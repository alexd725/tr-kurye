import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';

import '../main.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/LiveStream.dart';
import '../utils/Extensions/app_common.dart';

enum ThemeModes { SystemDefault, Light, Dark }

class ThemeScreen extends StatefulWidget {
  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    currentIndex = sharedPref.getInt(THEME_MODE_INDEX) ?? AppThemeMode().themeModeLight;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  String _getName(ThemeModes themeModes) {
    switch (themeModes) {
      case ThemeModes.Light:
        return language.light;
      case ThemeModes.Dark:
        return language.dark;
      case ThemeModes.SystemDefault:
        return language.systemDefault;
    }
  }

  Widget _getIcons(BuildContext context, ThemeModes themeModes) {
    switch (themeModes) {
      case ThemeModes.Light:
        return Icon(Icons.light_mode_outlined);
      case ThemeModes.Dark:
        return Icon(Icons.dark_mode);
      case ThemeModes.SystemDefault:
        return Icon(Icons.light_mode_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.theme)),
      body: ListView(
        children: List.generate(
          ThemeModes.values.length,
          (index) {
            return Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  child: Row(
                    children: [
                      _getIcons(context, ThemeModes.values[index]),
                      SizedBox(width: 16),
                      Expanded(child: Text('${_getName(ThemeModes.values[index])}', style: boldTextStyle())),
                      if (index == currentIndex) Icon(Icons.check_circle, color: primaryColor),
                    ],
                  ),
                  onTap: () async{
                    currentIndex = index;
                    if (index == AppThemeMode().themeModeSystem) {
                      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
                    } else if (index == AppThemeMode().themeModeLight) {
                      appStore.setDarkMode(false);
                    } else if (index == AppThemeMode().themeModeDark) {
                      appStore.setDarkMode(true);
                    }
                    sharedPref.setInt(THEME_MODE_INDEX, index);
                    setState(() {});
                    LiveStream().emit('UpdateTheme');
                    Navigator.pop(context);
                  },
                ));
          },
        ),
      ),
    );
  }
}
