import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/models/auth_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instrumentController = TextEditingController();
  bool _isSaving = false;
  bool _isEditing = false;

  static const _instrumentOptions = [
    'Vocal',
    'Guitar',
    'Bass',
    'Drum',
    'Keyboard',
    'Violin',
    '기타',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _instrumentController.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfile profile) {
    if (_nameController.text.isEmpty) {
      _nameController.text = profile.name;
    }
    if (_instrumentController.text.isEmpty) {
      _instrumentController.text = profile.instrument ?? '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(userProfileProvider.notifier).saveProfile(
            name: _nameController.text.trim(),
            instrument: _instrumentController.text.trim(),
          );
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleLogout() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '로그아웃',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(authProvider.notifier).signOut();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    // 프로필 로드 완료 시 컨트롤러에 값 세팅
    profileAsync.whenData(_populateControllers);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '프로필 변경' : '프로필'),
        centerTitle: false,
        leading: _isEditing
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    final profile = ref.read(userProfileProvider).value;
                    if (profile != null) {
                      _nameController.text = profile.name;
                      _instrumentController.text = profile.instrument ?? '';
                    }
                  });
                },
              )
            : null,
        actions: [
          if (_isEditing)
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text(
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
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text('불러오기 실패: $e'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(userProfileProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (profile) => _buildContent(profile),
      ),
    );
  }

  Widget _buildContent(UserProfile profile) {
    if (_isEditing) {
      return _buildEditForm(profile);
    }
    return _buildReadOnlyProfile(profile);
  }

  Widget _buildReadOnlyProfile(UserProfile profile) {
    final theme = Theme.of(context);
    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.point.withValues(alpha: 0.1),
            backgroundImage: profile.profileImageUrl != null
                ? NetworkImage(profile.profileImageUrl!)
                : null,
            child: profile.profileImageUrl == null
                ? Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.point,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 24),
          Text(
            profile.name,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            profile.instrument?.isNotEmpty == true ? profile.instrument! : '포지션 미정',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.point,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.point,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('프로필 변경', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('로그아웃'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryText,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEditForm(UserProfile profile) {
    final theme = Theme.of(context);
    final initial = profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : '?';

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 헤더: 아바타 + 이름 + 이메일 ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 36, horizontal: 24),
              color: AppColors.surface,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        AppColors.point.withValues(alpha: 0.1),
                    backgroundImage: profile.profileImageUrl != null
                        ? NetworkImage(profile.profileImageUrl!)
                        : null,
                    child: profile.profileImageUrl == null
                        ? Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.point,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // ── 편집 폼 ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임
                  Text(
                    '닉네임',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('닉네임을 입력하세요'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? '닉네임을 입력해주세요'
                            : null,
                  ),

                  const SizedBox(height: 24),

                  // 밴드 파트
                  Text(
                    '밴드 파트',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _instrumentController,
                    decoration: _inputDecoration('예: Guitar, Vocal'),
                  ),
                  const SizedBox(height: 10),

                  // 빠른 선택 Chip
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _instrumentOptions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final label = _instrumentOptions[index];
                        final isSelected = _instrumentController
                                .text
                                .trim() ==
                            label;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _instrumentController.text = label;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.point
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.point
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondaryText),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
