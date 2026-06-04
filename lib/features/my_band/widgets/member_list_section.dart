import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/authenticated_image.dart';
import '../models/band_models.dart';

class MemberListSection extends StatelessWidget {
  final List<Member> members;
  final bool canManage;
  final VoidCallback? onManage;

  const MemberListSection({
    super.key,
    required this.members,
    this.canManage = false,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '밴드 멤버',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (canManage)
                IconButton(
                  tooltip: '밴드 멤버 관리',
                  onPressed: onManage,
                  icon: const Icon(Icons.manage_accounts_outlined, size: 20),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: members.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final member = members[index];
              return Column(
                children: [
                  AuthenticatedAvatar(
                    radius: 30,
                    imageUrl: member.profileImageUrl,
                    child: Text(member.name.isNotEmpty ? member.name[0] : '?'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    member.role == BandMemberRole.owner
                        ? '${member.instrument ?? '-'} · owner'
                        : member.instrument ?? '-',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
