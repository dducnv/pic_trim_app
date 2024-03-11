import 'package:flutter/material.dart';
import 'package:pic_trim_app/core/controller.dart';

class SliderRoundCorner extends StatelessWidget {
  const SliderRoundCorner({super.key, required this.controller});

  final PicTrimController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.borderRadiusNotifier,
      builder: (context, borderRadius, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             _roundCornerButton(borderRadius),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  replacement: const SizedBox(
                    width: 50,
                  ),
                  visible: controller.borderRadiusNotifier.value > 0,
                  child: IconButton(
                      enableFeedback: true,
                      onPressed: () {
                        if (controller.borderRadiusNotifier.value > 0) {
                          controller.borderRadiusNotifier.value -= 1;
                        }
                      },
                      icon: const Icon(Icons.remove)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Slider(
                    value: controller.borderRadiusNotifier.value,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      controller.borderRadiusNotifier.value = value;
                    },
                  ),
                ),
                Visibility(
                  replacement: const SizedBox(
                    width: 50,
                  ),
                  visible: controller.borderRadiusNotifier.value < 100.0,
                  child: IconButton(
                      enableFeedback: true,
                      onPressed: () {
                        if (controller.borderRadiusNotifier.value < 100) {
                          controller.borderRadiusNotifier.value += 1;
                        }
                      },
                      icon: const Icon(Icons.add)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _roundCornerButton(
    double borderRadius, {
    Widget? suffixes,
  }) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
       
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            top: 2,
            bottom: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.rounded_corner),
              const SizedBox(width: 5),
              Text('${borderRadius.floor().round()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
              if (suffixes != null) suffixes,
             
            ],
          ),
        ),
      ),
    );
  }
}
