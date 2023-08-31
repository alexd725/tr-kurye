import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/CityListModel.dart';
import '../utils/Extensions/shared_pref.dart';
import '../language/AppLocalizations.dart';
import '../language/BaseLanguage.dart';
import '../main.dart';
import '../models/CountryListModel.dart';
import '../models/LanguageDataModel.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import 'package:mobx/mobx.dart';

import '../utils/Extensions/constants.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isLoading = false;

  @observable
  List<CountryData> countryList = ObservableList<CountryData>();

  @observable
  int allUnreadCount = 0;

  @observable
  bool isDarkMode = false;

  @observable
  AppBarTheme appBarTheme = AppBarTheme();

  @observable
  String selectedLanguage = "en";

  @observable
  int selectedMenuIndex = 0;

  @observable
  String userProfile = '';

  @observable
  String currencyCode = "INR";

  @observable
  String currencySymbol = "₹";

  @observable
  String currencyPosition = CURRENCY_POSITION_LEFT;

  @observable
  bool isMenuExpanded = true;

  @observable
  int isShowVehicle = 0;

  @observable
  String vehicleImage = '';

  @action
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await setValue(IS_LOGGED_IN, val);
  }

  @action
  Future<void> setLoading(bool value) async {
    isLoading = value;
  }

  @action
  void setAllUnreadCount(int val) {
    allUnreadCount = val;
  }

  @action
  void setSelectedMenuIndex(int val) {
    selectedMenuIndex = val;
  }

  @action
  Future<void> setUserProfile(String val, {bool isInitializing = false}) async {
    userProfile = val;
    if (!isInitializing) await setValue(USER_PROFILE_PHOTO, val);
  }
  @action
  Future<void> setVehicleImage(String val, {bool isInitializing = false}) async {
    vehicleImage = val;
    if (!isInitializing) await setValue(VEHICLE_IMAGE, val);
  }

  @action
  Future<void> setCurrencyCode(String val) async {
    currencyCode = val;
  }

  @action
  Future<void> setCurrencySymbol(String val) async {
    currencySymbol = val;
  }

  @action
  Future<void> setCurrencyPosition(String val) async {
    currencyPosition = val;
  }

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = scaffoldSecondaryDark;
      //shadowColorGlobal = Colors.white12;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
    }
    appBarTheme = AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              appStore.isDarkMode ? Brightness.dark : Brightness.light),
    );
  }

  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    selectedLanguageDataModel =
        getSelectedLanguageModel(defaultLanguage: default_Language);
    selectedLanguage =
        getSelectedLanguageModel(defaultLanguage: default_Language)!
            .languageCode!;

    setValue(SELECTED_LANGUAGE_CODE, aCode);

    if (context != null) language = BaseLanguage.of(context)!;
    language = await AppLocalizations().load(Locale(selectedLanguage));
  }

  @action
  void setExpandedMenu(bool val) {
    isMenuExpanded = val;
  }

  @action
  void showVehicleDialog(int val) {
    isShowVehicle = val;
  }


}
