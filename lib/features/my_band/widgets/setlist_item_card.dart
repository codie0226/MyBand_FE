import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';

class SetlistItemCard extends StatelessWidget {
  final int index;
  final SetlistItem item;

  const SetlistItemCard({super.key, required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${index + 1}. ',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  '${item.title} - ${item.artist}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (item.key != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.point.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.key!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.point,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (item.sheetMusicUrl != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.music_note,
                    size: 14,
                    color: AppColors.secondaryText.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Expanded(
                  child: SelectableText(
                    item.sheetMusicUrl!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.point,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (item.references.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...item.references.map((ref) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Row(
                    children: [
                      Icon(Icons.link,
                          size: 14,
                          color:
                              AppColors.secondaryText.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SelectableText(
                          ref,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.point,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
