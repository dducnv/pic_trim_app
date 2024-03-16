import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pic_trim_app/core/local/local_db.dart';
import 'package:pic_trim_app/core/utils.dart';
import 'package:pic_trim_app/main.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:pic_trim_app/ui/screens/home_screen.dart';
import 'package:provider/provider.dart';

extension HomeScreenController on HomeScreenState {
  Future<void> saveImage() async {
    String address = context.read<AppProvider>().addressSaveImage;
    if (address.isNotEmpty) {
      final byteImage = await controller.cropAndRoundedCorners();
      //dd-MM-yyyy_hh-mm-ss
      final date =
          "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}_${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}";
      final file = File('$address/trim_pic_$date.png');
      await file.writeAsBytes(byteImage);
      await ImageGallerySaver.saveFile(file.path, name: 'trim_pic_$date.png');
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
}
