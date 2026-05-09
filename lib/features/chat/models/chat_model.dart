class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderProfileImageUrl;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderProfileImageUrl,
    required this.text,
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
