enum EventType {
  practice('합주'),
  performance('공연'),
  other('기타');

  final String label;
  const EventType(this.label);
}

class Member {
  final String id;
  final String name;
  final String instrument;
  final String profileImageUrl;

  const Member({
    required this.id,
    required this.name,
    required this.instrument,
    required this.profileImageUrl,
  });
}

class BandEvent {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final String description;
  final List<String> setlist;

  const BandEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.description,
    this.setlist = const [],
  });
}

class Band {
  final String id;
  final String name;
  final String description;
  final List<Member> members;
  final List<BandEvent> events;

  const Band({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.events,
  });
}
