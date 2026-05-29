import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../profile/providers/user_provider.dart';
import '../data/band_member_repository.dart';
import '../providers/band_provider.dart';
import '../models/band_models.dart';
import '../widgets/empty_band_actions.dart';
import '../widgets/member_list_section.dart';
import '../widgets/event_list_section.dart';
import '../widgets/band_info_section.dart';

class MyBandScreen extends ConsumerWidget {
  const MyBandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bandsAsync = ref.watch(bandsProvider);
    final selectedBandAsync = ref.watch(selectedBandProvider);
    final profile = ref.watch(userProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: bandsAsync.when(
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (e, st) => const Text('MyBand'),
          data: (bands) => bands.isEmpty
              ? const Text('MyBand')
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Band>(
                    value:
                        selectedBandAsync.value != null &&
                            bands.any(
                              (b) => b.id == selectedBandAsync.value!.id,
                            )
                        ? bands.firstWhere(
                            (b) => b.id == selectedBandAsync.value!.id,
                          )
                        : null,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isDense: true,
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (Band? newValue) {
                      if (newValue != null) {
                        ref
                            .read(selectedBandIdProvider.notifier)
                            .select(newValue.id);
                      }
                    },
                    items: bands
                        .map<DropdownMenuItem<Band>>(
                          (band) => DropdownMenuItem<Band>(
                            value: band,
                            child: Text(band.name),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
        centerTitle: false,
      ),
      body: bandsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('밴드 목록을 불러오지 못했습니다: $e')),
        data: (bands) {
          if (bands.isEmpty) return const EmptyBandActions();
          return selectedBandAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
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
            data: (band) {
              BandMemberRole? myRole;
              for (final member in band.members) {
                if (member.id == profile?.id) {
                  myRole = member.role;
                  break;
                }
              }
              final isOwner = myRole == BandMemberRole.owner;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MemberListSection(
                      members: band.members,
                      canManage: isOwner,
                      onManage: () =>
                          context.push('/manage_band_members', extra: band),
                    ),
                    const SizedBox(height: 32),
                    EventListSection(
                      bandId: band.id,
                      events: band.events,
                      canDeleteEvents: isOwner,
                      onChanged: () => ref.invalidate(selectedBandProvider),
                    ),
                    const SizedBox(height: 32),
                    BandInfoSection(
                      band: band,
                      canEdit: isOwner,
                      onEdit: () => context.push('/edit_band', extra: band),
                    ),
                    const SizedBox(height: 32),
                    _LeaveBandButton(band: band),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LeaveBandButton extends ConsumerStatefulWidget {
  final Band band;

  const _LeaveBandButton({required this.band});

  @override
  ConsumerState<_LeaveBandButton> createState() => _LeaveBandButtonState();
}

class _LeaveBandButtonState extends ConsumerState<_LeaveBandButton> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmLeave() async {
    _controller.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('밴드 탈퇴'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('탈퇴하려면 밴드 이름 "${widget.band.name}"을 정확히 입력해주세요.'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: '밴드 이름'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, _controller.text == widget.band.name),
            child: const Text(
              '탈퇴',
              style: TextStyle(color: AppColors.semanticError),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      if (mounted && _controller.text.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('밴드 이름이 일치하지 않습니다.')));
      }
      return;
    }

    final userId = ref.read(userProfileProvider).value?.id;
    if (userId == null) return;
    try {
      await ref
          .read(bandMemberRepositoryProvider)
          .removeMember(bandId: widget.band.id, userId: userId);
      ref.invalidate(bandsProvider);
      ref.read(selectedBandIdProvider.notifier).select('');
      ref.invalidate(selectedBandProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.band.name}에서 탈퇴했습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('밴드 탈퇴 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: _confirmLeave,
        child: const Text(
          '밴드 탈퇴',
          style: TextStyle(color: AppColors.semanticError),
        ),
      ),
    );
  }
}
