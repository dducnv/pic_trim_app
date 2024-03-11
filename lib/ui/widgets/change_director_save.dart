import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pic_trim_app/providers/app_provider.dart';
import 'package:provider/provider.dart';

class ChangeDirectorSave extends StatelessWidget {
  const ChangeDirectorSave({super.key});

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
                child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(value.addressSaveImage),
            )),
          ],
        ),
      );
    });
  }
}
