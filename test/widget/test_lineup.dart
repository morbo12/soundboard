import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_lineup.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_color_state_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('Lineup displays loading state correctly', (
    WidgetTester tester,
  ) async {
    // Set loading state
    container.read(isLoadingProvider.notifier).state = true;

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Lineup(availableWidth: 300, availableHeight: 400),
          ),
        ),
      ),
    );

    // Verify loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Text), findsWidgets); // Loading messages
  });

  testWidgets('Lineup displays empty state correctly', (
    WidgetTester tester,
  ) async {
    // Set loading state to false
    container.read(isLoadingProvider.notifier).state = false;
    // Set empty lineup data
    container.read(lineupProvider.notifier).state = IbyMatchLineup(
      matchId: 0,
      homeTeamId: 1,
      homeTeam: 'N/A',
      homeTeamShortName: '',
      homeTeamLogotypeUrl: '',
      awayTeamId: 1,
      awayTeam: 'N/A',
      awayTeamShortName: '',
      awayTeamLogotypeUrl: '',
      homeTeamPlayers: [],
      awayTeamPlayers: [],
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Lineup(availableWidth: 300, availableHeight: 400),
          ),
        ),
      ),
    );

    // Verify empty state message
    expect(find.text('No Data'), findsOneWidget);
  });

  testWidgets('Lineup displays lineup data correctly', (
    WidgetTester tester,
  ) async {
    // Set loading state to false
    container.read(isLoadingProvider.notifier).state = false;

    // Create test lineup data
    final testData = IbyMatchLineup(
      matchId: 1,
      homeTeamId: 1,
      homeTeam: 'Home Team',
      homeTeamShortName: 'HOME',
      homeTeamLogotypeUrl: '',
      awayTeamId: 2,
      awayTeam: 'Away Team',
      awayTeamShortName: 'AWAY',
      awayTeamLogotypeUrl: '',
      homeTeamPlayers: [
        TeamPlayer(
          playerId: 1,
          name: 'Player 1',
          shirtNo: 10,
          position: 'Forward',
        ),
        TeamPlayer(
          playerId: 2,
          name: 'Player 2',
          shirtNo: 11,
          position: 'Defense',
        ),
      ],
      awayTeamPlayers: [
        TeamPlayer(
          playerId: 3,
          name: 'Player 3',
          shirtNo: 20,
          position: 'Forward',
        ),
      ],
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );

    // Set lineup data
    container.read(lineupProvider.notifier).state = testData;

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Lineup(availableWidth: 300, availableHeight: 400),
          ),
        ),
      ),
    );

    // Verify team names are displayed
    expect(find.text('Home Team'), findsOneWidget);
    expect(find.text('Away Team'), findsOneWidget);

    // Verify player information is displayed
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('F'), findsOneWidget); // Position abbreviation

    expect(find.text('Player 2'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('B'), findsOneWidget); // Position abbreviation

    expect(find.text('Player 3'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('F'), findsOneWidget); // Position abbreviation
  });

  testWidgets('Lineup handles player selection', (WidgetTester tester) async {
    // Set loading state to false
    container.read(isLoadingProvider.notifier).state = false;

    // Create test lineup data with a single player
    final testData = IbyMatchLineup(
      matchId: 1,
      homeTeamId: 1,
      homeTeam: 'Home Team',
      homeTeamShortName: 'HOME',
      homeTeamLogotypeUrl: '',
      awayTeamId: 2,
      awayTeam: 'Away Team',
      awayTeamShortName: 'AWAY',
      awayTeamLogotypeUrl: '',
      homeTeamPlayers: [
        TeamPlayer(
          playerId: 1,
          name: 'Player 1',
          shirtNo: 10,
          position: 'Forward',
        ),
      ],
      awayTeamPlayers: [],
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );

    // Set lineup data
    container.read(lineupProvider.notifier).state = testData;

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Lineup(availableWidth: 300, availableHeight: 400),
          ),
        ),
      ),
    );

    // Find and tap on a player
    final playerTile = find.text('Player 1');
    expect(playerTile, findsOneWidget);
    await tester.tap(playerTile);
    await tester.pump();

    // Verify player is selected (you might need to adjust this based on your UI)
    expect(find.byType(ListTile), findsWidgets);
    // Add more specific assertions based on your selection UI
  });

  testWidgets('Lineup handles window resize', (WidgetTester tester) async {
    // Set loading state to false
    container.read(isLoadingProvider.notifier).state = false;

    // Create test lineup data
    final testData = IbyMatchLineup(
      matchId: 1,
      homeTeamId: 1,
      homeTeam: 'Home Team',
      homeTeamShortName: 'HOME',
      homeTeamLogotypeUrl: '',
      awayTeamId: 2,
      awayTeam: 'Away Team',
      awayTeamShortName: 'AWAY',
      awayTeamLogotypeUrl: '',
      homeTeamPlayers: [
        TeamPlayer(
          playerId: 1,
          name: 'Player 1',
          shirtNo: 10,
          position: 'Forward',
        ),
      ],
      awayTeamPlayers: [],
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );

    // Set lineup data
    container.read(lineupProvider.notifier).state = testData;

    // Test with different sizes
    final testSizes = [(300.0, 400.0), (400.0, 600.0), (200.0, 300.0)];

    for (final (width, height) in testSizes) {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: Lineup(availableWidth: width, availableHeight: height),
            ),
          ),
        ),
      );

      // Verify the widget builds successfully with different sizes
      expect(find.byType(Lineup), findsOneWidget);
      expect(find.text('Home Team'), findsOneWidget);
      expect(find.text('Player 1'), findsOneWidget);
    }
  });

  testWidgets('Lineup handles goal input correctly', (
    WidgetTester tester,
  ) async {
    // Set loading state to false
    container.read(isLoadingProvider.notifier).state = false;

    // Create test lineup data
    final testData = IbyMatchLineup(
      matchId: 1,
      homeTeamId: 1,
      homeTeam: 'Home Team',
      homeTeamShortName: 'HOME',
      homeTeamLogotypeUrl: '',
      awayTeamId: 2,
      awayTeam: 'Away Team',
      awayTeamShortName: 'AWAY',
      awayTeamLogotypeUrl: '',
      homeTeamPlayers: [
        TeamPlayer(
          playerId: 1,
          name: 'Player 1',
          shirtNo: 10,
          position: 'Forward',
        ),
        TeamPlayer(
          playerId: 2,
          name: 'Player 2',
          shirtNo: 11,
          position: 'Defense',
        ),
      ],
      awayTeamPlayers: [],
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );

    // Set lineup data
    container.read(lineupProvider.notifier).state = testData;

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Lineup(availableWidth: 300, availableHeight: 400),
          ),
        ),
      ),
    );

    // Find and enter goal input
    final goalInput = find.widgetWithText(
      TextField,
      'Goal (time scorer [assist])',
    );
    expect(goalInput, findsOneWidget);
    await tester.enterText(
      goalInput,
      '112 10 11',
    ); // Time: 1:12, Scorer: 10, Assist: 11
    await tester.pump();

    // Verify player states are updated
    final playerStates = container.read(playerStatesProvider);
    expect(playerStates['10-Player 1'], equals(PlayerState.goal));
    expect(playerStates['11-Player 2'], equals(PlayerState.assist));

    // Verify goal input display
    expect(find.text('Tid: 01:12'), findsOneWidget);
    expect(find.text('Mål: 10-Player 1'), findsOneWidget);
    expect(find.text('Assist: 11-Player 2'), findsOneWidget);
  });

  testWidgets('Lineup handles penalty input correctly', (
    WidgetTester tester,
  ) async {
    // Set loading state to false
    container.read(isLoadingProvider.notifier).state = false;

    // Create test lineup data
    final testData = IbyMatchLineup(
      matchId: 1,
      homeTeamId: 1,
      homeTeam: 'Home Team',
      homeTeamShortName: 'HOME',
      homeTeamLogotypeUrl: '',
      awayTeamId: 2,
      awayTeam: 'Away Team',
      awayTeamShortName: 'AWAY',
      awayTeamLogotypeUrl: '',
      homeTeamPlayers: [
        TeamPlayer(
          playerId: 1,
          name: 'Player 1',
          shirtNo: 10,
          position: 'Forward',
        ),
      ],
      awayTeamPlayers: [],
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );

    // Set lineup data
    container.read(lineupProvider.notifier).state = testData;

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Lineup(availableWidth: 300, availableHeight: 400),
          ),
        ),
      ),
    );

    // Find and enter penalty input
    final penaltyInput = find.widgetWithText(
      TextField,
      'Penalty (time player code)',
    );
    expect(penaltyInput, findsOneWidget);
    await tester.enterText(
      penaltyInput,
      '112 10 201',
    ); // Time: 1:12, Player: 10, Code: 201
    await tester.pump();

    // Verify player state is updated
    final playerStates = container.read(playerStatesProvider);
    expect(playerStates['10-Player 1'], equals(PlayerState.penalty));

    // Verify penalty input display
    expect(find.text('Tid: 01:12'), findsOneWidget);
    expect(find.text('Spelare: 10-Player 1'), findsOneWidget);
    expect(find.text('Utvisning: 201 - Hållning (2 min)'), findsOneWidget);

    // Test penalty search
    final searchButton = find.byIcon(Icons.search);
    expect(searchButton, findsOneWidget);
    await tester.tap(searchButton);
    await tester.pump();

    // Verify penalty search is shown
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('201 - Hållning'), findsOneWidget);
    expect(find.text('Time: 2 min'), findsOneWidget);

    // Select a penalty from the search
    final penaltyItem = find.text('201 - Hållning');
    await tester.tap(penaltyItem);
    await tester.pump();

    // Verify penalty search is closed and penalty is selected
    expect(find.byType(ListView), findsNothing);
    expect(find.text('Utvisning: 201 - Hållning (2 min)'), findsOneWidget);
  });

  testWidgets('Lineup handles invalid input gracefully', (
    WidgetTester tester,
  ) async {
    // Set loading state to false
    container.read(isLoadingProvider.notifier).state = false;

    // Create test lineup data
    final testData = IbyMatchLineup(
      matchId: 1,
      homeTeamId: 1,
      homeTeam: 'Home Team',
      homeTeamShortName: 'HOME',
      homeTeamLogotypeUrl: '',
      awayTeamId: 2,
      awayTeam: 'Away Team',
      awayTeamShortName: 'AWAY',
      awayTeamLogotypeUrl: '',
      homeTeamPlayers: [
        TeamPlayer(
          playerId: 1,
          name: 'Player 1',
          shirtNo: 10,
          position: 'Forward',
        ),
      ],
      awayTeamPlayers: [],
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );

    // Set lineup data
    container.read(lineupProvider.notifier).state = testData;

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Lineup(availableWidth: 300, availableHeight: 400),
          ),
        ),
      ),
    );

    // Test invalid time format
    final goalInput = find.widgetWithText(
      TextField,
      'Goal (time scorer [assist])',
    );
    await tester.enterText(goalInput, '999 10'); // Invalid time
    await tester.pump();

    // Verify no goal state is set
    final playerStates = container.read(playerStatesProvider);
    expect(playerStates['10-Player 1'], isNull);

    // Test invalid player number
    await tester.enterText(goalInput, '112 99'); // Non-existent player
    await tester.pump();

    // Verify no goal state is set
    expect(playerStates['99-Player 1'], isNull);

    // Test invalid penalty code
    final penaltyInput = find.widgetWithText(
      TextField,
      'Penalty (time player code)',
    );
    await tester.enterText(penaltyInput, '112 10 999'); // Invalid penalty code
    await tester.pump();

    // Verify no penalty state is set
    expect(playerStates['10-Player 1'], isNull);
  });
}
