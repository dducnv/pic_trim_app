import 'package:flutter/material.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:provider/provider.dart';

class ChangeThemeButton extends StatelessWidget {
const ChangeThemeButton({ super.key });

  @override
  Widget build(BuildContext context){
    return Selector(builder: (context, value, child){
      return IconButton(
        icon: Icon(value == ThemeMode.light ? Icons.nightlight_round : Icons.wb_sunny),
        onPressed: () {
          final provider = Provider.of<AppProvider>(context, listen: false);
          provider.toggleMode();
          
        },
      );
    }, 
    
    selector: (context, AppProvider provider) => provider.themeMode);
  }
}