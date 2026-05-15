import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';

class BandInfoSection extends StatelessWidget {
  final Band band;
  final bool canEdit;
  final VoidCallback? onEdit;

  const BandInfoSection({
    super.key,
    required this.band,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceStrong,
                backgroundImage: band.iconUrl != null
                    ? NetworkImage(band.iconUrl!)
                    : null,
                child: band.iconUrl == null
                    ? const Icon(
                        Icons.music_note,
                        color: AppColors.ink,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (band.genre?.isNotEmpty == true)
                      Text(band.genre!, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (canEdit)
                IconButton(
                  tooltip: '밴드 정보 수정',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('밴드 소개', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            band.description?.isNotEmpty == true
                ? band.description!
                : '아직 밴드 소개가 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.body,
              height: 1.6,
            ),
          ),
          if (band.inviteCode?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text('초대 코드', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceStrong,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.hairlineStrong),
              ),
              child: SelectableText(
                band.inviteCode!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
