import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pic_trim_app/core/controller.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:pic_trim_app/ui/screens/controller.dart';
import 'package:pic_trim_app/ui/widgets.dart';
import 'package:pic_trim_app/ui/widgets/notify_save_image.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Uint8List? _bytes;
  late PicTrimController controller;

  @override
  void initState() {
    super.initState();
    controller = PicTrimController();
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkModeEnabled = Theme.of(context).brightness == Brightness.dark;
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
      floatingActionButton: ValueListenableBuilder(
          valueListenable: controller.borderRadiusNotifier,
          builder: (context, borderRadius, child) {
            return ValueListenableBuilder(
                valueListenable: controller.cropRectNotifier,
                builder: (context, cropRect, child) {
                  bool isInableSaveButton = _bytes != null &&
                      (cropRect != controller.imageRect || borderRadius > 0);
                  return Ink(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: isInableSaveButton
                          ? Colors.deepPurple[400]
                          : darkModeEnabled
                              ? Colors.grey[800]
                              : Colors.grey[400],
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
                  );
                });
          }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.53,
              child: _bytes != null
                  ? Consumer<PicEditProvider>(
                      builder: (context, data, child) {
                        return CropViewArea(
                          bytes: _bytes!,
                          controller: controller,
                          aspectRatio:
                              data.aspectRatio == 0 ? null : data.aspectRatio,
                        );
                      },
                    )
                  : Center(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: imagePicker,
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 100,
                          color: Colors.grey[500],
                        ),
                      ),
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
        ),
      ),
    );
  }
}
