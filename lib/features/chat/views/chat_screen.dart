import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/network/attachment_repository.dart';
import '../../calendar/views/calendar_screen.dart';
import '../../my_band/models/band_models.dart';
import '../../profile/providers/user_provider.dart';
import '../data/chat_repository.dart';
import '../models/chat_event_announcement.dart';
import '../models/chat_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String bandId;
  final String bandName;

  const ChatScreen({super.key, required this.bandId, required this.bandName});

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
  bool _isUploading = false;
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

  Future<void> _sendAttachment(ChatAttachment attachment) async {
    final bandId = _currentBandId;
    final userId = _currentUserId;
    if (bandId == null || userId == null || _isSending) return;

    setState(() => _isSending = true);
    try {
      final sent = await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            bandId: bandId,
            currentUserId: userId,
            attachments: [attachment],
          );
      _upsertMessage(sent);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('첨부 전송 실패: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickImage() async {
    if (_isUploading) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (picked == null) return;

    await _uploadAndSend(
      bytes: await picked.readAsBytes(),
      filename: picked.name,
      uploadType: AttachmentUploadType.image,
      attachmentType: ChatAttachmentType.image,
    );
  }

  Future<void> _pickPdf() async {
    if (_isUploading) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return;

    await _uploadAndSend(
      bytes: bytes,
      filename: file.name,
      uploadType: AttachmentUploadType.file,
      attachmentType: ChatAttachmentType.pdf,
    );
  }

  Future<void> _uploadAndSend({
    required List<int> bytes,
    required String filename,
    required AttachmentUploadType uploadType,
    required ChatAttachmentType attachmentType,
  }) async {
    setState(() => _isUploading = true);
    try {
      final url = await ref
          .read(attachmentRepositoryProvider)
          .upload(bytes: bytes, filename: filename, type: uploadType);
      await _sendAttachment(
        ChatAttachment(type: attachmentType, url: url, filename: filename),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
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

  Future<void> _openEventAnnouncement(
    ChatEventAnnouncement announcement,
  ) async {
    final currentUserId = _currentUserId;
    try {
      ref.invalidate(allBandEventsProvider);
      final entries = await ref.read(allBandEventsProvider.future);
      CalendarBandEvent? target;
      for (final entry in entries) {
        if (entry.band.id == widget.bandId &&
            entry.event.id == announcement.eventId) {
          target = entry;
          break;
        }
      }

      if (!mounted) return;
      if (target == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일정을 찾을 수 없습니다.')),
        );
        return;
      }
      final targetEntry = target;

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => EventDetailPage(
            bandId: targetEntry.band.id,
            event: targetEntry.event,
            canEdit: _canEditEventFromChat(targetEntry, currentUserId),
            canDelete: _isOwnerFromChat(targetEntry.band, currentUserId),
          ),
          transitionsBuilder: (context, animation, _, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('일정 상세를 열 수 없습니다: $e')));
    }
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
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          Scaffold(body: Center(child: Text('프로필을 불러오지 못했습니다. $e'))),
      data: (profile) {
        _ensureChatStarted(bandId: widget.bandId, userId: profile.id);

        return Scaffold(
          appBar: AppBar(title: Text(widget.bandName), centerTitle: false),
          body: Column(
            children: [
              if (_loadError != null)
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    dense: true,
                    title: Text(_loadError!),
                    trailing: TextButton(
                      onPressed: () =>
                          _loadChat(bandId: widget.bandId, userId: profile.id),
                      child: const Text('다시 시도'),
                    ),
                  ),
                ),
              Expanded(child: _buildMessageList()),
              if (_isUploading) const LinearProgressIndicator(minHeight: 2),
              ChatInputBar(
                onSend: _isSending ? (_) {} : _sendMessage,
                onPickImage: _pickImage,
                onPickPdf: _pickPdf,
              ),
            ],
          ),
        );
      },
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
        final bubble = ChatBubble(
          message: message,
          onOpenEvent: _openEventAnnouncement,
        );

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

bool _isOwnerFromChat(Band band, String? currentUserId) {
  if (currentUserId == null) return false;
  return band.members.any(
    (member) =>
        member.id == currentUserId && member.role == BandMemberRole.owner,
  );
}

bool _canEditEventFromChat(CalendarBandEvent entry, String? currentUserId) {
  if (currentUserId == null) return false;
  return _isOwnerFromChat(entry.band, currentUserId) ||
      entry.event.creatorId == currentUserId;
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
