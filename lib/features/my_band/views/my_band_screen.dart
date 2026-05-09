import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/band_provider.dart';
import '../models/band_models.dart';
import '../widgets/member_list_section.dart';
import '../widgets/event_list_section.dart';
import '../widgets/band_info_section.dart';

class MyBandScreen extends ConsumerWidget {
  const MyBandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bandsAsync = ref.watch(bandsProvider);
    final selectedBandAsync = ref.watch(selectedBandProvider);

    return Scaffold(
      appBar: AppBar(
        title: bandsAsync.when(
          loading: () => const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (e, st) => const Text('MyBand'),
          data: (bands) => DropdownButtonHideUnderline(
            child: DropdownButton<Band>(
              value: selectedBandAsync.value != null &&
                      bands.any((b) =>
                          b.id == selectedBandAsync.value!.id)
                  ? bands.firstWhere(
                      (b) => b.id == selectedBandAsync.value!.id)
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
      body: selectedBandAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
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
        data: (band) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemberListSection(members: band.members),
              const SizedBox(height: 32),
              EventListSection(events: band.events),
              const SizedBox(height: 32),
              BandInfoSection(band: band),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
