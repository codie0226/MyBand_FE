import 'package:flutter/material.dart';
import '../models/band_models.dart';

class BandInfoSection extends StatelessWidget {
  final Band band;

  const BandInfoSection({super.key, required this.band});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '밴드 소개',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            band.description ?? '',
            style: TextStyle(fontSize: 14, height: 1.6, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
