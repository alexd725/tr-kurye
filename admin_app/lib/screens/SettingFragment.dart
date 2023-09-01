import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/screens/ChangePasswordScreen.dart';
import 'package:mightydelivery_admin_app/screens/DocumentScreen.dart';
import 'package:mightydelivery_admin_app/screens/ParcelTypeScreen.dart';
import 'package:mightydelivery_admin_app/screens/UsersInvoices.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../utils/Extensions/LiveStream.dart';
import '../utils/Common.dart';
import 'AllDriversInvoces.dart';
import 'EditProfileScreen.dart';
import 'ExtraChargesScreen.dart';
import 'LanguageScreen.dart';
import 'PaymentGatewayScreen.dart';
import 'ThemeScreen.dart';
import 'CityScreen.dart';
import 'CountryScreen.dart';
import 'AppSettingsScreen.dart';
import 'DeliveryPersonDocumentScreen.dart';
import 'corporate_users.dart';
import 'VehicleScreen.dart';
import 'WithdrawalRequestScreen.dart';

class SettingFragment extends StatefulWidget {
  @override
  SettingFragmentState createState() => SettingFragmentState();
}

class SettingFragmentState extends State<SettingFragment> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController notificationController = ScrollController();

  Map<String, dynamic> notificationSettings = {};
  int? settingId;
  bool isAutoAssign = false;

  TextEditingController distanceController = TextEditingController();
  String? distanceUnitType;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(init);
  }

  void init() async {
    LiveStream().on('UpdateTheme', (p0) {
      setState(() {});
    });
    LiveStream().on('UpdateLanguage', (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget settingWidget(String? title, Function? onTap) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          onTap!();
        },
        child: Row(
          children: [
            Expanded(child: Text(title!, style: boldTextStyle())),
            Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Stack(
        children: [
          SingleChildScrollView(
            /*return Observer(builder: (context) {
      return SingleChildScrollView(*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.15)),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage('${appStore.userProfile}'),
                              fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${sharedPref.getString(NAME) ?? ""}',
                                    style: boldTextStyle()),
                                outlineActionIcon(
                                    context, Icons.edit, primaryColor,
                                    () async {
                                  bool? res = await launchScreen(
                                      context, EditProfileScreen());
                                  if (res ?? false) {
                                    setState(() {});
                                  }
                                }),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(sharedPref.getString(USER_EMAIL) ?? "",
                                style: secondaryTextStyle(size: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                settingWidget(language.country, () {
                  launchScreen(context, CountryScreen());
                }),
                settingWidget(language.city, () {
                  launchScreen(context, CityScreen());
                }),
                settingWidget(language.vehicle, () {
                  launchScreen(context, VehicleScreen());
                }),
                settingWidget("Corporate Users", () {
                  launchScreen(context, CorporateListFragment());
                }),
                settingWidget(language.extraCharges, () {
                  launchScreen(context, ExtraChargesScreen());
                }),
                settingWidget(language.parcelType, () {
                  launchScreen(context, ParcelTypeScreen());
                }),
                // settingWidget("All Drivers Invoices", () {
                //   launchScreen(context, DriversInvoices());
                // }),
                // settingWidget("All Users Invoices", () {
                //   launchScreen(context, UsersInvoices());
                // }),
                settingWidget(language.paymentGateway, () {
                  launchScreen(context, PaymentGatewayScreen());
                }),
                settingWidget(language.document, () {
                  launchScreen(context, DocumentScreen());
                }),
                settingWidget(language.deliveryPersonDocuments, () {
                  launchScreen(context, DeliveryPersonDocumentScreen());
                }),
                settingWidget(language.withdrawRequest, () {
                  launchScreen(context, WithdrawalRequestScreen());
                }),
                Divider(thickness: 8, color: Colors.grey.withOpacity(0.15)),
                settingWidget(language.appSetting, () {
                  launchScreen(context, AppSettingsScreen());
                }),
                settingWidget(language.changePassword, () {
                  launchScreen(context, ChangePasswordScreen());
                }),
                settingWidget(language.language, () {
                  launchScreen(context, LanguageScreen());
                }),
                settingWidget(language.theme, () {
                  launchScreen(context, ThemeScreen());
                }),
                Divider(thickness: 9, color: Colors.grey.withOpacity(0.15)),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: GestureDetector(
                    child: Text(language.logout,
                        style: boldTextStyle(color: Colors.red)),
                    onTap: () {
                      logOutData(context: context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Visibility(visible: appStore.isLoading, child: loaderWidget()),
        ],
      );
    });
  }
}
