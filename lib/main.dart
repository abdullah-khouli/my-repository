import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:to_do_app/db/db_helper.dart';
import 'services/notification_services.dart';
import 'package:to_do_app/services/theme_services.dart';
import 'package:to_do_app/ui/theme.dart';

import 'ui/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //هون ضروري كتير انو نحط اقواس لانو اذا ما حطيت بصير خطأ بالتهيئة
  await NotifyHelper().initializeNotification();
  NotifyHelper().requestIOSPermissions();
  await DBHelper.initDb();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: Themes.Light,
      darkTheme: Themes.Dark,
      themeMode: ThemeServices().theme,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
