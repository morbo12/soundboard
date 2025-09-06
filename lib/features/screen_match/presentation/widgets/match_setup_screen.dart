import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/date_selector.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/federation_selector.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/match_selector.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/selectors/venue_selector.dart';

/// Modern split-screen match setup with clean, minimalist design.
class MatchSetupScreen extends ConsumerStatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  MatchSetupScreenState createState() => MatchSetupScreenState();
}

class MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  void _getMatches() async {
    final state = ref.read(matchSetupStateProvider);
    final service = ref.read(matchSetupServiceProvider);
    final notifier = ref.read(matchSetupStateProvider.notifier);

    try {
      notifier.setLoading(true);
      final matches = await service.getMatches(
        date: state.selectedDate,
        venueId: state.selectedVenue,
      );
      ref.read(matchesProvider.notifier).state = matches;
      notifier.setLoading(false);
    } catch (e) {
      notifier.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(matchSetupStateProvider);
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 900;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Matchval',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: isWideScreen
          ? _buildWideLayout(theme, state)
          : _buildNarrowLayout(theme, state),
    );
  }

  Widget _buildWideLayout(ThemeData theme, MatchSetupState state) {
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // Left Panel - Selectors
        Expanded(
          flex: 2,
          child: Container(
            color: colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Matchinställningar',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Välj förbund, anläggning och datum för att se tillgängliga matcher',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(40),

                  Expanded(child: _buildSelectors(theme)),
                ],
              ),
            ),
          ),
        ),

        // Right Panel - Match Results
        Expanded(flex: 3, child: _buildMatchResults(theme, state)),
      ],
    );
  }

  Widget _buildNarrowLayout(ThemeData theme, dynamic state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectors(theme),
          const Gap(32),
          _buildMatchResults(theme, state),
        ],
      ),
    );
  }

  Widget _buildSelectors(ThemeData theme) {
    return Column(
      children: [
        _buildSelectorTile(
          theme: theme,
          title: 'Förbund',
          icon: Icons.account_balance_outlined,
          child: const FederationSelector(),
        ),
        const Gap(20),

        _buildSelectorTile(
          theme: theme,
          title: 'Anläggning',
          icon: Icons.location_on_outlined,
          child: const VenueSelector(),
        ),
        const Gap(20),

        _buildSelectorTile(
          theme: theme,
          title: 'Datum',
          icon: Icons.calendar_today_outlined,
          child: DateSelector(callback: _getMatches),
        ),
      ],
    );
  }

  Widget _buildSelectorTile({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const Gap(12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }

  Widget _buildMatchResults(ThemeData theme, dynamic state) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_soccer_outlined,
                color: colorScheme.primary,
                size: 28,
              ),
              const Gap(12),
              Text(
                'Tillgängliga matcher',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            'Välj en match från listan nedan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(32),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant, width: 1),
              ),
              child: _buildMatchContent(theme, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchContent(ThemeData theme, dynamic state) {
    final colorScheme = theme.colorScheme;

    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
            const Gap(20),
            Text(
              'Laddar matcher...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: colorScheme.onErrorContainer,
                  size: 48,
                ),
              ),
              const Gap(24),
              Text(
                'Något gick fel',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                state.error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              FilledButton.icon(
                onPressed: _getMatches,
                icon: const Icon(Icons.refresh),
                label: const Text('Försök igen'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show matches or placeholder
    final hasValidSelections =
        state.selectedFederation > 0 && state.selectedVenue > 0;

    if (!hasValidSelections) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onSurfaceVariant,
                size: 48,
              ),
              const Gap(16),
              Text(
                'Välj förbund och anläggning',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(8),
              Text(
                'Gör dina val i panelen till vänster för att se tillgängliga matcher',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return const Padding(padding: EdgeInsets.all(16.0), child: MatchSelector());
  }
}
