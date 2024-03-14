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
      final x = (cropRect.left / imageRect.width * imageSize.width);
      final y = (cropRect.top / imageRect.height * imageSize.height);
      final width = cropSize.width;
      final height = cropSize.height;

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      final rect = Rect.fromLTWH(0, 0, width, height);

      RoudedCorner roundedCorners = roundedCornerNotifier.value;

      // Create the path

      canvas.clipRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(roundedCorners == RoudedCorner.all
              ? borderRadiusNotifier.value * 2.24
              : borderRadiusTopLeftNotifier.value * 2.24),
          topRight: Radius.circular(roundedCorners == RoudedCorner.all
              ? borderRadiusNotifier.value * 2.24
              : borderRadiusTopRightNotifier.value * 2.24),
          bottomLeft: Radius.circular(roundedCorners == RoudedCorner.all
              ? borderRadiusNotifier.value * 2.24
              : borderRadiusBottomLeftNotifier.value * 2.24),
          bottomRight: Radius.circular(roundedCorners == RoudedCorner.all
              ? borderRadiusNotifier.value * 2.24
              : borderRadiusBottomRightNotifier.value * 2.24),
        ),
        doAntiAlias: true
      );

      final ui.Image image = await loadUiImage(ByteData.view(bytes.buffer));

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(x, y, width, height),
        rect,
        Paint()..isAntiAlias = true,
      );

      final roundedImage = await pictureRecorder.endRecording().toImage(
            width.round(),
            height.round(),
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
    borderRadiusTopLeftNotifier.dispose();
    borderRadiusTopRightNotifier.dispose();
    borderRadiusBottomLeftNotifier.dispose();
    borderRadiusBottomRightNotifier.dispose();
    roundedCornerNotifier.dispose();
  }
}
