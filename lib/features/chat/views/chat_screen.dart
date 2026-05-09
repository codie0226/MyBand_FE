import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../my_band/providers/band_provider.dart';
import '../../profile/providers/user_provider.dart';
import '../data/chat_repository.dart';
import '../models/chat_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  String? _currentBandId;
  String? _currentUserId;
  WebSocketChannel? _channel;
  StreamSubscription<ChatMessage>? _messageSubscription;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _loadError;

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _channel?.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureChatStarted({required String bandId, required String userId}) {
    if (_currentBandId == bandId && _currentUserId == userId) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_currentBandId == bandId && _currentUserId == userId) return;
      _loadChat(bandId: bandId, userId: userId);
    });
  }

  Future<void> _loadChat({
    required String bandId,
    required String userId,
  }) async {
    setState(() {
      _currentBandId = bandId;
      _currentUserId = userId;
      _messages.clear();
      _loadError = null;
      _isLoadingMessages = true;
    });

    await _messageSubscription?.cancel();
    _messageSubscription = null;
    await _channel?.sink.close();
    _channel = null;

    try {
      final repo = ref.read(chatRepositoryProvider);
      final page = await repo.getMessages(
        bandId: bandId,
        currentUserId: userId,
      );

      if (!mounted || _currentBandId != bandId || _currentUserId != userId) {
        return;
      }

      setState(() {
        _messages
          ..clear()
          ..addAll(page.messages.reversed);
        _isLoadingMessages = false;
      });
      _scrollToBottom(jump: true);

      final channel = await repo.connectMessages(bandId);
      if (!mounted || _currentBandId != bandId || _currentUserId != userId) {
        await channel.sink.close();
        return;
      }

      _channel = channel;
      _messageSubscription = repo
          .messageStream(channel: channel, currentUserId: userId)
          .listen(
            _upsertMessage,
            onError: (_) {
              if (!mounted) return;
              setState(() => _loadError = '실시간 연결이 끊겼습니다.');
            },
          );
    } catch (e) {
      if (!mounted || _currentBandId != bandId || _currentUserId != userId) {
        return;
      }
      setState(() {
        _isLoadingMessages = false;
        _loadError = '$e';
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    final bandId = _currentBandId;
    final userId = _currentUserId;
    if (bandId == null || userId == null || _isSending) return;

    setState(() => _isSending = true);
    try {
      final sent = await ref
          .read(chatRepositoryProvider)
          .sendMessage(bandId: bandId, currentUserId: userId, text: text);
      _upsertMessage(sent);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('메시지 전송 실패: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _upsertMessage(ChatMessage message) {
    if (!mounted) return;

    setState(() {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index >= 0) {
        _messages[index] = message;
      } else {
        _messages.add(message);
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (jump) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bandAsync = ref.watch(selectedBandProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return bandAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('오류: $e'))),
      data: (selectedBand) => profileAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, st) =>
            Scaffold(body: Center(child: Text('프로필을 불러오지 못했습니다: $e'))),
        data: (profile) {
          _ensureChatStarted(bandId: selectedBand.id, userId: profile.id);

          return Scaffold(
            appBar: AppBar(
              title: Text('${selectedBand.name} 채팅방'),
              centerTitle: false,
            ),
            body: Column(
              children: [
                if (_loadError != null)
                  Material(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      dense: true,
                      title: Text(_loadError!),
                      trailing: TextButton(
                        onPressed: () => _loadChat(
                          bandId: selectedBand.id,
                          userId: profile.id,
                        ),
                        child: const Text('다시 시도'),
                      ),
                    ),
                  ),
                Expanded(child: _buildMessageList()),
                ChatInputBar(onSend: _isSending ? (_) {} : _sendMessage),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return const Center(child: Text('아직 메시지가 없습니다.'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final previousMessage = index > 0 ? _messages[index - 1] : null;
        final bubble = ChatBubble(message: message);

        if (!_shouldShowDateSeparator(message, previousMessage)) {
          return bubble;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DateSeparator(date: message.timestamp),
            bubble,
          ],
        );
      },
    );
  }

  bool _shouldShowDateSeparator(
    ChatMessage message,
    ChatMessage? previousMessage,
  ) {
    if (previousMessage == null) return true;
    final currentDate = DateUtils.dateOnly(message.timestamp);
    final previousDate = DateUtils.dateOnly(previousMessage.timestamp);
    return currentDate != previousDate;
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final dateString = '${date.year}년 ${date.month}월 ${date.day}일';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateString,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
        ],
      ),
    );
  }
}
