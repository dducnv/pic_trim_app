import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pic_trim_app/core/controller.dart';
import 'package:pic_trim_app/core/mask/options.dart';
import 'package:pic_trim_app/ui/widgets.dart';

class CropViewArea extends StatelessWidget {
  const CropViewArea(
      {super.key,
      required this.bytes,
      required this.controller,
       this.aspectRatio});
  final Uint8List bytes;
  final PicTrimController controller;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final cropPreview = CropPreview(
      controller: controller,
      bytes: bytes,
      maskOptions: MaskOptions(aspectRatio: aspectRatio),
      dragPointBuilder: (size, position) =>const CropDragPoint(
        size: 8,
        color: Colors.deepPurple,
      ),
    );
    return cropPreview;
  }
}
