part of 'mask.dart';

class RoundedCorners extends CropMask {
  final double radius;
  final Color? color;

  const RoundedCorners({
    this.color,
    required this.radius,
    required super.rect,
    required super.maskOptions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screenRect = Offset.zero & size;

    final Path areaPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ));
    final Path maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(screenRect),
      areaPath,
    );
    Paint borderPaintCus = Paint();

    //set radius of the oval

    borderPaintCus.color = color ?? Colors.white;
    borderPaintCus.style = PaintingStyle.stroke;
    borderPaintCus.strokeWidth = 0.5;

    canvas
      ..drawPath(maskPath, backgroundPaint)
      ..drawPath(areaPath, borderPaintCus);
  }
}
