enum EventType {
  practice('합주', 'practice'),
  performance('공연', 'performance'),
  other('기타', 'other');

  final String label;
  final String wireName;
  const EventType(this.label, this.wireName);

  static EventType fromWire(String value) {
    return EventType.values.firstWhere(
      (e) => e.wireName == value,
      orElse: () => EventType.other,
    );
  }
}

enum BandMemberRole {
  owner('owner'),
  member('member');

  final String wireName;
  const BandMemberRole(this.wireName);

  static BandMemberRole fromWire(String value) {
    return BandMemberRole.values.firstWhere(
      (e) => e.wireName == value,
      orElse: () => BandMemberRole.member,
    );
  }
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

  factory SetlistItem.fromJson(Map<String, dynamic> json) {
    return SetlistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      key: json['key'] as String?,
      sheetMusicUrl: json['sheetMusicUrl'] as String?,
      references: ((json['references'] as List?) ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }

  /// 신규 항목 생성용 (id 없이 보내거나 기존 id로 업데이트).
  Map<String, dynamic> toRequestJson() {
    return {
      if (id.isNotEmpty && !id.startsWith('new_')) 'id': id,
      'title': title,
      'artist': artist,
      if (key != null) 'key': key,
      if (sheetMusicUrl != null) 'sheetMusicUrl': sheetMusicUrl,
      'references': references,
    };
  }
}

class Member {
  final String id;
  final String name;
  final String email;
  final String? instrument;
  final String? profileImageUrl;
  final BandMemberRole role;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    this.instrument,
    this.profileImageUrl,
    this.role = BandMemberRole.member,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      email: (json['email'] as String?) ?? '',
      instrument: json['instrument'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: BandMemberRole.fromWire(
          (json['role'] as String?) ?? 'member'),
    );
  }
}

class BandEvent {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final String? description;
  final List<SetlistItem> setlist;

  const BandEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
    this.setlist = const [],
  });

  factory BandEvent.fromJson(Map<String, dynamic> json) {
    return BandEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      type: EventType.fromWire(json['type'] as String),
      description: json['description'] as String?,
      setlist: ((json['setlist'] as List?) ?? const [])
          .map((e) => SetlistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 생성 요청 바디 (`CreateEventRequest`).
  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'date': _formatDate(date),
      'type': type.wireName,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (setlist.isNotEmpty)
        'setlist': setlist.map((s) => s.toRequestJson()).toList(),
    };
  }

  /// 수정 요청 바디 (`UpdateEventRequest`) — 변경된 필드만 보낼 때 사용.
  Map<String, dynamic> toUpdateJson() => toCreateJson();

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

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
  final String? description;
  final int memberCount;
  final List<Member> members;
  final List<BandEvent> events;

  const Band({
    required this.id,
    required this.name,
    this.description,
    this.memberCount = 0,
    this.members = const [],
    this.events = const [],
  });

  /// `BandResponse` (목록/상세 공통) — members/events 미포함.
  factory Band.fromJson(Map<String, dynamic> json) {
    return Band(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  Band copyWith({
    String? id,
    String? name,
    String? description,
    int? memberCount,
    List<Member>? members,
    List<BandEvent>? events,
  }) {
    return Band(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      members: members ?? this.members,
      events: events ?? this.events,
    );
  }
}
