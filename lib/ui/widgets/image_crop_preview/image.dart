part of 'preview.dart';

class _CropImage extends StatefulWidget {
  const _CropImage({
    required this.controller,
    required this.image,
    required this.maskOptions,
    required this.dragPointSize,
    required this.hitSize,
    required this.loadingWidget,
    required this.cropUtils,
  });

  final PicTrimController controller;
  final MemoryImage image;
  final MaskOptions maskOptions;
  final double dragPointSize;
  final double hitSize;
  final Widget loadingWidget;
  final CropUtils cropUtils;

  @override
  State<_CropImage> createState() => _CropImageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<PicTrimController>('controller', controller))
      ..add(DiagnosticsProperty<MemoryImage>('image', image))
      ..add(DiagnosticsProperty<MaskOptions>('maskOptions', maskOptions))
      ..add(DoubleProperty('dragPointSize', dragPointSize))
      ..add(DoubleProperty('hitSize', hitSize))
      ..add(DiagnosticsProperty<CropUtils>('cropUtils', cropUtils));
  }
}

class _CropImageState extends State<_CropImage> {
  bool _isMovingCropLayer = false;

  PicTrimController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    bool darkModeEnabled = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(
        widget.dragPointSize / 2 + widget.hitSize / 2,
      ),
      child: ValueListenableBuilder(
        valueListenable: _controller.imageSizeNotifier,
        builder: (context, imageSize, child) {
          if (imageSize == null) {
            return widget.loadingWidget;
          }

          return GestureDetector(
            onPanStart: (details) => _isMovingCropLayer = _controller
                    .cropRectNotifier.value
                    ?.contains(details.localPosition) ??
                false,
            onPanUpdate: _onMoveCropRectUpdate,
            onPanEnd: (_) => _isMovingCropLayer = false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableSpace = Offset.zero &
                    Size(constraints.maxWidth, constraints.maxHeight);

                final imageRect = widget.cropUtils.computeImageRect(
                  imageSize: imageSize,
                  availableSpace: availableSpace,
                );

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    final cropRect = _controller.cropRect;

                    if (cropRect == null) {
                      _controller.cropRect =
                          widget.cropUtils.getInitialRect(imageRect);
                    } else {
                      _controller.cropSizeNotifier.value = Size(
                        cropRect.width,
                        cropRect.height,
                      );
                      _controller.cropRect =
                          widget.cropUtils.computeCropRectForResizedImageRect(
                        imageRect: imageRect,
                        oldImageRect: _controller.imageRect!,
                        cropRect: cropRect,
                      );
                    }

                    _controller.imageRect = imageRect;
                  },
                );

                return child ?? const SizedBox.shrink();
              },
            ),
          );
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _controller.cropRectNotifier,
            _controller.roundedCornerNotifier,
            _controller.borderRadiusNotifier,
            _controller.borderRadiusBottomLeftNotifier,
            _controller.borderRadiusBottomRightNotifier,
            _controller.borderRadiusTopLeftNotifier,
            _controller.borderRadiusTopRightNotifier,
          ]),
          builder: (context, child) {
            final cropRect = _controller.cropRect;
            if (cropRect == null) {
              return widget.loadingWidget;
            }
            



           
            RoudedCorner roundedCorners =
                _controller.roundedCornerNotifier.value;

            return CustomPaint(
              foregroundPainter: RoundedCorners(
                rect: cropRect,
                width: _controller.imageRect!.width,
                height: _controller.imageRect!.height,
                maskOptions: widget.maskOptions,
                radiusTopLeft: roundedCorners == RoudedCorner.all
                    ? _controller.borderRadiusNotifier.value
                    : _controller.borderRadiusTopLeftNotifier.value,
                radiusTopRight: roundedCorners == RoudedCorner.all
                    ? _controller.borderRadiusNotifier.value
                    : _controller.borderRadiusTopRightNotifier.value,
                radiusBottomLeft: roundedCorners == RoudedCorner.all
                    ? _controller.borderRadiusNotifier.value
                    : _controller.borderRadiusBottomLeftNotifier.value,
                radiusBottomRight: roundedCorners == RoudedCorner.all
                    ? _controller.borderRadiusNotifier.value
                    : _controller.borderRadiusBottomRightNotifier.value,
                color: !darkModeEnabled ? Colors.grey[300] : Colors.white,
              ),
              child: Image(
                image: widget.image,
                fit: BoxFit.fill,
                width: double.parse(
                    _controller.imageRect!.width.round().toString()),
                height: double.parse(
                    _controller.imageRect!.height.round().toString()),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onMoveCropRectUpdate(DragUpdateDetails details) {
    if (!_isMovingCropLayer) {
      return;
    }
    _controller.cropRect = widget.cropUtils.moveCropRect(
      delta: details.delta,
      cropRect: _controller.cropRect,
      imageRect: _controller.imageRect,
    );
  }
}
