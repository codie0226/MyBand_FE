enum EventType {
  practice('합주'),
  performance('공연'),
  other('기타');

  final String label;
  const EventType(this.label);
}

class SetlistItem {
  final String id;
  final String title;
  final String artist;
  final String? key;
  final String? sheetMusicUrl;
  final List<String> references;

  const SetlistItem({
    required this.id,
    required this.title,
    required this.artist,
    this.key,
    this.sheetMusicUrl,
    this.references = const [],
  });
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
  final List<SetlistItem> setlist;

  const BandEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.description,
    this.setlist = const [],
  });

  BandEvent copyWith({
    String? id,
    String? title,
    DateTime? date,
    EventType? type,
    String? description,
    List<SetlistItem>? setlist,
  }) {
    return BandEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      setlist: setlist ?? this.setlist,
    );
  }
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

  Band copyWith({
    String? id,
    String? name,
    String? description,
    List<Member>? members,
    List<BandEvent>? events,
  }) {
    return Band(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      members: members ?? this.members,
      events: events ?? this.events,
    );
  }
}
