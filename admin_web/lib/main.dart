import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_delivery_admin/utils/RouteGenerator.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'network/RestApis.dart';
import 'screens/Admin/AdminHomeScreen.dart';
import '../screens/Client/DashboardScreen.dart';
import '../services/AuthServices.dart';
import '../services/ChatMessagesService.dart';
import '../services/NotificationService.dart';
import '../services/UserServices.dart';
import '../store/AppStore.dart';
import '../store/ClientStore.dart';
import '../utils/Extensions/common.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../appTheme.dart';
import '../language/AppLocalizations.dart';
import '../language/BaseLanguage.dart';
import '../models/LanguageDataModel.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/DataProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/Client/BuilderResponse.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

AppStore appStore = AppStore();
ClientStore clientStore = ClientStore();
BuilderResponse builderResponse = BuilderResponse();
AuthServices authService = AuthServices();
UserService userService = UserService();
ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();

final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;

late SharedPreferences sharedPref;

late BaseLanguage language;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;

PageRouteAnimation? pageRouteAnimationGlobal;
Duration pageRouteTransitionDurationGlobal = 400.milliseconds;

Future<String> loadBuilderData() async {
  return await rootBundle.loadString('assets/builder.json');
}

Future<BuilderResponse> loadContent() async {
  String jsonString = await loadBuilderData();
  final jsonResponse = json.decode(jsonString);
  return BuilderResponse.fromJson(jsonResponse);
}

Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel = getSelectedLanguageModel(defaultLanguage: default_Language);
}

void main() async {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();
  builderResponse = await loadContent();

  await Firebase.initializeApp(options: firebaseOptions);

  await initialize(aLocaleLanguageList: languageList());

  appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: default_Language));
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN), isInitializing: true);
  appStore.setUserProfile(getStringAsync(USER_PROFILE_PHOTO), isInitializing: true);

  FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
  clientStore.setFiltering(filterData.orderStatus.toString() != "null" || filterData.fromDate.toString() != "null" || filterData.toDate.toString() != "null");

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
  if(appStore.isLoggedIn){
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? defaultCurrencyCode);
      appStore.setCurrencySymbol(value.currency ?? defaultCurrencySymbol);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.isShowVehicle = value.isVehicleInOrder ?? 0;
    }).catchError((error) {
      log(error.toString());
    });
  }
  saveFcmTokenId();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
            ),
            child: child!,
          );
        },
        initialRoute: (getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN) ? AdminHomeScreen.route : DashboardScreen.route,
        routes: route,
        onGenerateRoute: onGenerateRoute,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: language.app_name,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          MonthYearPickerLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguage),
        scrollBehavior: SBehavior(),
      );
    });
  }
}
