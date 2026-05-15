import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../models/band_models.dart';

class SheetMusicGallery extends StatelessWidget {
  const SheetMusicGallery({super.key, required this.setlist});

  final List<SetlistItem> setlist;

  @override
  Widget build(BuildContext context) {
    final images = _sheetMusicImages(setlist);
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('악보 미리보기', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceStrong,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '${images.length}장',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.body,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return _SheetMusicTile(
              image: image,
              onTap: () => _openPreview(context, images, index),
            );
          },
        ),
      ],
    );
  }

  void _openPreview(
    BuildContext context,
    List<_SheetMusicImage> images,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _SheetMusicPreviewPage(images: images, initialIndex: initialIndex),
      ),
    );
  }
}

class _SheetMusicTile extends StatelessWidget {
  const _SheetMusicTile({required this.image, required this.onTap});

  final _SheetMusicImage image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceStrong,
            border: Border.all(color: AppColors.hairlineStrong),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                image.url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.muted,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.64),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${image.setlistIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  image.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetMusicPreviewPage extends StatefulWidget {
  const _SheetMusicPreviewPage({
    required this.images,
    required this.initialIndex,
  });

  final List<_SheetMusicImage> images;
  final int initialIndex;

  @override
  State<_SheetMusicPreviewPage> createState() => _SheetMusicPreviewPageState();
}

class _SheetMusicPreviewPageState extends State<_SheetMusicPreviewPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.images[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.images.length}'),
        actions: [
          IconButton(
            tooltip: '다운로드',
            onPressed: () => _download(current.url),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      image.url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    current.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current.artist,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SheetMusicImage {
  const _SheetMusicImage({
    required this.url,
    required this.title,
    required this.artist,
    required this.setlistIndex,
  });

  final String url;
  final String title;
  final String artist;
  final int setlistIndex;
}

List<_SheetMusicImage> _sheetMusicImages(List<SetlistItem> setlist) {
  final images = <_SheetMusicImage>[];
  for (final entry in setlist.asMap().entries) {
    final url = entry.value.sheetMusicUrl;
    if (url == null || !_isImageUrl(url)) continue;
    images.add(
      _SheetMusicImage(
        url: url,
        title: entry.value.title,
        artist: entry.value.artist,
        setlistIndex: entry.key,
      ),
    );
  }
  return images;
}

bool _isImageUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.gif') ||
      path.endsWith('.webp') ||
      path.endsWith('.bmp') ||
      path.endsWith('.svg') ||
      path.endsWith('.tiff') ||
      path.endsWith('.heic') ||
      path.endsWith('.heif') ||
      path.endsWith('.avif');
}
