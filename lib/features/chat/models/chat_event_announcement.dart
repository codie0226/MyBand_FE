import 'dart:convert';

import '../../my_band/models/band_models.dart';

const eventAnnouncementPrefix = '@@myband:event-announcement:v1@@';

class ChatEventAnnouncement {
  const ChatEventAnnouncement({
    required this.eventId,
    required this.title,
    required this.date,
    required this.typeLabel,
    required this.description,
    required this.setlistCount,
  });

  final String eventId;
  final String title;
  final DateTime date;
  final String typeLabel;
  final String description;
  final int setlistCount;

  factory ChatEventAnnouncement.fromEvent(BandEvent event) {
    return ChatEventAnnouncement(
      eventId: event.id,
      title: event.title,
      date: event.date,
      typeLabel: event.type.label,
      description: event.description?.trim() ?? '',
      setlistCount: event.setlist.length,
    );
  }

  static ChatEventAnnouncement? tryParse(String text) {
    if (!text.startsWith(eventAnnouncementPrefix)) return null;

    try {
      final raw = text.substring(eventAnnouncementPrefix.length);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ChatEventAnnouncement(
        eventId: json['eventId'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String).toLocal(),
        typeLabel: json['typeLabel'] as String,
        description: (json['description'] as String?)?.trim() ?? '',
        setlistCount: (json['setlistCount'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  String toMessageText() {
    return '$eventAnnouncementPrefix${jsonEncode({
          'eventId': eventId,
          'title': title,
          'date': date.toIso8601String(),
          'typeLabel': typeLabel,
          'description': description,
          'setlistCount': setlistCount,
        })}';
  }
}
