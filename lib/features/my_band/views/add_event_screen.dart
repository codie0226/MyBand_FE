import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';
import '../data/event_repository.dart';
import '../providers/band_provider.dart';
import '../widgets/setlist_item_form.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final DateTime? preselectedDate;

  const AddEventScreen({super.key, this.preselectedDate});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  EventType _selectedType = EventType.practice;
  final List<SetlistItemFormData> _setlistItems = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preselectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final item in _setlistItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addSetlistItem() {
    setState(() {
      _setlistItems.add(SetlistItemFormData());
    });
  }

  void _removeSetlistItem(int index) {
    setState(() {
      _setlistItems[index].dispose();
      _setlistItems.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.point,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('날짜를 선택해주세요')),
      );
      return;
    }

    final setlist = _selectedType != EventType.other
        ? _setlistItems
            .asMap()
            .entries
            .map((e) => e.value.toSetlistItem(e.key))
            .where((item) => item.title.isNotEmpty && item.artist.isNotEmpty)
            .toList()
        : <SetlistItem>[];

    final newEvent = BandEvent(
      id: '',
      title: _titleController.text.trim(),
      date: _selectedDate!,
      type: _selectedType,
      description: _descriptionController.text.trim(),
      setlist: setlist,
    );

    try {
      final band = await ref.read(selectedBandProvider.future);
      await ref.read(eventRepositoryProvider).createEvent(band.id, newEvent);
      ref.invalidate(selectedBandProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('일정 저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 추가'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: Text(
              '저장',
              style: TextStyle(
                color: AppColors.point,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateField(theme),
              const SizedBox(height: 20),
              _buildEventTypeSelector(theme),
              const SizedBox(height: 20),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              if (_selectedType != EventType.other) ...[
                const SizedBox(height: 24),
                _buildSetlistSection(theme),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일정 날짜',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: _selectedDate != null
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                      : '날짜를 선택하세요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _selectedDate != null
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일정 종류',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<EventType>(
            segments: EventType.values.map((type) {
              return ButtonSegment<EventType>(
                value: type,
                label: Text(type.label),
              );
            }).toList(),
            selected: {_selectedType},
            onSelectionChanged: (selected) {
              setState(() => _selectedType = selected.first);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.background;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppColors.primaryText;
              }),
              side: WidgetStateProperty.all(
                const BorderSide(color: AppColors.border),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '일정 제목',
        hintText: '예: 정기 합주, 클럽 공연',
        border: OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? '제목을 입력해주세요' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '일정 내용',
        hintText: '일정에 대한 상세 내용을 입력하세요',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
    );
  }

  Widget _buildSetlistSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '셋리스트',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 28,
              width: 28,
              child: IconButton(
                onPressed: _addSetlistItem,
                icon: const Icon(Icons.add, size: 16),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: const CircleBorder(
                    side: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_setlistItems.isEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.music_note_outlined,
                    size: 28,
                    color: AppColors.secondaryText.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(
                  '+ 버튼을 눌러 곡을 추가하세요',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          ..._setlistItems.asMap().entries.map((entry) {
            return SetlistItemForm(
              key: ValueKey(entry.value),
              index: entry.key,
              data: entry.value,
              onDelete: () => _removeSetlistItem(entry.key),
            );
          }),
        ],
      ],
    );
  }
}
