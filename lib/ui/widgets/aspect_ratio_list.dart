import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

class AspectRatioList extends StatelessWidget {
  const AspectRatioList(
      {super.key,
      required this.onAspectRatioChanged,
      required this.aspectRatio});

  final Function(double) onAspectRatioChanged;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    bool darkModeEnabled = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      scrollDirection: Axis.horizontal,
      itemCount: aspectRatioList.length,
      itemBuilder: (context, index) {
        return Material(
          child: Ink(
            decoration: BoxDecoration(
              color: aspectRatio == aspectRatioList[index].value
                  ? darkModeEnabled
                      ? Colors.grey[800]
                      : Colors.grey[200]
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              radius: 10,
              onTap: () {
                onAspectRatioChanged(aspectRatioList[index].value!);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 2,
                ),
                child: Center(
                  child: Row(
                    children: [
                      if (aspectRatioList[index].icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Icon(aspectRatioList[index].icon,
                         color: aspectRatio == aspectRatioList[index].value
                                ? darkModeEnabled
                                    ? Colors.grey[200]
                                    : Colors.grey[800]
                                : Colors.grey[600],
                        size: 16,
                        ),
                      ),
                      Text(aspectRatioList[index].label,
                          style: TextStyle(
                            fontSize: 12,
                            color: aspectRatio == aspectRatioList[index].value
                                ? darkModeEnabled
                                    ? Colors.grey[200]
                                    : Colors.grey[800]
                                : Colors.grey[600],
                          )),

                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AspectRatio {
  final double? value;
  final String label;
  final IconData? icon;
  const AspectRatio({
    this.value,
    this.icon,
    required this.label,
  });
}

const List<AspectRatio> aspectRatioList = [
  AspectRatio(label: 'Freedom', value: 0),
  AspectRatio(value: 1, label: '1:1'),
  AspectRatio(value: 4 / 3, label: '4:3'),
  AspectRatio(value: 16 / 9, label: '16:9'),
  AspectRatio(value: 3 / 4, label: '3:4'),
  AspectRatio(icon: BootstrapIcons.instagram, value: 9 / 16, label: '9:16'),
  AspectRatio(icon: BootstrapIcons.instagram, value: 4 / 5, label: '4:5'),
  AspectRatio(icon: BootstrapIcons.pinterest, value: 2 / 3, label: '2:3'),
  AspectRatio(icon: BootstrapIcons.twitter_x, value: 2 / 1, label: '2:1'),
  AspectRatio(icon: BootstrapIcons.linkedin, value: 1.91 / 1, label: '1.91:1'),
];
