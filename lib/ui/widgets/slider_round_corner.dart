import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pic_trim_app/core/controller.dart';

class SliderRoundCorner extends StatefulWidget {
  const SliderRoundCorner({super.key, required this.controller});

  final PicTrimController controller;

  @override
  State<SliderRoundCorner> createState() => _SliderRoundCornerState();
}

class _SliderRoundCornerState extends State<SliderRoundCorner> {
  bool _isShowAnimation = false;

  void setRadius(double value) {
    if (widget.controller.roundedCornerNotifier.value == RoudedCorner.all) {
      widget.controller.borderRadiusNotifier.value = value;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.topLeft) {
      widget.controller.borderRadiusTopLeftNotifier.value = value;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.topRight) {
      widget.controller.borderRadiusTopRightNotifier.value = value;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.bottomLeft) {
      widget.controller.borderRadiusBottomLeftNotifier.value = value;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.bottomRight) {
      widget.controller.borderRadiusBottomRightNotifier.value = value;
    }
  }

  ValueListenable getNotifier() {
    if (widget.controller.roundedCornerNotifier.value == RoudedCorner.all) {
      return widget.controller.borderRadiusNotifier;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.topLeft) {
      return widget.controller.borderRadiusTopLeftNotifier;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.topRight) {
      return widget.controller.borderRadiusTopRightNotifier;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.bottomLeft) {
      return widget.controller.borderRadiusBottomLeftNotifier;
    } else if (widget.controller.roundedCornerNotifier.value ==
        RoudedCorner.bottomRight) {
      return widget.controller.borderRadiusBottomRightNotifier;
    }
    return widget.controller.borderRadiusNotifier;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _roundCornerButton(
              valueListenable: widget.controller.borderRadiusNotifier,
              child: _isShowAnimation
                  ? const Icon(
                      Icons.cancel_outlined,
                      size: 20,
                    )
                  : null,
              suffixes: !_isShowAnimation
                  ? const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                    )
                  : const SizedBox.shrink(),
              onTap: () {
                setState(() {
                  _isShowAnimation = !_isShowAnimation;
                });

                if (!_isShowAnimation) {
                  widget.controller.roundedCornerNotifier.value =
                      RoudedCorner.all;
                } else {
                  widget.controller.roundedCornerNotifier.value =
                      RoudedCorner.topLeft;
                }
              },
            ),
            Visibility(
                visible: _isShowAnimation, child: const SizedBox(width: 5)),
            ValueListenableBuilder(
                valueListenable: widget.controller.roundedCornerNotifier,
                builder: (context, roundedCorner, child) {
                  return AnimatedOpacity(
                    opacity: _isShowAnimation ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    child: Visibility(
                      visible: _isShowAnimation,
                      child: Row(
                        children: [
                          _roundCornerButton(
                            valueListenable:
                                widget.controller.borderRadiusTopLeftNotifier,
                            suffixes: const SizedBox(
                              width: 5,
                            ),
                            quarterTurns: 3,
                            selected:
                                widget.controller.roundedCornerNotifier.value ==
                                    RoudedCorner.topLeft,
                            onTap: () {
                              widget.controller.roundedCornerNotifier.value =
                                  RoudedCorner.topLeft;
                            },
                          ),
                          _roundCornerButton(
                            valueListenable: widget
                                .controller.borderRadiusBottomLeftNotifier,
                            suffixes: const SizedBox(
                              width: 5,
                            ),
                            quarterTurns: 2,
                            selected:
                                widget.controller.roundedCornerNotifier.value ==
                                    RoudedCorner.bottomLeft,
                            onTap: () {
                              widget.controller.roundedCornerNotifier.value =
                                  RoudedCorner.bottomLeft;
                            },
                          ),
                          _roundCornerButton(
                            valueListenable:
                                widget.controller.borderRadiusTopRightNotifier,
                            suffixes: const SizedBox(
                              width: 5,
                            ),
                            selected:
                                widget.controller.roundedCornerNotifier.value ==
                                    RoudedCorner.topRight,
                            onTap: () {
                              widget.controller.roundedCornerNotifier.value =
                                  RoudedCorner.topRight;
                            },
                          ),
                          _roundCornerButton(
                            valueListenable: widget
                                .controller.borderRadiusBottomRightNotifier,
                            suffixes: const SizedBox(
                              width: 5,
                            ),
                            quarterTurns: 5,
                            selected:
                                widget.controller.roundedCornerNotifier.value ==
                                    RoudedCorner.bottomRight,
                            onTap: () {
                              widget.controller.roundedCornerNotifier.value =
                                  RoudedCorner.bottomRight;
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ],
        ),
        ValueListenableBuilder(
            valueListenable: widget.controller.roundedCornerNotifier,
            builder: (context, roundedCorners, child) {
              return ValueListenableBuilder(
                valueListenable: getNotifier(),
                builder: (context, roundedCorners, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: roundedCorners > 0,
                        maintainState: true,
                        maintainSize: true,
                        maintainAnimation: true,
                        child: IconButton(
                            enableFeedback: true,
                            onPressed: () {
                              setRadius(getNotifier().value - 1 < 0
                                  ? 0
                                  : getNotifier().value - 1);
                            },
                            icon: const Icon(Icons.remove)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Slider(
                          value: roundedCorners,
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setRadius(value);
                          },
                        ),
                      ),
                      Visibility(
                        visible: roundedCorners < 100,
                        maintainState: true,
                        maintainSize: true,
                        maintainAnimation: true,
                        child: IconButton(
                            enableFeedback: true,
                            onPressed: () {
                              setRadius(getNotifier().value + 1 > 100
                                  ? 100
                                  : getNotifier().value + 1);
                            },
                            icon: const Icon(Icons.add)),
                      ),
                    ],
                  );
                },
              );
            }),
      ],
    );
  }

  Widget _roundCornerButton(
      {Widget? suffixes,
      Function()? onTap,
      Widget? child,
      int? quarterTurns,
      bool selected = false,
      required ValueListenable valueListenable}) {
    bool darkModeEnabled = Theme.of(context).brightness == Brightness.dark;

    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: selected
            ? darkModeEnabled
                ? Colors.grey[700]
                : Colors.grey[200]
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          onTap?.call();
        },
        child: child ??
            Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 5,
                top: 2,
                bottom: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotatedBox(
                      quarterTurns: quarterTurns ?? 0,
                      child: const Icon(
                        Icons.rounded_corner,
                        size: 18,
                      )),
                  const SizedBox(width: 5),
                  ValueListenableBuilder(
                      valueListenable: valueListenable,
                      builder: (context, borderRadius, child) {
                        return Text(
                          '${borderRadius.floor().round()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }),
                  if (suffixes != null) suffixes,
                ],
              ),
            ),
      ),
    );
  }
}
