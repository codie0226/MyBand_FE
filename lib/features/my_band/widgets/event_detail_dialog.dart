import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';
import 'setlist_item_card.dart';

class EventDetailDialog extends StatelessWidget {
  final BandEvent event;

  const EventDetailDialog({super.key, required this.event});

  static void show(BuildContext context, BandEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EventDetailDialog(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasSetlist =
        event.type == EventType.practice || event.type == EventType.performance;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceStrong,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.hairlineStrong),
                ),
                child: Text(
                  event.type.label,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.body),
              const SizedBox(width: 8),
              Text(
                '${event.date.year}년 ${event.date.month}월 ${event.date.day}일',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('일정 내용', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(event.description ?? '', style: theme.textTheme.bodyMedium),
          if (hasSetlist && event.setlist.isNotEmpty) ...[
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
                children: event.setlist.asMap().entries.map((entry) {
                  return SetlistItemCard(index: entry.key, item: entry.value);
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
