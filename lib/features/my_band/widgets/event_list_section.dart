import 'package:flutter/material.dart';
import '../models/band_models.dart';
import 'event_detail_dialog.dart';

class EventListSection extends StatelessWidget {
  final List<BandEvent> events;

  const EventListSection({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '일정 모아보기',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('등록된 일정이 없습니다.', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  onTap: () => EventDetailDialog.show(context, event),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${event.date.year}.${event.date.month.toString().padLeft(2, '0')}.${event.date.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEventColor(context, event.type).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _getEventColor(context, event.type).withOpacity(0.1)),
                    ),
                    child: Text(
                      event.type.label,
                      style: TextStyle(
                        color: _getEventColor(context, event.type),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getEventColor(BuildContext context, EventType type) {
    // B&W theme + point color
    switch (type) {
      case EventType.practice:
        return Theme.of(context).colorScheme.primary;
      case EventType.performance:
        return Theme.of(context).colorScheme.secondary;
      case EventType.other:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }
}
