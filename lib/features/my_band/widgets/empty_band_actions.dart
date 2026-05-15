import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmptyBandActions extends StatelessWidget {
  final String message;

  const EmptyBandActions({super.key, this.message = '아직 속한 밴드가 없습니다.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/join_band'),
                icon: const Icon(Icons.key),
                label: const Text('새로운 밴드 가입'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/create_band'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('새로운 밴드 생성'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
