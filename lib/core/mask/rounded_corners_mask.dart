part of 'mask.dart';

class RoundedCorners extends CropMask {
  final double radiusTopLeft;
  final double radiusTopRight;
  final double radiusBottomLeft;
  final double radiusBottomRight;
  final Color? color;
  final double? width;
  final double? height;
  final Function(Rect screenRect)? onDrawMask; 

  const RoundedCorners({
    this.color,
    required super.rect,
    required super.maskOptions,
    this.width,
    this.height,
    this.onDrawMask,
    required this.radiusTopLeft,
    required this.radiusTopRight,
    required this.radiusBottomLeft,
    required this.radiusBottomRight,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final Rect screenRect = Offset.zero & size;

    
    double radiusTl = radiusTopLeft * min(size.width, size.height) / 100;
    double radiusTr = radiusTopRight * min(size.width, size.height) / 100;
    double radiusBl = radiusBottomLeft * min(size.width, size.height) / 100;
    double radiusBr = radiusBottomRight * min(size.width, size.height) / 100;

    final Path areaPath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(radiusTl),
        topRight: Radius.circular(radiusTr),
        bottomLeft: Radius.circular(radiusBl),
        bottomRight: Radius.circular(radiusBr),

      ));


    final Path maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(screenRect),
      areaPath,
    );
    


    canvas
      ..drawPath(maskPath, backgroundPaint)
      ..drawPath(areaPath, borderPaint);
  }
}