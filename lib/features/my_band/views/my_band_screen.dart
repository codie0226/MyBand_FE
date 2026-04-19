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
    final selectedBand = ref.watch(selectedBandProvider);
    final bands = ref.watch(bandsProvider);

    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<Band>(
            value: selectedBand,
            icon: const Icon(Icons.keyboard_arrow_down),
            isDense: true,
            style: Theme.of(context).textTheme.titleLarge,
            onChanged: (Band? newValue) {
              if (newValue != null) {
                ref.read(selectedBandIdProvider.notifier).select(newValue.id);
              }
            },
            items: bands.map<DropdownMenuItem<Band>>((Band band) {
              return DropdownMenuItem<Band>(
                value: band,
                child: Text(band.name),
              );
            }).toList(),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberListSection(members: selectedBand.members),
            const SizedBox(height: 32),
            EventListSection(events: selectedBand.events),
            const SizedBox(height: 32),
            BandInfoSection(band: selectedBand),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
