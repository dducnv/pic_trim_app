import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pic_trim_app/core/local/local_db.dart';
import 'package:pic_trim_app/core/local_pref.dart';
import 'package:pic_trim_app/firebase_options.dart';
import 'package:pic_trim_app/provider.dart';
import 'package:pic_trim_app/ui/screens/main_home.dart';
import 'package:provider/provider.dart';

bool isDarkMode = false;

final InAppReview inAppReview = InAppReview.instance;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var getThemeStorage = await PrefHelper().readBool(PrefKeys.isDarkMode);
  if (getThemeStorage == null) {
    await PrefHelper().saveBool(PrefKeys.isDarkMode, false);
    isDarkMode = false;
  } else {
    isDarkMode = getThemeStorage;
  }
  packageInfoGlobal = await PackageInfo.fromPlatform();
  setSettings();
  runApp(const MyApp());
}

setSettings() async {
  numberLogins = await PrefHelper().readInt(PrefKeys.numberLogin) ?? 0;
  await PrefHelper().saveInt(PrefKeys.numberLogin, numberLogins + 1);

  if (!kIsWeb) {
    if (numberLogins == 6 || numberLogins == 15 || numberLogins == 25) {
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(create: (context) => PicEditProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (BuildContext context, AppProvider value, Widget? child) {
          return MaterialApp(
              title: 'PicTrim',
              themeMode: value.themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              builder: (context, child) => SafeArea(child: child!),
              debugShowCheckedModeBanner: false,
              home: const MainHome());
        },
      ),
    );
  }
}
