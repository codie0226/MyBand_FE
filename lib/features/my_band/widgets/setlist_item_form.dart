import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';

class SetlistItemFormData {
  final titleController = TextEditingController();
  final artistController = TextEditingController();
  final keyController = TextEditingController();
  final sheetMusicUrlController = TextEditingController();
  final List<TextEditingController> referenceControllers = [];

  void dispose() {
    titleController.dispose();
    artistController.dispose();
    keyController.dispose();
    sheetMusicUrlController.dispose();
    for (final c in referenceControllers) {
      c.dispose();
    }
  }

  SetlistItem toSetlistItem(int index) {
    return SetlistItem(
      id: 'new_s_${DateTime.now().millisecondsSinceEpoch}_$index',
      title: titleController.text.trim(),
      artist: artistController.text.trim(),
      key: keyController.text.trim().isEmpty
          ? null
          : keyController.text.trim(),
      sheetMusicUrl: sheetMusicUrlController.text.trim().isEmpty
          ? null
          : sheetMusicUrlController.text.trim(),
      references: referenceControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }
}

class SetlistItemForm extends StatefulWidget {
  final int index;
  final SetlistItemFormData data;
  final VoidCallback onDelete;

  const SetlistItemForm({
    super.key,
    required this.index,
    required this.data,
    required this.onDelete,
  });

  @override
  State<SetlistItemForm> createState() => _SetlistItemFormState();
}

class _SetlistItemFormState extends State<SetlistItemForm> {
  void _addReference() {
    setState(() {
      widget.data.referenceControllers.add(TextEditingController());
    });
  }

  void _removeReference(int index) {
    setState(() {
      widget.data.referenceControllers[index].dispose();
      widget.data.referenceControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '곡 ${widget.index + 1}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.secondaryText,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.data.artistController,
              decoration: const InputDecoration(
                labelText: '아티스트명',
                hintText: '예: 10cm',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '아티스트명을 입력해주세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.data.titleController,
              decoration: const InputDecoration(
                labelText: '곡 제목',
                hintText: '예: 스토커',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '곡 제목을 입력해주세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.data.keyController,
              decoration: const InputDecoration(
                labelText: '키 (조성)',
                hintText: '예: C Major, Am',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.data.sheetMusicUrlController,
              decoration: const InputDecoration(
                labelText: '악보 URL',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '레퍼런스',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 28,
                  width: 28,
                  child: IconButton(
                    onPressed: _addReference,
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
            if (widget.data.referenceControllers.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...widget.data.referenceControllers
                  .asMap()
                  .entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: entry.value,
                                decoration: InputDecoration(
                                  hintText: 'YouTube, Spotify 링크 등',
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  isDense: true,
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        _removeReference(entry.key),
                                    icon: const Icon(Icons.remove_circle_outline,
                                        size: 18),
                                    style: IconButton.styleFrom(
                                      foregroundColor: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.url,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      )),
            ],
          ],
        ),
      ),
    );
  }
}
