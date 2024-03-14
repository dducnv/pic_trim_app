import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pic_trim_app/core/controller.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:pic_trim_app/ui/screens/controller.dart';
import 'package:pic_trim_app/ui/widgets.dart';
import 'package:pic_trim_app/ui/widgets/notify_save_image.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.add_photo_alternate_outlined),
          onPressed: imagePicker,
        ),
        actions: [
          const ChangeThemeButton(),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showBottomSheetInfoApp(context: context);
            },
          ),
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _bytes == null
          ? const SizedBox.shrink()
          : Ink(
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.deepPurple[400],
                borderRadius: BorderRadius.circular(30),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () async {
                  saveImage();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.check, color: Colors.white),
                ),
              ),
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
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.53,
                        child: Consumer<PicEditProvider>(
                          builder: (context, data, child) {
                            return CropViewArea(
                              bytes: _bytes!,
                              controller: controller,
                              aspectRatio: data.aspectRatio == 0
                                  ? null
                                  : data.aspectRatio,
                            );
                          },
                        ),
                      ),
                      SliderRoundCorner(controller: controller),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 35,
                          child: Row(
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
                                  )),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Selector<PicEditProvider, double>(
                                  selector: (context, data) => data.aspectRatio,
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
                      ),
                      const ChangeDirectorSave(),
                      const NotifySaveImage()
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
