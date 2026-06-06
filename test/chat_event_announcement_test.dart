import 'package:flutter_test/flutter_test.dart';
import 'package:my_band/features/chat/models/chat_event_announcement.dart';
import 'package:my_band/features/my_band/models/band_models.dart';

void main() {
  test('serializes and parses event announcement messages', () {
    final event = BandEvent(
      id: 'event-1',
      title: '합주',
      date: DateTime(2026, 6, 7),
      type: EventType.practice,
      description: '신곡 위주로 맞춰보기',
      setlist: const [
        SetlistItem(id: 'set-1', title: 'Song', artist: 'Artist'),
      ],
    );

    final text = ChatEventAnnouncement.fromEvent(event).toMessageText();
    final parsed = ChatEventAnnouncement.tryParse(text);

    expect(parsed, isNotNull);
    expect(parsed!.eventId, 'event-1');
    expect(parsed.title, '합주');
    expect(parsed.description, '신곡 위주로 맞춰보기');
    expect(parsed.typeLabel, '합주');
    expect(parsed.setlistCount, 1);
  });

  test('ignores normal chat messages', () {
    expect(ChatEventAnnouncement.tryParse('일반 메시지'), isNull);
  });
}
