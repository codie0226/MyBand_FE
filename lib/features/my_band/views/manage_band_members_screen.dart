import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/authenticated_image.dart';
import '../data/band_member_repository.dart';
import '../models/band_models.dart';
import '../providers/band_provider.dart';

class ManageBandMembersScreen extends ConsumerWidget {
  final Band? band;

  const ManageBandMembersScreen({super.key, this.band});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBandProvider);
    final effectiveBand = band ?? selected.value;

    return Scaffold(
      appBar: AppBar(title: const Text('밴드 멤버 관리'), centerTitle: false),
      body: effectiveBand == null
          ? selected.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('멤버를 불러오지 못했습니다: $e')),
              data: (loaded) => _MemberManager(band: loaded),
            )
          : _MemberManager(band: effectiveBand),
    );
  }
}

class _MemberManager extends ConsumerWidget {
  final Band band;

  const _MemberManager({required this.band});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: band.members.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final member = band.members[index];
        final isOwner = member.role == BandMemberRole.owner;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AuthenticatedAvatar(
            radius: 20,
            imageUrl: member.profileImageUrl,
            child: Text(member.name.isNotEmpty ? member.name[0] : '?'),
          ),
          title: Text(member.name),
          subtitle: Text(
            [
              member.instrument ?? '파트 미정',
              isOwner ? 'owner' : 'member',
            ].join(' · '),
          ),
          trailing: Wrap(
            spacing: 4,
            children: [
              if (!isOwner)
                TextButton(
                  onPressed: () => _promote(context, ref, member),
                  child: const Text('owner 지정'),
                ),
              IconButton(
                tooltip: '강퇴',
                onPressed: () => _remove(context, ref, member),
                icon: const Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.semanticError,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _promote(
    BuildContext context,
    WidgetRef ref,
    Member member,
  ) async {
    try {
      await ref
          .read(bandMemberRepositoryProvider)
          .updateMemberRole(
            bandId: band.id,
            userId: member.id,
            role: BandMemberRole.owner,
          );
      ref.invalidate(selectedBandProvider);
      ref.invalidate(bandsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.name}님을 owner로 변경했습니다.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('등급 변경 실패: $e')));
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Member member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('멤버 강퇴'),
        content: Text('${member.name}님을 밴드에서 내보낼까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '강퇴',
              style: TextStyle(color: AppColors.semanticError),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(bandMemberRepositoryProvider)
          .removeMember(bandId: band.id, userId: member.id);
      ref.invalidate(selectedBandProvider);
      ref.invalidate(bandsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${member.name}님을 내보냈습니다.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('강퇴 실패: $e')));
    }
  }
}
