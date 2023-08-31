import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../delivery/screens/DeliveryDashBoard.dart';
import '../../main.dart';
import '../../user/screens/DashboardScreen.dart';
import '../components/UserCitySelectScreen.dart';
import '../models/CityListModel.dart';
import '../models/CreditCardProvider.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import 'LoginScreen.dart';
import 'WalkThroughScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    setStatusBarColor(appStore.isDarkMode ? Colors.black : Colors.white,
        statusBarBrightness:
            appStore.isDarkMode ? Brightness.light : Brightness.dark);
    Future.delayed(
      Duration(seconds: 1),
      () async {
        if (appStore.isLoggedIn && getIntAsync(USER_ID) != 0) {
          await getUserDetail(getIntAsync(USER_ID)).then((value) {
            /*() {
        if (appStore.isLoggedIn && getIntAsync(USER_ID) != 0) {
          getUserDetail(getIntAsync(USER_ID)).then((value) {*/
            if (value.deletedAt != null) {
              logout(context);
            } else {
              if (CityModel.fromJson(getJSONAsync(CITY_DATA))
                  .name
                  .validate()
                  .isNotEmpty) {
                if (getStringAsync(USER_TYPE) == CLIENT) {
                  DashboardScreen().launch(context, isNewTask: true);
                } else if (getStringAsync(USER_TYPE) == CORPORATE) {
                  DashboardScreen().launch(context, isNewTask: true);
                } else {
                  DeliveryDashBoard().launch(context, isNewTask: true);
                }
              } else {
                UserCitySelectScreen().launch(context);
              }
            }
          }).catchError((e) {
            log(e);
          });
        } else {
          if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
            WalkThroughScreen().launch(context, isNewTask: true);
          } else {
            LoginScreen().launch(context, isNewTask: true);
          }
        }
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/app_logo.jpg',
                    height: 80, width: 80, fit: BoxFit.fill)
                .cornerRadiusWithClipRRect(defaultRadius),
            16.height,
            Text(language.appName,
                style: boldTextStyle(size: 20), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
