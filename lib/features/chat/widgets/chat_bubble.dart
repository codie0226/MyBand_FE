import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final theme = Theme.of(context);

    // Format the time as h:mm a (e.g., 2:30 PM) or suitable Korean format
    final timeString = DateFormat('a h:mm', 'ko_KR').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: isMe
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTime(context, timeString),
                const SizedBox(width: 6),
                Flexible(
                  child: _buildBubble(context),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                  child: Text(
                    message.senderName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: _buildBubble(context),
                    ),
                    const SizedBox(width: 6),
                    _buildTime(context, timeString),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final isMe = message.isMe;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isMe ? theme.colorScheme.secondary : theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        border: isMe ? null : Border.all(color: theme.dividerColor),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isMe ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTime(BuildContext context, String time) {
    return Text(
      time,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 11,
      ),
    );
  }
}
