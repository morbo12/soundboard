import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/standings.dart';

/// Provider that holds the current standings data
final standingsProvider = StateProvider<Standings?>((ref) => null);
