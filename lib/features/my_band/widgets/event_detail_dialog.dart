import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/event_repository.dart';
import '../models/band_models.dart';
import 'setlist_item_card.dart';
import 'sheet_music_gallery.dart';

class EventDetailDialog extends ConsumerStatefulWidget {
  final BandEvent event;
  final String bandId;
  final bool canDelete;
  final VoidCallback? onChanged;

  const EventDetailDialog({
    super.key,
    required this.event,
    required this.bandId,
    required this.canDelete,
    this.onChanged,
  });

  static void show(
    BuildContext context, {
    required BandEvent event,
    required String bandId,
    required bool canDelete,
    VoidCallback? onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EventDetailDialog(
          event: event,
          bandId: bandId,
          canDelete: canDelete,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  ConsumerState<EventDetailDialog> createState() => _EventDetailDialogState();
}

class _EventDetailDialogState extends ConsumerState<EventDetailDialog> {
  bool _isDeleting = false;

  Future<void> _deleteEvent() async {
    if (!widget.canDelete || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.semanticError),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await ref
          .read(eventRepositoryProvider)
          .deleteEvent(widget.bandId, widget.event.id);
      widget.onChanged?.call();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('일정을 삭제했습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('일정 삭제 실패: $e')));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSetlist =
        widget.event.type == EventType.practice ||
        widget.event.type == EventType.performance;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: AppColors.hairlineStrong),
                    ),
                    child: Text(
                      widget.event.type.label,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.canDelete)
                        IconButton(
                          tooltip: '삭제',
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.semanticError,
                                ),
                          onPressed: _isDeleting ? null : _deleteEvent,
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.event.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.body,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.event.date.year}년 ${widget.event.date.month}월 ${widget.event.date.day}일',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('일정 내용', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                widget.event.description ?? '',
                style: theme.textTheme.bodyMedium,
              ),
              if (hasSetlist && widget.event.setlist.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('셋리스트', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.canvasSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.hairlineStrong),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.event.setlist.asMap().entries.map((entry) {
                      return SetlistItemCard(
                        index: entry.key,
                        item: entry.value,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                SheetMusicGallery(setlist: widget.event.setlist),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
