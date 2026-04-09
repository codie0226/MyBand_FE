import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../my_band/models/band_models.dart';
import '../../my_band/providers/band_provider.dart';
import '../../../core/theme/app_theme.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  BandEvent? _selectedEvent;

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
    final band = ref.watch(selectedBandProvider);

    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!, band.events)
        : <BandEvent>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(band.name),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildCalendar(band),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _selectedDay == null
                  ? _buildNoSelection(context)
                  : _selectedEvent == null
                      ? _buildEventList(context, selectedEvents)
                      : _buildEventDetail(context, _selectedEvent!),
            ),
          ),
        ],
      ),
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
          _selectedEvent = null;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
          letterSpacing: -0.5,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primaryText),
        rightChevronIcon:
            Icon(Icons.chevron_right, color: AppColors.primaryText),
        headerPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.point, width: 1.5),
          ),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: AppColors.point,
          fontWeight: FontWeight.bold,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.point,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        markerDecoration: BoxDecoration(
          color: AppColors.point,
          shape: BoxShape.circle,
        ),
        markerSize: 5.0,
        markersMaxCount: 3,
        markersOffset: PositionedOffset(bottom: 4),
        defaultTextStyle:
            TextStyle(color: AppColors.primaryText, letterSpacing: -0.3),
        weekendTextStyle:
            TextStyle(color: AppColors.primaryText, letterSpacing: -0.3),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500),
        weekendStyle: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildNoSelection(BuildContext context) {
    return Center(
      key: const ValueKey('empty'),
      child: Text(
        '날짜를 선택하면 일정을 확인할 수 있어요',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context, List<BandEvent> events) {
    final day = _selectedDay!;
    final dateLabel = '${day.year}년 ${day.month}월 ${day.day}일';

    return Column(
      key: const ValueKey('list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            dateLabel,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 36,
                        color: AppColors.secondaryText.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '등록된 일정이 없습니다.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () =>
                            setState(() => _selectedEvent = event),
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          event.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                        trailing: _EventTypeBadge(type: event.type),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: 일정 추가 기능 구현 예정
              },
              icon: const Icon(Icons.add),
              label: const Text('새 일정 추가'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetail(BuildContext context, BandEvent event) {
    final hasSetlist = event.type == EventType.practice ||
        event.type == EventType.performance;

    return Column(
      key: const ValueKey('detail'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 헤더: 뒤로가기 + 제목
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedEvent = null),
              ),
              Text(
                '일정 상세',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        // 스크롤 가능한 상세 내용
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventTypeBadge(type: event.type, large: true),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.secondaryText),
                    const SizedBox(width: 6),
                    Text(
                      '${event.date.year}년 ${event.date.month}월 ${event.date.day}일',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '일정 내용',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(event.description),
                if (hasSetlist && event.setlist.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    '셋리스트',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: event.setlist.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 이벤트 타입 배지 위젯
class _EventTypeBadge extends StatelessWidget {
  final EventType type;
  final bool large;

  const _EventTypeBadge({required this.type, this.large = false});

  Color _color() {
    switch (type) {
      case EventType.practice:
        return AppColors.primary;
      case EventType.performance:
        return AppColors.point;
      case EventType.other:
        return AppColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 10,
        vertical: large ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: color,
          fontSize: large ? 13 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
