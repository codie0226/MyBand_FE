import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/file_downloader.dart';
import '../../../core/widgets/authenticated_image.dart';
import '../models/chat_event_announcement.dart';
import '../models/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueChanged<ChatEventAnnouncement>? onOpenEvent;

  const ChatBubble({super.key, required this.message, this.onOpenEvent});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final theme = Theme.of(context);

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
                Flexible(child: _buildBubble(context)),
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
                    Flexible(child: _buildBubble(context)),
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
    final announcement = message.eventAnnouncement;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (announcement != null)
            _EventAnnouncementCard(
              announcement: announcement,
              isMe: isMe,
              onTap: onOpenEvent == null
                  ? null
                  : () => onOpenEvent!(announcement),
            )
          else if (message.text.isNotEmpty)
            Text(
              message.text,
              style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onSecondary
                    : theme.colorScheme.onSurface,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          for (final attachment in message.attachments) ...[
            if (message.text.isNotEmpty ||
                attachment != message.attachments.first)
              const SizedBox(height: 8),
            _AttachmentPreview(attachment: attachment, isMe: isMe),
          ],
        ],
      ),
    );
  }

  Widget _buildTime(BuildContext context, String time) {
    return Text(
      time,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
    );
  }
}

class _EventAnnouncementCard extends StatelessWidget {
  const _EventAnnouncementCard({
    required this.announcement,
    required this.isMe,
    required this.onTap,
  });

  final ChatEventAnnouncement announcement;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(
      announcement.date,
    );
    final description = announcement.description.isEmpty
        ? '내용 없음'
        : announcement.description;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.white : AppColors.canvasSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.72)
                  : AppColors.hairlineStrong,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 18,
                    color: isMe ? AppColors.ink : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '새 일정',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                announcement.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.body,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.body,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _EventChip(label: announcement.typeLabel),
                  if (announcement.setlistCount > 0)
                    _EventChip(label: '${announcement.setlistCount}곡'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.body,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final ChatAttachment attachment;
  final bool isMe;

  const _AttachmentPreview({required this.attachment, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (attachment.type == ChatAttachmentType.image) {
      return InkWell(
        onTap: () => _openImagePreview(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AuthenticatedImage(
            url: attachment.url,
            width: 180,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox(
              width: 180,
              height: 96,
              child: Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () =>
          downloadFile(attachment.url, filename: attachment.filename),
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
      label: Text(attachment.filename, overflow: TextOverflow.ellipsis),
    );
  }

  void _openImagePreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ImagePreviewPage(attachment: attachment),
      ),
    );
  }
}

class _ImagePreviewPage extends StatelessWidget {
  final ChatAttachment attachment;

  const _ImagePreviewPage({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: _PreviewFilenameLabel(filename: attachment.filename),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () =>
                  downloadFile(attachment.url, filename: attachment.filename),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('다운로드'),
            ),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: AuthenticatedImage(
            url: attachment.url,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewFilenameLabel extends StatelessWidget {
  const _PreviewFilenameLabel({required this.filename});

  final String filename;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        filename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
