import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/utils/responsive_utils.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/date_selector.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/federation_selector.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/match_selector.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/venue_selector.dart';
import 'package:soundboard/features/screen_match/utils/match_setup_constants.dart';

/// Main screen for setting up a match.
///
/// This screen provides a user interface for selecting:
/// - Federation
/// - Venue
/// - Date
/// - Match
///
/// The screen handles loading states and error conditions, providing appropriate
/// feedback to the user during the match selection process.
class MatchSetupScreen extends ConsumerStatefulWidget {
  /// Creates a new instance of [MatchSetupScreen].
  const MatchSetupScreen({super.key});

  @override
  MatchSetupScreenState createState() => MatchSetupScreenState();
}

/// State class for [MatchSetupScreen].
///
/// Manages the state and logic for the match setup process, including:
/// - Fetching matches based on user selections
/// - Handling loading states
/// - Managing error conditions
/// - Updating the UI accordingly
class MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  /// Fetches matches based on the current state selections.
  ///
  /// This method:
  /// 1. Updates the loading state
  /// 2. Fetches matches using the [MatchSetupService]
  /// 3. Updates the matches provider with the results
  /// 4. Handles any errors that occur during the process
  ///
  /// The method updates the UI state to reflect:
  /// - Loading progress
  /// - Success with matches
  /// - Error conditions
  void _getMatches() async {
    final state = ref.read(matchSetupStateProvider);
    final service = ref.read(matchSetupServiceProvider);
    final notifier = ref.read(matchSetupStateProvider.notifier);

    try {
      // Set loading state
      notifier.setLoading(true);

      // Fetch matches
      final matches = await service.getMatches(
        date: state.selectedDate,
        venueId: state.selectedVenue,
      );

      // Update state with matches
      ref.read(matchesProvider.notifier).state = matches;
      notifier.setLoading(false);
    } catch (e) {
      // Handle error
      notifier.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(matchSetupStateProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200, minWidth: 600),
            child: Container(
              width: screenWidth * 0.8,
              height: ResponsiveUtils.getHeight(context),
              padding: const EdgeInsets.all(MatchSetupConstants.defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Federation selector section
                  Text(
                    MatchSetupConstants.selectFederation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(MatchSetupConstants.gapSize),
                  const FederationSelector(),
                  const Gap(MatchSetupConstants.gapSize),

                  // Venue selector section
                  Text(
                    MatchSetupConstants.selectVenue,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(MatchSetupConstants.gapSize),
                  const VenueSelector(),
                  const Gap(MatchSetupConstants.gapSize),

                  // Date selector section
                  Text(
                    MatchSetupConstants.selectDate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(MatchSetupConstants.gapSize),
                  DateSelector(callback: _getMatches),
                  const Gap(MatchSetupConstants.gapSize),

                  // Match selector section
                  Text(
                    MatchSetupConstants.selectMatch,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(MatchSetupConstants.gapSize),

                  // Dynamic content based on state
                  if (state.isLoading)
                    const Expanded(
                      flex: 2,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.error != null)
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 48,
                            ),
                            const Gap(16),
                            Text(
                              state.error!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Gap(16),
                            ElevatedButton(
                              onPressed: _getMatches,
                              child: const Text('Försök igen'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Expanded(flex: 2, child: MatchSelector()),
                  const Gap(MatchSetupConstants.gapSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
