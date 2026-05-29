import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';
import 'event_detail_dialog.dart';

class EventListSection extends StatelessWidget {
  final String bandId;
  final List<BandEvent> events;
  final bool canDeleteEvents;
  final VoidCallback? onChanged;

  const EventListSection({
    super.key,
    required this.bandId,
    required this.events,
    required this.canDeleteEvents,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('일정 모아보기', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(
                height: 32,
                width: 32,
                child: IconButton(
                  onPressed: () => context.push('/add_event'),
                  icon: const Icon(Icons.add, size: 18),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceStrong,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.hairlineStrong),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '등록된 일정이 없습니다.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: events.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final event = events[index];
              final typeLabel = event.type.label;
              return Card(
                child: ListTile(
                  onTap: () => EventDetailDialog.show(
                    context,
                    event: event,
                    bandId: bandId,
                    canDelete: canDeleteEvents,
                    onChanged: onChanged,
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${event.date.year}.${event.date.month.toString().padLeft(2, '0')}.${event.date.day.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: AppColors.hairlineStrong),
                    ),
                    child: Text(
                      typeLabel,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
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
}
