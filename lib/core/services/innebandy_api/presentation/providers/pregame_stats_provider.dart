import 'package:flutter_riverpod/legacy.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/pregame_stats.dart';

/// Provider that holds the current pregame statistics data
final pregameStatsProvider = StateProvider<PregameStats?>((ref) => null);
