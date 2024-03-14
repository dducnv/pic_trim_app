part of 'mask.dart';

class RoundedCorners extends CropMask {
  final double radiusTopLeft;
  final double radiusTopRight;
  final double radiusBottomLeft;
  final double radiusBottomRight;
  final Color? color;

  const RoundedCorners({
    this.color,
    required super.rect,
    required super.maskOptions,
    required this.radiusTopLeft,
    required this.radiusTopRight,
    required this.radiusBottomLeft,
    required this.radiusBottomRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screenRect = Offset.zero & Size(double.parse(size.width.round().toString()), double.parse(size.height.round().toString()));

    final Path areaPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(radiusTopLeft),
        topRight: Radius.circular(radiusTopRight),
        bottomLeft: Radius.circular(radiusBottomLeft),
        bottomRight: Radius.circular(radiusBottomRight),

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
