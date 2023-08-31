import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../main.dart';
import 'DashboardScreen.dart';
import 'SignInScreen.dart';

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
    Future.delayed(
      Duration(seconds: 2),
      () {
        if (appStore.isLoggedIn) {
          launchScreen(context, DashboardScreen(), isNewTask: true);
        } else {
          launchScreen(context, SignInScreen(), isNewTask: true);
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(defaultRadius),
              child: Image.asset('assets/app_logo_primary.png', height: 90, width: 90, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            Text(language.appName, style: boldTextStyle(size: 20)),
          ],
        ),
      ),
    );
  }
}
