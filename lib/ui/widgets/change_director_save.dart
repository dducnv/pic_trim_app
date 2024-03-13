import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pic_trim_app/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ChangeDirectorSave extends StatefulWidget {
  const ChangeDirectorSave({super.key});

  @override
  State<ChangeDirectorSave> createState() => _ChangeDirectorSaveState();
}

class _ChangeDirectorSaveState extends State<ChangeDirectorSave> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, value, child) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                String? selectedDirectory =
                    await FilePicker.platform.getDirectoryPath();
                if (selectedDirectory != null) {
                  value.setAddressSaveImage(selectedDirectory);
                }
              },
              icon: const Icon(Icons.folder),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: InkWell(
              onTap: () async {
                if (await Directory(
                  value.addressSaveImage,
                ).exists()) {
                  Directory directory = Directory(value.addressSaveImage);

                  // ignore: use_build_context_synchronously
                  modalBottomSheetListImage(context, directory: directory);
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thư mục không tồn tại'),
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(value.addressSaveImage),
              ),
            )),
          ],
        ),
      );
    });
  }

  Future<void> modalBottomSheetListImage(BuildContext context,
      {required Directory directory}) {
    ValueNotifier<List<FileSystemEntity>> listImage = ValueNotifier([]);

    void getListImage() async {
      listImage.value = await directory.list().toList();
    }

    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        getListImage();
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 50,
                height: 5,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: listImage,
                builder: (context, value, child) {
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: value.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 100,
                                color: Colors.grey[400],
                              ),
                            )
                          : GridView.count(
                              padding: const EdgeInsets.all(20),
                              shrinkWrap: value.length > 2,
                              physics: value.length > 2
                                  ? const NeverScrollableScrollPhysics()
                                  : const AlwaysScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 2,
                              children: value.map((FileSystemEntity file) {
                                return InkWell(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      useSafeArea: false,
                                      builder: (_) => imageDialog(file.path, _),
                                    );
                                  },
                                  onLongPress: () async {
                                    final result = await Share.shareXFiles(
                                      [XFile(file.path)],
                                      text: 'Image From PicTrim App',
                                    );
                                    if (result.status ==
                                        ShareResultStatus.success) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Shared'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: file is File &&
                                                (file.path.endsWith('.jpg') ||
                                                    file.path
                                                        .endsWith('.png') ||
                                                    file.path.endsWith('.jpeg'))
                                            ? Image.file(
                                                file,
                                                fit: BoxFit.cover,
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: IconButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black45),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50))),
                                          ),
                                          enableFeedback: true,
                                          color: Colors.red[700],
                                          onPressed: () async {
                                            await file.delete();
                                            getListImage();
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: IconButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black45),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50))),
                                          ),
                                          enableFeedback: true,
                                          color: Colors.white,
                                          onPressed: () async {
                                            final result =
                                                await Share.shareXFiles([
                                              XFile(file.path)
                                            ], text: 'Image From PicTrim App');
                                            if (result.status ==
                                                ShareResultStatus.success) {
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text('Shared'),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.share,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget imageDialog(path, context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  path.split('/').last,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
