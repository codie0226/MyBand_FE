import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../my_band/models/band_models.dart';
import '../../my_band/providers/band_provider.dart';
import '../../../core/theme/app_theme.dart';

// ─── CalendarScreen ──────────────────────────────────────────────────────────

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<BandEvent> _getEventsForDay(DateTime day, List<BandEvent> allEvents) {
    return allEvents
        .where((e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bandAsync = ref.watch(selectedBandProvider);

    return bandAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text('불러오기 실패: $e'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(selectedBandProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (band) {
        final selectedEvents = _selectedDay != null
            ? _getEventsForDay(_selectedDay!, band.events)
            : <BandEvent>[];

        return Scaffold(
          appBar: AppBar(title: Text(band.name), centerTitle: false),
          body: Column(
            children: [
              _buildCalendar(band),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: _selectedDay == null
                    ? _buildNoSelection(context)
                    : _buildEventList(context, selectedEvents),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendar(Band band) {
    return TableCalendar<BandEvent>(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2027, 12, 31),
      focusedDay: _focusedDay,
      locale: 'ko_KR',
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) => _getEventsForDay(day, band.events),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.5,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.ink),
        rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.ink),
        headerPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(color: AppColors.ink, width: 1.5)),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
        selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        selectedTextStyle: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
        markerDecoration: BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
        markerSize: 5.0,
        markersMaxCount: 3,
        markersOffset: PositionedOffset(bottom: 4),
        defaultTextStyle: TextStyle(color: AppColors.ink, letterSpacing: -0.3),
        weekendTextStyle: TextStyle(color: AppColors.ink, letterSpacing: -0.3),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: AppColors.body, fontSize: 12, fontWeight: FontWeight.w500),
        weekendStyle: TextStyle(color: AppColors.body, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildNoSelection(BuildContext context) {
    return Center(
      child: Text(
        '날짜를 선택하면 일정을 확인할 수 있어요',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.body),
      ),
    );
  }

  Widget _buildEventList(BuildContext context, List<BandEvent> events) {
    final day = _selectedDay!;
    final dateLabel = '${day.year}년 ${day.month}월 ${day.day}일';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_busy_outlined, size: 36, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text(
                        '등록된 일정이 없습니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.body),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () => _openEventDetail(context, event),
                        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          event.description ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: EventTypeBadge(type: event.type),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {
                final dateStr = _selectedDay!.toIso8601String().split('T').first;
                context.push('/add_event?date=$dateStr');
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('새 일정 추가'),
            ),
          ),
        ),
      ],
    );
  }

  void _openEventDetail(BuildContext context, BandEvent event) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => EventDetailPage(event: event),
        transitionsBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// ─── EventDetailPage ─────────────────────────────────────────────────────────

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.event});

  final BandEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSetlist =
        event.type == EventType.practice || event.type == EventType.performance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 상세'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타입 배지 + 날짜
            Row(
              children: [
                EventTypeBadge(type: event.type, large: true),
                const SizedBox(width: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.body),
                    const SizedBox(width: 6),
                    Text(
                      '${event.date.year}년 ${event.date.month}월 ${event.date.day}일',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 제목
            Text(
              event.title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),

            // 설명
            if (event.description?.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.canvasSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hairlineStrong),
                ),
                child: Text(
                  event.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.body,
                    height: 1.7,
                  ),
                ),
              ),
            ],

            // 셋리스트
            if (hasSetlist && event.setlist.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Text('셋리스트', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '${event.setlist.length}곡',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.body,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...event.setlist.asMap().entries.map((entry) {
                return _SetlistRow(index: entry.key, item: entry.value);
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── SetlistRow ───────────────────────────────────────────────────────────────

class _SetlistRow extends StatelessWidget {
  const _SetlistRow({required this.index, required this.item});

  final int index;
  final SetlistItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairlineStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 번호 뱃지
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceStrong,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(item.artist, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (item.key != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.hairlineStrong),
                  ),
                  child: Text(
                    item.key!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (item.sheetMusicUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 36),
                const Icon(Icons.description_outlined, size: 13, color: AppColors.muted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.sheetMusicUrl!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (item.references.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...item.references.map((ref) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      const SizedBox(width: 36),
                      const Icon(Icons.link, size: 13, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ref,
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ─── EventTypeBadge ───────────────────────────────────────────────────────────

class EventTypeBadge extends StatelessWidget {
  const EventTypeBadge({super.key, required this.type, this.large = false});

  final EventType type;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 10,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.hairlineStrong),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: AppColors.ink,
          fontSize: large ? 13 : 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
