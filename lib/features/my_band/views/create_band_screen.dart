import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/attachment_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../data/band_repository.dart';
import '../models/band_models.dart';
import '../providers/band_provider.dart';

class CreateBandScreen extends ConsumerStatefulWidget {
  final Band? band;

  const CreateBandScreen({super.key, this.band});

  @override
  ConsumerState<CreateBandScreen> createState() => _CreateBandScreenState();
}

class _CreateBandScreenState extends ConsumerState<CreateBandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bandNameController = TextEditingController();
  final _bandGenreController = TextEditingController();
  final _bandDescriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  XFile? _bandIconFile;
  bool _isSaving = false;
  bool get _isEditing => widget.band != null;

  @override
  void initState() {
    super.initState();
    final band = widget.band;
    if (band != null) {
      _bandNameController.text = band.name;
      _bandGenreController.text = band.genre ?? '';
      _bandDescriptionController.text = band.description ?? '';
    }
  }

  @override
  void dispose() {
    _bandNameController.dispose();
    _bandGenreController.dispose();
    _bandDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickBandIcon() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 86,
    );
    if (picked == null || !mounted) return;
    setState(() => _bandIconFile = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      String? iconUrl;
      final icon = _bandIconFile;
      if (icon != null) {
        iconUrl = await ref
            .read(attachmentRepositoryProvider)
            .upload(
              bytes: await icon.readAsBytes(),
              filename: icon.name,
              type: AttachmentUploadType.image,
            );
      }

      final repo = ref.read(bandRepositoryProvider);
      final saved = _isEditing
          ? await repo.updateBand(
              bandId: widget.band!.id,
              name: _bandNameController.text.trim(),
              genre: _bandGenreController.text.trim(),
              description: _bandDescriptionController.text.trim(),
              iconUrl: iconUrl ?? widget.band!.iconUrl,
            )
          : await repo.createBand(
              name: _bandNameController.text.trim(),
              genre: _bandGenreController.text.trim(),
              description: _bandDescriptionController.text.trim(),
              iconUrl: iconUrl,
            );

      ref.invalidate(bandsProvider);
      ref.read(selectedBandIdProvider.notifier).select(saved.id);
      ref.invalidate(selectedBandProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? '${saved.name} 밴드 정보를 수정했습니다.'
                : '${saved.name} 밴드를 만들었습니다.',
          ),
        ),
      );
      context.go('/my_band');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? '밴드 수정 실패: $e' : '밴드 생성 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '밴드 정보 수정' : '새 밴드 생성'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Text(
                _isEditing ? '밴드 정보를 새롭게 정리해주세요.' : '함께 연주할 밴드 정보를 입력해주세요.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 28),
              const _SectionLabel('새 밴드 정보'),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _pickBandIcon,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.hairlineStrong),
                  ),
                  child: _bandIconFile == null
                      ? Icon(
                          _isEditing && widget.band?.iconUrl != null
                              ? Icons.image
                              : Icons.add_photo_alternate_outlined,
                          size: 28,
                          color: AppColors.muted,
                        )
                      : const Icon(Icons.image, size: 28, color: AppColors.ink),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bandNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: '밴드명'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? '밴드명을 입력해주세요.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bandGenreController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: '장르 예: 인디 록, 재즈, 팝',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bandDescriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(hintText: '밴드 설명'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(_isEditing ? '수정 완료' : '밴드 만들기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}
