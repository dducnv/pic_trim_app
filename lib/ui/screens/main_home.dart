import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pic_trim_app/core/controller.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:pic_trim_app/ui/screens/main_home_controller.dart';
import 'package:pic_trim_app/ui/widgets.dart';
import 'package:pic_trim_app/ui/widgets/notify_save_image.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => MainHomeState();
}

class MainHomeState extends State<MainHome> {
  Uint8List? _bytes;
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];
  late PicTrimController controller;
  @override
  void initState() {
    super.initState();
    controller = PicTrimController();

    _intentSub = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles.addAll(value);
        if (_sharedFiles.isNotEmpty) {
          final file = File(_sharedFiles[0].path);
          final bytes = file.readAsBytesSync();
          _bytes = bytes;
        }
      });
    });

    ReceiveSharingIntent.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        if (_sharedFiles.isNotEmpty) {
          final file = File(_sharedFiles[0].path);
          final bytes = file.readAsBytesSync();
          _bytes = bytes;
        }
        ReceiveSharingIntent.reset();
      });
    });

    context.read<AppProvider>().initAddressSaveImage();
  }

  Future<void> imagePicker() async {
    final ImagePicker picker = ImagePicker();
    final value = await picker.pickImage(source: ImageSource.gallery);
    if (value != null) {
      final file = File(value.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _bytes = bytes;
      });
    }
  }

  ValueListenable getNotifier() {
    if (controller.roundedCornerNotifier.value == RoudedCorner.all) {
      return controller.borderRadiusNotifier;
    } else if (controller.roundedCornerNotifier.value == RoudedCorner.topLeft) {
      return controller.borderRadiusTopLeftNotifier;
    } else if (controller.roundedCornerNotifier.value ==
        RoudedCorner.topRight) {
      return controller.borderRadiusTopRightNotifier;
    } else if (controller.roundedCornerNotifier.value ==
        RoudedCorner.bottomLeft) {
      return controller.borderRadiusBottomLeftNotifier;
    } else if (controller.roundedCornerNotifier.value ==
        RoudedCorner.bottomRight) {
      return controller.borderRadiusBottomRightNotifier;
    }
    return controller.borderRadiusNotifier;
  }

  @override
  void dispose() {
    controller.dispose();
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: _bytes == null
            ? const SizedBox.shrink()
            : Selector<AppProvider, int>(
                selector: (p0, p1) => p1.tabEditIndex,
                builder: (context, tabEditIndex, child) {
                  return BottomAppBar(
                    elevation: 0,
                    child: Row(
                      children: [
                        IconButton(
                            isSelected: tabEditIndex == 0,
                            icon: const Icon(Icons.rounded_corner_rounded),
                            onPressed: () {
                              context.read<AppProvider>().changePage(0);
                            }),
                        const SizedBox(width: 10),
                        IconButton(
                            isSelected: tabEditIndex == 1,
                            icon: const Icon(Icons.crop),
                            onPressed: () {
                              context.read<AppProvider>().changePage(1);
                            }),
                        const SizedBox(width: 10),
                        IconButton(
                            isSelected: tabEditIndex == 2,
                            icon: const Icon(Icons.file_download),
                            onPressed: () {
                              Directory path = Directory(
                                  context.read<AppProvider>().addressSaveImage);
                              modalBottomSheetListImage(context,
                                  directory: path);
                            }),
                        const Spacer(),
                        const NotifySaveImage(),
                        const SizedBox(width: 5),
                        Consumer<AppProvider>(builder: (context, watch, child) {
                          return Ink(
                              width: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                color: watch.loadSaveImage ||
                                        watch.saveImageSuccess
                                    ? Colors.grey
                                    : Colors.deepPurple[500],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () async {
                                    if (!watch.saveImageSuccess &&
                                        !watch.loadSaveImage) {
                                      saveImage();
                                    }
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: watch.loadSaveImage
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Center(
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            ))));
                        }),
                      ],
                    ),
                  );
                },
              ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              imagePicker();
            },
          ),
          actions: [
            Visibility(
              visible: _bytes != null,
              child: IconButton(
                onPressed: () {
                  controller.cropRectNotifier.value = controller.imageRect;
                  context.read<PicEditProvider>().setAspectRatio(0);
                  controller.resetBorderRadius();
                },
                icon: const Icon(
                  Icons.restore,
                  size: 20,
                ),
              ),
            ),
            const ChangeThemeButton(),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showBottomSheetInfoApp(context: context);
              },
            ),
          ],
        ),
        body: _bytes == null
            ? Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.transparent,
                  onTap: imagePicker,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 100,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Consumer<PicEditProvider>(
                        builder: (context, data, child) {
                          return CropViewArea(
                            bytes: _bytes!,
                            controller: controller,
                            aspectRatio:
                                data.aspectRatio == 0 ? null : data.aspectRatio,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Selector<AppProvider, int>(
                      selector: (context, provider) => provider.tabEditIndex,
                      builder: (context, currentPage, child) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: IndexedStack(
                            key: ValueKey<int>(currentPage),
                            index: currentPage,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SliderRoundCorner(controller: controller),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //  ValueListenableBuilder(valueListenable:controller.cropSizeNotifier, builder: (context, value, child) {
                                  //     return  Row(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: [
                                  //         Row(
                                  //         children: [
                                  //          const RotatedBox(
                                  //             quarterTurns: 1,
                                  //             child: Icon(Icons.height_rounded),
                                  //           ),
                                  //           const SizedBox(width: 10),
                                  //            Text(
                                  //             '${controller.cropRectNotifier.value?.width.toStringAsFixed(2)}',
                                  //            ),
                                  //         ],

                                  //       ),
                                  //       const SizedBox(width: 20),
                                  //       Row(
                                  //         children: [
                                  //          const Icon(Icons.height_rounded),
                                  //           const SizedBox(width: 10),
                                  //             Text(
                                  //               '${controller.cropRectNotifier.value?.height.toStringAsFixed(2)}',
                                  //             ),
                                  //         ],

                                  //       )
                                  //     ],
                                  //   );
                                  //   }),
                                  //   const SizedBox(height: 10),
                                  SizedBox(
                                    height: 35,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            controller.cropRectNotifier.value =
                                                controller.imageRect;
                                            context
                                                .read<PicEditProvider>()
                                                .setAspectRatio(0);
                                          },
                                          icon: const Icon(
                                            Icons.restore,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child:
                                              Selector<PicEditProvider, double>(
                                            selector: (context, data) =>
                                                data.aspectRatio,
                                            builder: (context, data, child) {
                                              return AspectRatioList(
                                                onAspectRatioChanged: (value) {
                                                  context
                                                      .read<PicEditProvider>()
                                                      .setAspectRatio(value);
                                                },
                                                aspectRatio: data,
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ));
  }
}
