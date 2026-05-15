enum ChatAttachmentType {
  image('image'),
  pdf('pdf');

  final String wireName;
  const ChatAttachmentType(this.wireName);

  static ChatAttachmentType fromWire(String value) {
    return ChatAttachmentType.values.firstWhere(
      (type) => type.wireName == value,
      orElse: () => ChatAttachmentType.pdf,
    );
  }
}

class ChatAttachment {
  final ChatAttachmentType type;
  final String url;
  final String filename;

  const ChatAttachment({
    required this.type,
    required this.url,
    required this.filename,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      type: ChatAttachmentType.fromWire(json['type'] as String),
      url: json['url'] as String,
      filename: json['filename'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type.wireName, 'url': url, 'filename': filename};
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderProfileImageUrl;
  final String text;
  final List<ChatAttachment> attachments;
  final bool isMe;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderProfileImageUrl,
    required this.text,
    this.attachments = const [],
    required this.isMe,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = json['senderId'] as String;

    return ChatMessage(
      id: json['id'] as String,
      senderId: senderId,
      senderName: json['senderName'] as String,
      senderProfileImageUrl: json['senderProfileImageUrl'] as String?,
      text: json['text'] as String,
      attachments: ((json['attachments'] as List?) ?? const [])
          .map((item) => ChatAttachment.fromJson(item as Map<String, dynamic>))
          .toList(),
      isMe: senderId == currentUserId,
      timestamp: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }
}

class ChatMessagePage {
  final List<ChatMessage> messages;
  final String? nextCursor;

  const ChatMessagePage({required this.messages, required this.nextCursor});
}
