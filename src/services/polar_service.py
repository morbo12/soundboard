import os
import requests
import json
import logging
from typing import Optional, Dict, Any

# Import for retry mechanism
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# --- Logging Configuration ---
# Configure basic logging for the module.
# In a real application, this would typically be set up globally by the application's main entry point.
logging.basicConfig(level=os.environ.get("POLAR_SERVICE_LOG_LEVEL", "INFO").upper(),
                    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class PolarServiceError(Exception):
    """Custom exception for Polar.sh service errors."""
    pass

class PolarService:
    """
    A robust client service for interacting with the Polar.sh API.
    Handles API key authentication, request making, error handling, retries,
    and configurable timeouts.
    """
    def __init__(
        self,
        api_key: Optional[str] = None,
        base_url: Optional[str] = None,
        timeout: int = 30,  # Default timeout in seconds
        retries: int = 3,   # Default number of retries for transient errors
        backoff_factor: float = 0.3, # Factor for exponential backoff (0.3, 0.6, 1.2, ...)
        user_agent: Optional[str] = None
    ):
        """
        Initializes the PolarService client.
        Args:
            api_key (str, optional): The Polar API key. If not provided, it attempts to load from POLAR_API_KEY env var.
            base_url (str, optional): The base URL for the Polar API. If not provided, it uses POLAR_API_BASE_URL env var.
            timeout (int): Default timeout for HTTP requests in seconds.
            retries (int): Number of times to retry failed requests (e.g., 5xx, 429).
            backoff_factor (float): Factor for exponential backoff between retries.
            user_agent (str, optional): Custom User-Agent header. Defaults to a standard string.
        Raises:
            PolarServiceError: If the API key is not set.
        """
        # Load configuration from arguments or environment variables
        self.api_key = api_key or os.environ.get("POLAR_API_KEY")
        self.base_url = (
            base_url or os.environ.get("POLAR_API_BASE_URL", "https://api.polar.sh/api/v1")
        ).rstrip('/') # Ensure no trailing slash for consistent path joining

        if not self.api_key:
            logger.error("POLAR_API_KEY is not set. Please provide it or set the environment variable.")
            raise PolarServiceError("POLAR_API_KEY is not set. Please provide it or set the environment variable.")

        self.timeout = timeout
        self.user_agent = user_agent or "YourAppName/1.0 (PolarIntegrationService)"

        # Setup requests session with retries for performance and robustness
        self._session = requests.Session()
        
        # Configure retry strategy for transient errors
        retry_strategy = Retry(
            total=retries,
            backoff_factor=backoff_factor,
            status_forcelist=[429, 500, 502, 503, 504], # Retry on these HTTP status codes
            allowed_methods=["HEAD", "GET", "PUT", "DELETE", "OPTIONS", "TRACE"] 
            # POST is generally not retried by default as it's often not idempotent.
            # If a specific POST endpoint is idempotent, it should be explicitly added here.
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self._session.mount("http://", adapter)
        self._session.mount("https://", adapter)

        # Apply common headers to the session
        self._session.headers.update({
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": self.user_agent,
        })

        logger.info(f"PolarService initialized with base_url: {self.base_url}, timeout: {self.timeout}s, retries: {retries}")


    def _make_request(
        self, method: str, path: str, params: Optional[Dict] = None, json_data: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """
        Makes an HTTP request to the Polar.sh API using the configured session.
        Args:
            method (str): The HTTP method (e.g., "GET", "POST").
            path (str): The API endpoint path (e.g., "pledges").
            params (Dict, optional): Dictionary of URL query parameters.
            json_data (Dict, optional): Dictionary of JSON data to send in the request body.
        Returns:
            Dict[str, Any]: The JSON response from the API. Returns an empty dict for 204 No Content.
        Raises:
            PolarServiceError: For API-specific errors, network errors, or timeouts.
        """
        url = f"{self.base_url}/{path.lstrip('/')}"
        logger.debug(f"Making {method} request to {url} with params: {params}, json_data: {json_data}")

        try:
            response = self._session.request(method, url, params=params, json=json_data, timeout=self.timeout)
            response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
            
            # Handle 204 No Content response gracefully
            if response.status_code == 204:
                return {} 
            
            return response.json()
        except requests.exceptions.HTTPError as e:
            try:
                # Attempt to parse JSON error details from response body
                error_details = e.response.json()
                # Prioritize 'detail' or 'message' fields, fallback to full text
                detail_message = error_details.get('detail', error_details.get('message', e.response.text))
                logger.error(
                    f"Polar API HTTP Error: {detail_message} (Status: {e.response.status_code}) for {method} {url}"
                )
                raise PolarServiceError(
                    f"Polar API HTTP Error: {detail_message} (Status: {e.response.status_code})"
                ) from e
            except json.JSONDecodeError:
                # If response body is not JSON, use raw text
                logger.error(
                    f"Polar API HTTP Error (non-JSON response): {e.response.text} (Status: {e.response.status_code}) for {method} {url}"
                )
                raise PolarServiceError(
                    f"Polar API HTTP Error: {e.response.text} (Status: {e.response.status_code})"
                ) from e
        except requests.exceptions.ConnectionError as e:
            logger.error(f"Polar API Connection Error: Could not connect to {url}: {e}")
            raise PolarServiceError(f"Polar API Connection Error: Could not connect to {url}: {e}") from e
        except requests.exceptions.Timeout as e:
            logger.error(f"Polar API Timeout Error: Request to {url} timed out after {self.timeout}s: {e}")
            raise PolarServiceError(f"Polar API Timeout Error: Request to {url} timed out: {e}") from e
        except requests.exceptions.RequestException as e:
            # Catch any other requests-related exceptions (e.g., TooManyRedirects)
            logger.error(f"An unexpected error occurred during Polar API request to {url}: {e}")
            raise PolarServiceError(f"An unexpected error occurred during Polar API request to {url}: {e}") from e
        except Exception as e:
            # Catch any other truly unexpected exceptions
            logger.critical(f"A critical unexpected error occurred: {e}", exc_info=True)
            raise PolarServiceError(f"A critical unexpected error occurred: {e}") from e

    def get_pledges(self, organization_id: Optional[str] = None, issue_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Fetches a list of pledges.
        Args:
            organization_id (str, optional): Filter pledges by organization ID.
            issue_id (str, optional): Filter pledges by issue ID.
        Returns:
            Dict[str, Any]: A dictionary containing a list of pledges and pagination info.
                            Example: {"items": [...], "pagination": {...}}
        """
        path = "pledges"
        params = {}
        if organization_id:
            params["organization_id"] = organization_id
        if issue_id:
            params["issue_id"] = issue_id

        logger.info(f"Fetching pledges with params: {params}")
        return self._make_request("GET", path, params=params)

    def create_pledge(self, issue_id: str, amount_in_cents: int, email: str, by_user_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Creates a new pledge for a specific issue.
        Args:
            issue_id (str): The ID of the issue to pledge to.
            amount_in_cents (int): The pledge amount in cents (e.g., 500 for $5.00).
            email (str): The email address of the backer.
            by_user_id (str, optional): An optional external user ID to link the pledge.
                                        This might depend on specific Polar API features.
        Returns:
            Dict[str, Any]: The newly created pledge object.
        """
        path = "pledges"
        payload = {
            "issue_id": issue_id,
            "amount": amount_in_cents,
            "email": email,
        }
        if by_user_id:
            # IMPORTANT: This field name ('external_id') is a common pattern for linking
            # internal user IDs to external systems. Please verify with the actual Polar.sh
            # API documentation if they support this, and what the exact field name is.
            # If not supported, remove this 'if' block.
            payload["external_id"] = by_user_id
            
        logger.info(f"Creating pledge for issue '{issue_id}' with amount {amount_in_cents} cents for '{email}'")
        return self._make_request("POST", path, json_data=payload)

    def get_user_subscriptions(self, user_email: str) -> Dict[str, Any]:
        """
        Fetches subscriptions for a given user email.
        Note: This is a hypothetical method. Polar.sh's direct API might not expose
        user-specific subscriptions directly via email lookup on a single endpoint.
        You might need to list all subscriptions for your organization and then filter,
        or use a more specific 'user' endpoint if it exists.
        For illustration, we assume a path like `subscriptions` which can be filtered.
        Please confirm with Polar API documentation.
        """
        path = "subscriptions"
        params = {"email": user_email} # This assumes the API supports filtering by email.
        logger.info(f"Attempting to fetch subscriptions for user_email: {user_email}")
        return self._make_request("GET", path, params=params)

    # You can add more methods here to interact with other Polar API endpoints,
    # e.g., get_issue_by_id, list_organizations, handle_webhooks, etc.

# --- Example Usage ---
if __name__ == "__main__":
    # To run this example, set POLAR_API_KEY environment variable.
    # Example for Linux/macOS: export POLAR_API_KEY="polar_api_key_..."
    # Example for Windows (cmd): set POLAR_API_KEY="polar_api_key_..."
    # Optionally: export POLAR_API_BASE_URL="https://api.polar.sh/api/v1"
    # Optionally: export POLAR_SERVICE_LOG_LEVEL="DEBUG"

    # Configure root logger for example usage (would be handled by main app in production)
    logging.basicConfig(level=os.environ.get("POLAR_SERVICE_LOG_LEVEL", "INFO").upper(),
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger = logging.getLogger(__name__)

    if not os.environ.get("POLAR_API_KEY"):
        logger.critical("Please set the POLAR_API_KEY environment variable to test this service.")
        logger.info("You can get your API key from your Polar.sh dashboard under Settings -> API.")
        exit(1)

    try:
        # Initialize with custom timeout or other settings if needed
        # polar_service = PolarService(timeout=15, retries=5, user_agent="MyAppTesting/1.0")
        polar_service = PolarService()
        logger.info("PolarService initialized successfully.")

        # --- Example 1: Fetch Pledges ---
        logger.info("\n--- Example: Fetching Pledges ---")
        try:
            # This will fetch all pledges accessible by the configured API key's organization.
            # You might want to filter these by organization_id or issue_id.
            pledges_response = polar_service.get_pledges()
            logger.info("Fetched pledges (raw response):")
            logger.info(json.dumps(pledges_response, indent=2))

            if pledges_response and pledges_response.get('items'):
                logger.info(f"Found {len(pledges_response['items'])} pledges. First pledge ID: {pledges_response['items'][0].get('id')}")
            else:
                logger.info("No pledges found or response was empty.")
        except PolarServiceError as e:
            logger.error(f"Failed to fetch pledges: {e}")

        # --- Example 2: Create a Pledge (requires a valid issue ID and organization) ---
        # NOTE: Uncomment and replace placeholders with actual values to test.
        # This will create a real pledge on your Polar.sh organization if successful.
        # logger.info("\n--- Example: Creating a Pledge ---")
        # try:
        #     # Replace with a real issue ID from your Polar organization.
        #     # You can find issue IDs in the URL of an issue on polar.sh, e.g.,
        #     # https://polar.sh/organizations/your-org/issues/ISSUE_ID
        #     issue_id_to_pledge = "REPLACE_WITH_ACTUAL_POLAR_ISSUE_ID"
        #     pledge_amount_cents = 500  # $5.00 USD
        #     backer_email = "test.backer@example.com" # Replace with a test email

        #     if issue_id_to_pledge == "REPLACE_WITH_ACTUAL_POLAR_ISSUE_ID":
        #         logger.info("Skipping pledge creation: Please replace 'REPLACE_WITH_ACTUAL_POLAR_ISSUE_ID' with a real issue ID.")
        #     else:
        #         new_pledge = polar_service.create_pledge(issue_id_to_pledge, pledge_amount_cents, backer_email)
        #         logger.info("Pledge created successfully:")
        #         logger.info(json.dumps(new_pledge, indent=2))
        # except PolarServiceError as e:
        #     logger.error(f"Failed to create pledge: {e}")

        # --- Example 3: Fetch User Subscriptions (Hypothetical, depends on Polar API specifics) ---
        # logger.info("\n--- Example: Fetching User Subscriptions ---")
        # try:
        #     # This assumes the Polar API has a direct endpoint to query subscriptions by email.
        #     # If not, you'd typically fetch all subscriptions and filter client-side.
        #     user_subscriptions_email = "some_user@example.com" # Replace with an actual user email
        #     subscriptions_response = polar_service.get_user_subscriptions(user_subscriptions_email)
        #     logger.info(f"Fetched subscriptions for '{user_subscriptions_email}' (raw response):")
        #     logger.info(json.dumps(subscriptions_response, indent=2))
        # except PolarServiceError as e:
        #     logger.error(f"Failed to fetch user subscriptions: {e}")


    except PolarServiceError as e:
        logger.critical(f"Service initialization failed: {e}")
    except Exception as e:
        logger.critical(f"An unexpected error occurred during example execution: {e}", exc_info=True)