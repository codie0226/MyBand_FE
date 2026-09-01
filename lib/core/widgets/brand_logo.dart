import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'MyBand logo',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _BrandLogoPainter()),
      ),
    );
  }
}

class _BrandLogoPainter extends CustomPainter {
  static const _canvasSize = 512.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _canvasSize;
    canvas.scale(scale, scale);

    final background = Paint()..color = const Color(0xFF171717);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, _canvasSize, _canvasSize),
        const Radius.circular(120),
      ),
      background,
    );

    final monogram = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final mPath = Path()
      ..moveTo(116, 368)
      ..lineTo(116, 152)
      ..lineTo(256, 296)
      ..lineTo(396, 152)
      ..lineTo(396, 368);
    canvas.drawPath(mPath, monogram);

    final beat = Paint()..color = const Color(0xFFCFE7FF);
    for (final point in const [
      Offset(116, 368),
      Offset(256, 296),
      Offset(396, 368),
    ]) {
      canvas.drawCircle(point, 22, beat);
    }
  }

  @override
  bool shouldRepaint(covariant _BrandLogoPainter oldDelegate) => false;
}
