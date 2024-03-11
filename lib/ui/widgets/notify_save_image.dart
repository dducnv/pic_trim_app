import 'package:flutter/material.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:provider/provider.dart';

class NotifySaveImage extends StatelessWidget {
const NotifySaveImage({ super.key });

  @override
  Widget build(BuildContext context){
    return  Selector(builder: (context, value, child){
      return Center(
        child: AnimatedOpacity(
            opacity: value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: const Text(
              'Image saved successfully!',
              style: TextStyle(color: Colors.green, fontSize: 12),
            ),
          ),
      );
    }, selector: (context, AppProvider provider) => provider.saveImageSuccess);
      
  }
}