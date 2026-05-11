import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';

class SetlistItemFormData {
  final titleController = TextEditingController();
  final artistController = TextEditingController();
  final keyController = TextEditingController();
  final List<TextEditingController> referenceControllers = [];

  // 악보 파일 (선택 후 저장 시 업로드)
  PlatformFile? sheetMusicFile;
  // 업로드 완료 후 받은 URL (toSetlistItem에서 사용)
  String? uploadedSheetUrl;

  void dispose() {
    titleController.dispose();
    artistController.dispose();
    keyController.dispose();
    for (final c in referenceControllers) {
      c.dispose();
    }
  }

  SetlistItem toSetlistItem(int index) {
    return SetlistItem(
      id: 'new_s_${DateTime.now().millisecondsSinceEpoch}_$index',
      title: titleController.text.trim(),
      artist: artistController.text.trim(),
      key: keyController.text.trim().isEmpty ? null : keyController.text.trim(),
      sheetMusicUrl: uploadedSheetUrl,
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
    setState(() => widget.data.referenceControllers.add(TextEditingController()));
  }

  void _removeReference(int index) {
    setState(() {
      widget.data.referenceControllers[index].dispose();
      widget.data.referenceControllers.removeAt(index);
    });
  }

  Future<void> _pickSheetMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        widget.data.sheetMusicFile = result.files.first;
        widget.data.uploadedSheetUrl = null; // 새 파일 선택 시 기존 URL 초기화
      });
    }
  }

  void _removeSheetMusic() {
    setState(() {
      widget.data.sheetMusicFile = null;
      widget.data.uploadedSheetUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetFile = widget.data.sheetMusicFile;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Text('곡 ${widget.index + 1}', style: theme.textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.body,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 아티스트
            TextFormField(
              controller: widget.data.artistController,
              decoration: const InputDecoration(labelText: '아티스트명', hintText: '예: 10cm'),
              validator: (v) => v == null || v.trim().isEmpty ? '아티스트명을 입력해주세요' : null,
            ),
            const SizedBox(height: 12),

            // 곡 제목
            TextFormField(
              controller: widget.data.titleController,
              decoration: const InputDecoration(labelText: '곡 제목', hintText: '예: 스토커'),
              validator: (v) => v == null || v.trim().isEmpty ? '곡 제목을 입력해주세요' : null,
            ),
            const SizedBox(height: 12),

            // 키 (조성)
            TextFormField(
              controller: widget.data.keyController,
              decoration: const InputDecoration(labelText: '키 (조성)', hintText: '예: C Major, Am'),
            ),
            const SizedBox(height: 16),

            // 악보 파일 업로드
            Text(
              '악보 파일',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (sheetFile != null)
              _SheetFileChip(
                filename: sheetFile.name,
                fileSize: sheetFile.size,
                onRemove: _removeSheetMusic,
              )
            else
              _SheetFilePickerButton(onTap: _pickSheetMusic),

            // 레퍼런스
            const SizedBox(height: 16),
            Row(
              children: [
                Text('레퍼런스', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                SizedBox(
                  height: 28,
                  width: 28,
                  child: IconButton(
                    onPressed: _addReference,
                    icon: const Icon(Icons.add, size: 14),
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
            if (widget.data.referenceControllers.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...widget.data.referenceControllers.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        hintText: 'YouTube, Spotify 링크 등',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                        suffixIcon: IconButton(
                          onPressed: () => _removeReference(entry.key),
                          icon: const Icon(Icons.remove_circle_outline, size: 18),
                          style: IconButton.styleFrom(foregroundColor: AppColors.body),
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      style: theme.textTheme.bodySmall,
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── 파일 선택 버튼 ────────────────────────────────────────────────────────────

class _SheetFilePickerButton extends StatelessWidget {
  const _SheetFilePickerButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.canvasSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.hairlineStrong),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file_outlined, size: 18, color: AppColors.body),
            const SizedBox(width: 8),
            Text(
              '악보 파일 선택 (PDF, 이미지)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.body,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 선택된 파일 칩 ───────────────────────────────────────────────────────────

class _SheetFileChip extends StatelessWidget {
  const _SheetFileChip({
    required this.filename,
    required this.fileSize,
    required this.onRemove,
  });

  final String filename;
  final int fileSize;
  final VoidCallback onRemove;

  String get _sizeLabel {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairlineStrong),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 18, color: AppColors.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _sizeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 18, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
