import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/authenticated_image.dart';
import '../../my_band/models/band_models.dart';
import '../../my_band/providers/band_provider.dart';
import '../../my_band/widgets/empty_band_actions.dart';

class ChatRoomListScreen extends ConsumerWidget {
  const ChatRoomListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bandsAsync = ref.watch(bandsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('채팅방'), centerTitle: false),
      body: bandsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorView(
          message: '채팅방 목록을 불러오지 못했습니다. $e',
          onRetry: () => ref.invalidate(bandsProvider),
        ),
        data: (bands) {
          if (bands.isEmpty) {
            return const EmptyBandActions(message: '채팅할 밴드가 없습니다.');
          }

          return RefreshIndicator(
            onRefresh: () async => ref.read(bandsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: bands.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final band = bands[index];
                return _ChatRoomTile(band: band);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.band});

  final Band band;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (band.genre?.isNotEmpty == true) band.genre!,
      '${band.memberCount}명',
    ].join(' · ');

    return Material(
      color: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/chat/${band.id}', extra: band),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AuthenticatedAvatar(
                radius: 24,
                imageUrl: band.iconUrl,
                backgroundColor: AppColors.surfaceStrong,
                child: Text(
                  band.name.isNotEmpty ? band.name[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      band.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.body),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}
