import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_colors.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_type.dart';
import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
import 'package:soundboard/features/screen_home/presentation/ssml/class_pre_ssml.dart';

class EventCard extends ConsumerWidget {
  const EventCard({super.key, required this.data});
  final MatchEvent data;

  static const double _smallFontSize = 11.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      isThreeLine: true,
      dense: true,
      // visualDensity: VisualDensity.compact,
      onTap: () {
        PreSsml(ref: ref, data: data).getEventText(context);
        if (kDebugMode) {
          print("Button pressed");
        }
      },
      leading: Icon(
        _getEventIcon(data.matchEventTypeID),
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      textColor: MatchEventColors(data.matchEventTypeID).getTextColor(context),
      tileColor: MatchEventColors(data.matchEventTypeID).getColor(context),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventHeader(),
          // _buildEventDetails(),
        ],
      ),
      subtitle: _buildEventDetails(),
    );
  }

  Widget _buildEventHeader() {
    return Row(
      children: [
        AutoSizeText(
          "${MatchEventTypes.getEventName(data.matchEventTypeID)} | ",
          minFontSize: _smallFontSize,
          style: const TextStyle(
              fontSize: _smallFontSize + 2, fontWeight: FontWeight.bold),
        ),
        AutoSizeText(
          "${data.minute}:${data.second.toString().padLeft(2, '0')} | ",
          minFontSize: _smallFontSize,
          style: TextStyle(
              fontSize: _smallFontSize + 2, fontWeight: FontWeight.bold),
        ),
        if (_isGoalEvent())
          AutoSizeText(
            "${data.goalsHomeTeam} - ${data.goalsAwayTeam} ",
            minFontSize: _smallFontSize,
            style: const TextStyle(
                fontSize: _smallFontSize, fontWeight: FontWeight.bold),
          ),
        AutoSizeText(
            data.matchTeamName.length < 20
                ? data.matchTeamName
                : "| ${data.matchTeamName.substring(0, 22) + "..."}",
            minFontSize: _smallFontSize,
            style: const TextStyle(
                fontSize: _smallFontSize + 2,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildEventDetails() {
    return Row(
      children: [
        AutoSizeText(
          "${data.playerShirtNo != null ? "${data.playerShirtNo}. " : ""}${data.playerName}\n${_buildSubTitle()}",
          maxLines: 2,
          minFontSize: _smallFontSize,
          style: const TextStyle(
              fontSize: _smallFontSize, fontStyle: FontStyle.normal),
        ),
      ],
    );
  }

  bool _isGoalEvent() {
    return data.matchEventTypeID == MatchEventType.mal ||
        data.matchEventTypeID == MatchEventType.straffmal;
  }

  String _buildSubTitle() {
    switch (data.matchEventTypeID) {
      case MatchEventType.mal:
      case MatchEventType.straffmal:
        return _isAssist();
      case MatchEventType.utvisning:
        return _isPenalty();
      default:
        return "";
    }
  }

  String _isAssist() {
    if (data.playerAssistShirtNo != null) {
      return "Ass: ${data.playerAssistShirtNo}. ${data.playerAssistName}";
    } else {
      return "";
    }
  }

  String _isPenalty() {
    return data.penaltyName;
  }
}

class EventCardSubTile extends StatelessWidget {
  const EventCardSubTile({super.key, required this.data});
  final MatchEvent data;

  static const double _mediumFontSize = 6.0;
  static const double _smallFontSize = 11.0;

  @override
  Widget build(BuildContext context) {
    switch (data.matchEventTypeID) {
      case MatchEventType.mal:
      case MatchEventType.straffmal:
      // return _buildAssistText();
      case MatchEventType.utvisning:
        return _buildPenaltyText();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPenaltyText() {
    return AutoSizeText(
      data.penaltyName,
      maxLines: 1,
      minFontSize: _smallFontSize,
      style: const TextStyle(
          fontSize: _mediumFontSize, fontStyle: FontStyle.italic),
      textAlign: TextAlign.left,
    );
  }
}

IconData _getEventIcon(int eventTypeID) {
  switch (eventTypeID) {
    case MatchEventType.mal:
    case MatchEventType.straffmal:
      return Icons.sports_soccer;
    case MatchEventType.utvisning:
      return Icons.timer;
    case MatchEventType.timeoutHemma:
    case MatchEventType.timeoutBorta:
      return Icons.pause;
    default:
      return Icons.event;
  }
}
