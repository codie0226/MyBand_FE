import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';

class BandInfoSection extends StatelessWidget {
  final Band band;

  const BandInfoSection({super.key, required this.band});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surface,
                backgroundImage: band.iconUrl != null
                    ? NetworkImage(band.iconUrl!)
                    : null,
                child: band.iconUrl == null
                    ? const Icon(Icons.music_note, color: AppColors.point)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (band.genre?.isNotEmpty == true)
                      Text(
                        band.genre!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('밴드 소개', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            band.description?.isNotEmpty == true
                ? band.description!
                : '아직 밴드 소개가 없습니다.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          if (band.inviteCode?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text('초대 코드', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SelectableText(
              band.inviteCode!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.point,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
