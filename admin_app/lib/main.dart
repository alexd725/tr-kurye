import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:mightydelivery_admin_app/AppTheme.dart';
import 'package:mightydelivery_admin_app/language/BaseLanguage.dart';
import 'package:mightydelivery_admin_app/models/LanguageDataModel.dart';
import 'package:mightydelivery_admin_app/screens/SplashScreen.dart';
import 'package:mightydelivery_admin_app/store/AppStore.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Common.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/DataProvider.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/AuthSertvices.dart';
import 'services/UserServices.dart';
import 'language/AppLocalizations.dart';

AppStore appStore = AppStore();
//late SharedPreferences sharedPref;
AuthServices authService = AuthServices();
UserService userService = UserService();
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
Color defaultLoaderBgColorGlobal = Colors.white;

late SharedPreferences sharedPref;
late BaseLanguage language;

final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;

List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;

Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: default_Language);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();

  await initialize(aLocaleLanguageList: languageList());
  appStore.setLanguage(default_Language);

  appStore.setLoggedIn(sharedPref.getBool(IS_LOGGED_IN) ?? false,
      isInitializing: true);
  appStore.setUserProfile(sharedPref.getString(USER_PROFILE_PHOTO).validate(),
      isInitializing: true);

  int themeModeIndex =
      sharedPref.getInt(THEME_MODE_INDEX) ?? AppThemeMode().themeModeLight;
  if (themeModeIndex == AppThemeMode().themeModeDark) {
    appStore.setDarkMode(true);
  } else if (themeModeIndex == AppThemeMode().themeModeLight) {
    appStore.setDarkMode(false);
  }

  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await OneSignal.shared.setAppId(mOneSignalAppIdAdmin);
  saveOneSignalPlayerId();

  runApp(const MyApp());
}

const iOSLocalizedLabels = false;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: (Platform.isAndroid || Platform.isIOS)
                  ? MyBehavior()
                  : ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch,
                      },
                    ),
              child: child!,
            );
          },
          debugShowCheckedModeBanner: false,
          title: language.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(),
          supportedLocales: LanguageDataModel.languageLocales(),
          localizationsDelegates: [
            AppLocalizations(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            MonthYearPickerLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) => locale,
          locale: Locale(
              appStore.selectedLanguage.validate(value: default_Language)));
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
