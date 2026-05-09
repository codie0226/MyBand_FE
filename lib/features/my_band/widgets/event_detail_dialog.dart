import 'package:flutter/material.dart';
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EventDetailDialog(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSetlist = event.type == EventType.practice || event.type == EventType.performance;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(event.type.label),
                backgroundColor: _getEventColor(event.type).withOpacity(0.1),
                labelStyle: TextStyle(
                  color: _getEventColor(event.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${event.date.year}년 ${event.date.month}월 ${event.date.day}일',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '일정 내용',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(event.description ?? ''),
          if (hasSetlist && event.setlist.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '셋리스트',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: event.setlist.asMap().entries.map((entry) {
                  return SetlistItemCard(
                      index: entry.key, item: entry.value);
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.practice:
        return Colors.blue;
      case EventType.performance:
        return Colors.red;
      case EventType.other:
        return Colors.green;
    }
  }
}
