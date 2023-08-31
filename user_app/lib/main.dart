import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'AppTheme.dart';
import 'main/models/CreditCardProvider.dart';
import 'main/models/models.dart';
import 'main/screens/SplashScreen.dart';
import 'main/services/ChatMessagesService.dart';
import 'main/services/NotificationService.dart';
import 'main/services/UserServices.dart';
import 'main/language/AppLocalizations.dart';
import 'main/language/BaseLanguage.dart';
import 'main/models/FileModel.dart';
import 'main/screens/NoInternetScreen.dart';
import 'main/store/AppStore.dart';
import 'main/utils/Common.dart';
import 'main/utils/Constants.dart';
import 'main/utils/DataProviders.dart';

AppStore appStore = AppStore();
late BaseLanguage language;
UserService userService = UserService();
ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();
late List<FileModel> fileList = [];
bool isCurrentlyOnNoInternet = false;
late StreamSubscription<Position> positionStream;

bool mIsEnterKey = false;
String mSelectedImage = "assets/default_wallpaper.png";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCX8lH_PMjT-ownBP4Udtjt0TmUkZs7N0s",
        authDomain: "flutter-app-a8a2d.firebaseapp.com",
        projectId: "flutter-app-a8a2d",
        storageBucket: "flutter-app-a8a2d.appspot.com",
        messagingSenderId: "481944169516",
        appId: "1:481944169516:web:0257d4fff5e9088d037589",
        measurementId: "G-Y0DCLDDQN5"
    )
  );

  await initialize(aLocaleLanguageList: languageList());

  appStore.setLogin(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
  appStore.setUserEmail(getStringAsync(USER_EMAIL), isInitialization: true);
  appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: defaultLanguage));
  FilterAttributeModel? filterData =
      FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
  appStore.setFiltering(filterData.orderStatus != null ||
      !filterData.fromDate.isEmptyOrNull ||
      !filterData.toDate.isEmptyOrNull);

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == appThemeMode.themeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == appThemeMode.themeModeDark) {
    appStore.setDarkMode(true);
  }

 //  await OneSignal.shared.setAppId(mOneSignalAppId);
 //
 // saveOneSignalPlayerId();
 //  FlutterError.onError = (FlutterErrorDetails details) async {
 //    if (kDebugMode) {
 //      // In debug mode, print the error to the console
 //      FlutterError.dumpErrorToConsole(details);
 //    } else {
 //      // In release mode, report the error to Firebase Crashlytics
 //      await FirebaseCrashlytics.instance.recordFlutterError;
 //    }
 //  };
  runApp(MyApp());
}

const iOSLocalizedLabels = false;

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((e) {
      if (e == ConnectivityResult.none) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        push(NoInternetScreen());
      } else {
        if (isCurrentlyOnNoInternet) {
          pop();
          isCurrentlyOnNoInternet = false;
          toast(language.internetIsConnected);
        }
        log('connected');
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    _connectivitySubscription.cancel();
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MultiProvider(
          providers: [
            ChangeNotifierProvider<CreditCardProvider>(
                create: (_) => CreditCardProvider()),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            builder: (context, child) {
              return ScrollConfiguration(
                behavior: MyBehavior(),
                child: child!,
              );
            },
            title: language.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
            supportedLocales: LanguageDataModel.languageLocales(),
            localizationsDelegates: [
              AppLocalizations(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            localeResolutionCallback: (locale, supportedLocales) => locale,
            locale: Locale(
                appStore.selectedLanguage.validate(value: defaultLanguage)),
          ));
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
