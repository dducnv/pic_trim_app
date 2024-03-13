import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pic_trim_app/core/exception/pic_trim_exception.dart';

enum RoudedCorner {
  all,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

final class PicTrimController {
  /// Stores the size of the image to be cropped.
  final imageSizeNotifier = ValueNotifier<Size?>(null);

  /// Stores the image's position and size within the view.
  final imageRectNotifier = ValueNotifier<Rect?>(null);

  /// Stores the selected crop area within the view.
  final cropRectNotifier = ValueNotifier<Rect?>(null);

  ValueNotifier<double> borderRadiusNotifier = ValueNotifier<double>(0);

  ValueNotifier<double> borderRadiusTopLeftNotifier = ValueNotifier<double>(0);
  ValueNotifier<double> borderRadiusTopRightNotifier = ValueNotifier<double>(0);
  ValueNotifier<double> borderRadiusBottomLeftNotifier =
      ValueNotifier<double>(0);
  ValueNotifier<double> borderRadiusBottomRightNotifier =
      ValueNotifier<double>(0);

  ValueNotifier<RoudedCorner> roundedCornerNotifier =
      ValueNotifier<RoudedCorner>(RoudedCorner.all);

  /// Stores the [CropMode] of the image to be cropped.

  /// Stores the image data to be cropped.
  Uint8List? bytes;

  /// Gets the image [Size] stored in the [ValueNotifier].
  Size? get imageSize => imageSizeNotifier.value;

  /// Sets the new image [Size] in the [ValueNotifier].
  set imageSize(Size? value) => imageSizeNotifier.value = value;

  /// Gets the image [Rect] stored in the [ValueNotifier].
  Rect? get imageRect => imageRectNotifier.value;

  /// Sets the new image [Rect] in the [ValueNotifier].
  set imageRect(Rect? value) => imageRectNotifier.value = value;

  /// Gets the crop [Rect] stored in the [ValueNotifier].
  Rect? get cropRect => cropRectNotifier.value;

  /// Sets the new crop [Rect] in the [ValueNotifier].
  set cropRect(Rect? value) => cropRectNotifier.value = value;

  Size get cropSize {
    if ((cropRect, imageRect, imageSize)
        case (
          final Rect cropRect,
          final Rect imageRect,
          final Size imageSize,
        )) {
      final width = cropRect.width / imageRect.width * imageSize.width;
      final height = cropRect.height / imageRect.height * imageSize.height;
      return Size(width, height);
    }

    throw const PicTrimException(
      'NullPointerException',
      'Crop rect, image rect or image size are not initialized!',
    );
  }

  Future<Uint8List> cropAndRoundedCorners() async {
    if ((cropRect, imageRect, imageSize, bytes)
        case (
          final Rect cropRect,
          final Rect imageRect,
          final Size imageSize,
          final Uint8List bytes,
        )) {
      print('cropRect: $cropRect');

      final x = (cropRect.left / imageRect.width * imageSize.width).toInt();
      final y = (cropRect.top / imageRect.height * imageSize.height).toInt();
      final width = cropSize.width.toInt();
      final height = cropSize.height.toInt();

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      final rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());

      RoudedCorner roundedCorners = roundedCornerNotifier.value;

      // Create the path
      final areaPath = Path()
        ..addRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(
            roundedCorners == RoudedCorner.all
                ? borderRadiusNotifier.value
                : borderRadiusTopLeftNotifier.value,
          ),
          topRight: Radius.circular(
            roundedCorners == RoudedCorner.all
                ? borderRadiusNotifier.value
                : borderRadiusTopRightNotifier.value,
          ),
          bottomLeft: Radius.circular(
            roundedCorners == RoudedCorner.all
                ? borderRadiusNotifier.value
                : borderRadiusBottomLeftNotifier.value,
          ),
          bottomRight: Radius.circular(
            roundedCorners == RoudedCorner.all
                ? borderRadiusNotifier.value
                : borderRadiusBottomRightNotifier.value,
          ),
        ));

      canvas.clipPath(areaPath);

      final ui.Image image = await loadUiImage(ByteData.view(bytes.buffer));

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(
            x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
        rect,
        Paint()..isAntiAlias = true,
      );

      final roundedImage = await pictureRecorder.endRecording().toImage(
            width.toInt(),
            height.toInt(),
          );

      final roundedBytes = await roundedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return roundedBytes!.buffer.asUint8List();
    }

    throw const PicTrimException(
      'NullPointerException',
      'Bytes, crop rect, image rect or image size are not initialized!',
    );
  }

  Future<ui.Image> loadUiImage(ByteData bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(Uint8List.view(bytes.buffer), (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  void dispose() {
    imageSizeNotifier.dispose();
    imageRectNotifier.dispose();
    cropRectNotifier.dispose();
    borderRadiusNotifier.dispose();
  }
}
