import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CropDragPoint extends StatelessWidget {
  /// Constructs a [CropDragPoint].
  const CropDragPoint({
    super.key,
    this.size = 20,
    this.color = Colors.blue,
  });

  /// The height and width of this widget.
  final double size;

  /// The color of this widget.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('size', size))
      ..add(ColorProperty('color', color));
  }
}