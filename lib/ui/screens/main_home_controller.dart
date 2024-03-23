import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pic_trim_app/core/local/local_db.dart';
import 'package:pic_trim_app/core/utils.dart';
import 'package:pic_trim_app/main.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:pic_trim_app/ui/screens/main_home.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

extension HomeScreenController on MainHomeState {
  Future<void> saveImage() async {
    Directory address = await getApplicationDocumentsDirectory();

    

    if(address.existsSync()){

      final byteImage = await controller.cropAndRoundedCorners();
      // //dd-MM-yyyy_hh-mm-ss
      final date =
          "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}";
      final file = File('${address.path}/PicTrim_$date.png');
      await file.writeAsBytes(byteImage);
      await GallerySaver.saveImage(file.path, albumName: 'PicTrim');
      await  file.delete();

      //remove file
      // file.delete();
      // ignore: use_build_context_synchronously
      context.read<AppProvider>().setSaveImageSuccess(true);
    }
    
  }

  Future<void> showBottomSheetInfoApp({required BuildContext context}) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              ListTile(
                onTap: () {
                  final Uri params = Uri(
                      scheme: 'mailto',
                      path: 'contact@dducnv.dev',
                    );
                  String url = params.toString();
                  openUrl(url);
                },
                leading: const Icon(Icons.mail_outline),
                title: const Text('Feature Requests and Bug Reports'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                onTap: () => showBottomSheetReadMd(
                    'assets/md/privacy_policy.md',
                    context: context),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Terms of Service'),
                onTap: () => showBottomSheetReadMd(
                    'assets/md/terms_of_service.md',
                    context: context),
              ),

              ListTile(
                leading: const Icon(Icons.star_outline),
                onTap: () {
                  inAppReview.requestReview();
                },
                title: const Text('Rate this app'),
               
              ),
              ListTile(
                onTap: () {
                  showLicensePage(
                      context: context,
                      applicationVersion:
                          "v${packageInfoGlobal.version}+${packageInfoGlobal.buildNumber}",
                      applicationLegalese:
                          "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.");
                },
                title: const Text('App version'),
                subtitle: Text(
                    "v${packageInfoGlobal.version}+${packageInfoGlobal.buildNumber}"),
              ),
              ListTile(
                onTap: () {
                  openUrl('https://dducnv.dev');
                },
                title: const Text('Developer'),
                subtitle: const Text("Duc's App Lab, Ind."),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showBottomSheetReadMd(
    String pathFile, {
    required BuildContext context,
  }) async {
    final String response = await rootBundle.loadString(pathFile);

    return showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                    child: SingleChildScrollView(
                        child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MarkdownBody(data: response),
                ))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> modalBottomSheetListImage(BuildContext context,
      {required Directory directory}) {
    ValueNotifier<List<FileSystemEntity>> listImage = ValueNotifier([]);

    void getListImage() async {
      listImage.value = await directory
          .list()
          .where((event) =>
              event is File &&
              event.path
                      .split("/")[event.path.split("/").length - 1]
                      .split("_")[0] ==
                  "PicTrim" &&
              (event.path.endsWith('.jpg') ||
                  event.path.endsWith('.png') ||
                  event.path.endsWith('.jpeg')))
          .toList();
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
                  return SizedBox(
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
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            children: value.map((FileSystemEntity file) {
                              return file is File
                                  ? InkWell(
                                      onTap: () async {
                                        showDialog(
                                          context: context,
                                          useSafeArea: false,
                                          builder: (_) =>
                                              imageDialog(file.path, _),
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
                                              child: Image.file(
                                                file,
                                                fit: BoxFit.cover,
                                              )),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: IconButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.black45),
                                                shape: MaterialStateProperty
                                                    .all(RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50))),
                                              ),
                                              enableFeedback: true,
                                              color: Colors.red[700],
                                              onPressed: () async {
                                                //popup confirm delete
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text('Delete'),
                                                      content: const Text(
                                                          'Are you sure?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            file.delete();
                                                            getListImage();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Delete'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
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
                                                shape: MaterialStateProperty
                                                    .all(RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50))),
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
                                    )
                                  : const SizedBox.shrink();
                            }).toList(),
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
                  "/${path.split('/')[path.split('/').length - 3]}/${path.split('/')[path.split('/').length - 2]}/${path.split('/')[path.split('/').length - 1]}",
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

