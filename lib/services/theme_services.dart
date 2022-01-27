//d
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class ThemeServices {
  final GetStorage _box = GetStorage();
  final _key = 'isDarkMode';

  bool _loadThemeFromBox() => _box.read<bool>(_key) ?? false;

  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  ThemeMode get theme => _loadThemeFromBox()
      ? ThemeMode.light
      : ThemeMode
          .system; //هي حطيتها مشان وقت اطلع من التطبيق وارجع فوت ياخد القيمة تبع الثيم اللي كانت قبل مااطلع
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToBox(!_loadThemeFromBox());
  }
}
