import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../my_band/providers/band_provider.dart';
import '../../profile/data/user_repository.dart';
import '../../profile/providers/user_provider.dart';

enum _BandEntryMode { inviteCode, createBand }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _instrumentController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _bandNameController = TextEditingController();
  final _bandGenreController = TextEditingController();
  final _bandDescriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  _BandEntryMode _mode = _BandEntryMode.inviteCode;
  XFile? _bandIconFile;
  bool _isSaving = false;

  static const _instrumentOptions = [
    '보컬',
    '기타',
    '베이스',
    '드럼',
    '키보드',
    '피아노',
    '바이올린',
    '색소폰',
    '프로듀서',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _instrumentController.dispose();
    _inviteCodeController.dispose();
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
      final repo = ref.read(userRepositoryProvider);
      String? iconUrl;
      final icon = _bandIconFile;
      if (_mode == _BandEntryMode.createBand && icon != null) {
        iconUrl = await repo.uploadImage(
          bytes: await icon.readAsBytes(),
          filename: icon.name,
        );
      }

      await ref
          .read(userProfileProvider.notifier)
          .completeOnboarding(
            nickname: _nicknameController.text.trim(),
            instrument: _instrumentController.text.trim(),
            inviteCode: _mode == _BandEntryMode.inviteCode
                ? _inviteCodeController.text.trim()
                : null,
            band: _mode == _BandEntryMode.createBand
                ? OnboardingBandInput(
                    name: _bandNameController.text.trim(),
                    genre: _bandGenreController.text.trim(),
                    description: _bandDescriptionController.text.trim(),
                    iconUrl: iconUrl,
                  )
                : null,
          );

      ref.invalidate(bandsProvider);
      if (mounted) context.go('/my_band');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('가입 설정 저장 실패: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('시작 설정'),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('프로필을 불러오지 못했습니다: $e')),
        data: (profile) {
          if (_nicknameController.text.isEmpty) {
            _nicknameController.text = profile.nickname ?? profile.name;
          }
          if (_instrumentController.text.isEmpty &&
              profile.instrument?.isNotEmpty == true) {
            _instrumentController.text = profile.instrument!;
          }

          return SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Text(
                    '밴드에서 사용할 정보를 먼저 정해볼게요.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel('닉네임'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nicknameController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration('예: 홍길동, 베이스길동'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? '닉네임을 입력해주세요.'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('악기 / 파트'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _instrumentOptions.map(_instrumentChip).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _instrumentController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration('목록에 없으면 직접 입력'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? '악기 또는 파트를 입력해주세요.'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  SegmentedButton<_BandEntryMode>(
                    segments: const [
                      ButtonSegment(
                        value: _BandEntryMode.inviteCode,
                        label: Text('초대 코드'),
                        icon: Icon(Icons.key),
                      ),
                      ButtonSegment(
                        value: _BandEntryMode.createBand,
                        label: Text('밴드 생성'),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (selected) {
                      setState(() => _mode = selected.first);
                    },
                  ),
                  const SizedBox(height: 18),
                  if (_mode == _BandEntryMode.inviteCode)
                    _buildInviteCodeFields()
                  else
                    _buildCreateBandFields(),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.point,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('MyBand 시작하기'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _instrumentChip(String label) {
    final selected = _instrumentController.text.trim() == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _instrumentController.text = label);
      },
      selectedColor: AppColors.point,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.border),
    );
  }

  Widget _buildInviteCodeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('밴드 초대 코드'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _inviteCodeController,
          textCapitalization: TextCapitalization.characters,
          decoration: _inputDecoration('예: AB12CD34'),
          validator: (value) {
            if (_mode != _BandEntryMode.inviteCode) return null;
            return value == null || value.trim().isEmpty
                ? '초대 코드를 입력하거나 밴드를 생성해주세요.'
                : null;
          },
        ),
      ],
    );
  }

  Widget _buildCreateBandFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('새 밴드 정보'),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickBandIcon,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _bandIconFile == null
                ? const Icon(Icons.add_photo_alternate_outlined, size: 30)
                : const Icon(Icons.image, size: 30, color: AppColors.point),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _bandNameController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration('밴드명'),
          validator: (value) {
            if (_mode != _BandEntryMode.createBand) return null;
            return value == null || value.trim().isEmpty
                ? '밴드명을 입력해주세요.'
                : null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bandGenreController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration('장르 예: 인디 록, 재즈, 팝'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bandDescriptionController,
          minLines: 3,
          maxLines: 5,
          decoration: _inputDecoration('밴드 설명'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.point, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
