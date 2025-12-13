import 'package:flutter_riverpod/legacy.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/standings.dart';

/// Provider that holds the current standings data
final standingsProvider = StateProvider<Standings?>((ref) => null);
