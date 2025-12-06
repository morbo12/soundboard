import 'package:auto_size_text/auto_size_text.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_colors.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_type.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_event_card.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_goalevent.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_penaltyevent.dart';
import 'package:soundboard/core/utils/logger.dart';

class EventCard extends ConsumerWidget {
  const EventCard({super.key, required this.data});
  final IbyMatchEvent data;

  static const double _smallFontSize = 11.0;
  final Logger logger = const Logger('EventCard');

  String _getEventText(BuildContext context, WidgetRef ref) {
    switch (data.matchEventTypeId) {
      case MatchEventType.utvisning:
        return _stripSsmlTags(
          SsmlPenaltyEvent(ref: ref, matchEvent: data).formatAnnouncement(),
        );
      case MatchEventType.straffmal:
      case MatchEventType.mal:
        return _stripSsmlTags(
          SsmlGoalEvent(ref: ref, matchEvent: data).formatAnnouncement(),
        );
      default:
        return "";
    }
  }

  String _stripSsmlTags(String text) {
    // Remove SSML/XML tags using regex
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  void _showTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Announcement Text'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = MatchEventColors(data.matchEventTypeId);
    final backgroundColor = colors.getTileColor(context);
    final textColor = colors.getTextColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Card(
        elevation: 2,
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          isThreeLine: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          onTap: () {
            EventCardSsml(ref: ref, data: data).getEventText(context);
            logger.d("Button pressed");
          },
          onLongPress: () {
            final text = _getEventText(context, ref);
            _showTextDialog(context, text);
          },
          leading: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEventIcon(data.matchEventTypeId),
              color: textColor,
              size: 20,
            ),
          ),
          textColor: textColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildEventHeader()],
          ),
          subtitle: _buildEventDetails(),
        ),
      ),
    );
  }

  Widget _buildEventHeader() {
    return Row(
      children: [
        AutoSizeText(
          "${MatchEventTypes.getEventName(data.matchEventTypeId)} | ",
          minFontSize: _smallFontSize,
          style: const TextStyle(
            fontSize: _smallFontSize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        AutoSizeText(
          "${data.minute}:${data.second.toString().padLeft(2, '0')} | ",
          minFontSize: _smallFontSize,
          style: const TextStyle(
            fontSize: _smallFontSize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_isGoalEvent())
          AutoSizeText(
            "${data.goalsHomeTeam} - ${data.goalsAwayTeam} | ",
            minFontSize: _smallFontSize,
            style: const TextStyle(
              fontSize: _smallFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        AutoSizeText(
          data.matchTeamName.length < 20
              ? data.matchTeamName
              : "${data.matchTeamName.substring(0, 17) + "..."}",
          minFontSize: _smallFontSize,
          style: const TextStyle(
            fontSize: _smallFontSize + 2,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
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
            fontSize: _smallFontSize,
            fontStyle: FontStyle.normal,
          ),
        ),
      ],
    );
  }

  bool _isGoalEvent() {
    return data.matchEventTypeId == MatchEventType.mal ||
        data.matchEventTypeId == MatchEventType.straffmal;
  }

  String _buildSubTitle() {
    switch (data.matchEventTypeId) {
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
    const int maxLength = 43;
    if (data.penaltyName.isEmpty) return '';

    return data.penaltyName.length > maxLength
        ? '${data.penaltyName.substring(0, math.min(maxLength, data.penaltyName.length))}...'
        : data.penaltyName;
  }
}

class EventCardSubTile extends StatelessWidget {
  const EventCardSubTile({super.key, required this.data});
  final IbyMatchEvent data;

  static const double _mediumFontSize = 6.0;
  static const double _smallFontSize = 11.0;

  @override
  Widget build(BuildContext context) {
    switch (data.matchEventTypeId) {
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
        fontSize: _mediumFontSize,
        fontStyle: FontStyle.italic,
      ),
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
