import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_resource_url.dart';
import '../network/attachment_repository.dart';

class AuthenticatedImage extends ConsumerStatefulWidget {
  const AuthenticatedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, Object error, StackTrace? stack)?
  errorBuilder;

  @override
  ConsumerState<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends ConsumerState<AuthenticatedImage> {
  Future<Uint8List>? _bytesFuture;

  @override
  void initState() {
    super.initState();
    _updateBytesFuture();
  }

  @override
  void didUpdateWidget(covariant AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _updateBytesFuture();
    }
  }

  void _updateBytesFuture() {
    _bytesFuture = isApiResourceUrl(widget.url) ? _load() : null;
  }

  Future<Uint8List> _load() {
    return ref.read(attachmentRepositoryProvider).fetchBytes(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    if (!isApiResourceUrl(widget.url)) {
      return Image.network(
        widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        filterQuality: widget.filterQuality,
        errorBuilder: widget.errorBuilder,
      );
    }

    return FutureBuilder<Uint8List>(
      future: _bytesFuture!,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _sized(
            widget.loadingBuilder?.call(context) ??
                const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _sized(
            widget.errorBuilder?.call(
                  context,
                  snapshot.error ?? StateError('Image bytes missing'),
                  snapshot.stackTrace,
                ) ??
                const Center(child: Icon(Icons.broken_image_outlined)),
          );
        }

        return Image.memory(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          gaplessPlayback: true,
          filterQuality: widget.filterQuality,
        );
      },
    );
  }

  Widget _sized(Widget child) {
    return SizedBox(width: widget.width, height: widget.height, child: child);
  }
}

class AuthenticatedAvatar extends StatelessWidget {
  const AuthenticatedAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.backgroundColor,
    this.child,
  });

  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        child: child,
      );
    }

    final size = radius * 2;
    final fallback = child ?? const Icon(Icons.broken_image_outlined);
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: ColoredBox(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          child: AuthenticatedImage(
            url: url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            loadingBuilder: (_) => const Center(
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorBuilder: (_, _, _) => Center(child: fallback),
          ),
        ),
      ),
    );
  }
}
