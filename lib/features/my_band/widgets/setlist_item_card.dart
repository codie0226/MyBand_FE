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
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Text(
                  '${item.title} - ${item.artist}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (item.key != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceStrong,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.hairlineStrong),
                  ),
                  child: Text(
                    item.key!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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
                const Icon(Icons.music_note, size: 14, color: AppColors.muted),
                const SizedBox(width: 4),
                Expanded(
                  child: SelectableText(
                    item.sheetMusicUrl!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      color: AppColors.body,
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
                      const Icon(Icons.link, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SelectableText(
                          ref,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            color: AppColors.body,
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
