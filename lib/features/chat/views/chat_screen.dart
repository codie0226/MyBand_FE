import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../../my_band/models/band_models.dart';
import '../../my_band/providers/band_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? _currentBandId;
  List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          senderName: '나',
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Band>>(selectedBandProvider, (_, next) {
      next.whenData((band) {
        if (_currentBandId != band.id) {
          setState(() {
            _currentBandId = band.id;
            _messages = generateDummyChatMessages(_currentBandId!);
          });
        }
      });
    });

    final bandAsync = ref.watch(selectedBandProvider);

    return bandAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (selectedBand) => Scaffold(
        appBar: AppBar(
          title: Text('${selectedBand.name} 채팅방'),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final previousMessage =
                      index > 0 ? _messages[index - 1] : null;

                  bool showDateSeparator = false;
                  if (previousMessage == null) {
                    showDateSeparator = true;
                  } else {
                    final msgDate = DateTime(message.timestamp.year,
                        message.timestamp.month, message.timestamp.day);
                    final prevDate = DateTime(previousMessage.timestamp.year,
                        previousMessage.timestamp.month,
                        previousMessage.timestamp.day);
                    if (msgDate != prevDate) showDateSeparator = true;
                  }

                  final bubble = ChatBubble(message: message);
                  if (showDateSeparator) {
                    final dateString =
                        '${message.timestamp.year}년 ${message.timestamp.month}월 ${message.timestamp.day}일';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 24.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      color: Theme.of(context).dividerColor)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  dateString,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: Theme.of(context).dividerColor)),
                            ],
                          ),
                        ),
                        bubble,
                      ],
                    );
                  }
                  return bubble;
                },
              ),
            ),
            ChatInputBar(onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}
