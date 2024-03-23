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
            duration: const Duration(milliseconds: 300),
            child:const Icon(
              Icons.check,
              color: Colors.green,
              size: 25,
            ),
          ),
      );
    }, selector: (context, AppProvider provider) => provider.saveImageSuccess);
      
  }
}