import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/authenticated_image.dart';
import '../../auth/models/auth_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../my_band/data/band_repository.dart';
import '../../my_band/providers/band_provider.dart';
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
  final _inviteCodeController = TextEditingController();
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isJoiningBand = false;

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
    _inviteCodeController.dispose();
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
      await ref
          .read(userProfileProvider.notifier)
          .saveProfile(
            name: _nameController.text.trim(),
            instrument: _instrumentController.text.trim(),
          );
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('저장되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
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
                color: AppColors.semanticError,
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

  Future<void> _joinBandByInviteCode() async {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty || _isJoiningBand) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('초대 코드를 입력해주세요.')));
      return;
    }

    setState(() => _isJoiningBand = true);
    try {
      final band = await ref
          .read(bandRepositoryProvider)
          .joinByInviteCode(inviteCode);
      _inviteCodeController.clear();
      ref.invalidate(bandsProvider);
      ref.read(selectedBandIdProvider.notifier).select(band.id);
      ref.invalidate(selectedBandProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${band.name} 밴드에 가입했습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('밴드 가입 실패: $e')));
    } finally {
      if (mounted) setState(() => _isJoiningBand = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

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
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
    if (_isEditing) return _buildEditForm(profile);
    return _buildReadOnlyProfile(profile);
  }

  Widget _buildReadOnlyProfile(UserProfile profile) {
    final theme = Theme.of(context);
    final initial = profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : '?';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Column(
            children: [
              AuthenticatedAvatar(
                radius: 60,
                imageUrl: profile.profileImageUrl,
                backgroundColor: AppColors.surfaceStrong,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                profile.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              if (profile.instrument?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    profile.instrument!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Text('포지션 미정', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 36),
          _buildInviteCodeJoinSection(theme),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('프로필 변경'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/create_band'),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('새 밴드 생성'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('로그아웃'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInviteCodeJoinSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvasSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairlineStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('다른 밴드 가입', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          TextField(
            controller: _inviteCodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: '초대 코드'),
            onSubmitted: (_) => _joinBandByInviteCode(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _isJoiningBand ? null : _joinBandByInviteCode,
              icon: _isJoiningBand
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.group_add_outlined, size: 16),
              label: const Text('초대 코드로 가입'),
            ),
          ),
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
            // 헤더: 아바타 + 이름 + 이메일
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              color: AppColors.canvasSoft,
              child: Column(
                children: [
                  AuthenticatedAvatar(
                    radius: 48,
                    imageUrl: profile.profileImageUrl,
                    backgroundColor: AppColors.surfaceStrong,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(profile.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(profile.email, style: theme.textTheme.bodySmall),
                ],
              ),
            ),

            // 편집 폼
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('닉네임', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: '닉네임을 입력하세요'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '닉네임을 입력해주세요' : null,
                  ),
                  const SizedBox(height: 24),
                  Text('밴드 파트', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _instrumentController,
                    decoration: const InputDecoration(
                      hintText: '예: Guitar, Vocal',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _instrumentOptions.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final label = _instrumentOptions[index];
                        final isSelected =
                            _instrumentController.text.trim() == label;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _instrumentController.text = label,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceStrong,
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.hairlineStrong,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.onPrimary
                                    : AppColors.body,
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
}
