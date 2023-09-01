import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/AppSettingModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Common.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/DataProvider.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../utils/Extensions/app_textfield.dart';

class AppSettingsScreen extends StatefulWidget {
  @override
  AppSettingsScreenState createState() => AppSettingsScreenState();
}

class AppSettingsScreenState extends State<AppSettingsScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController notificationController = ScrollController();

  Map<String, dynamic> notificationSettings = {};
  int? settingId;
  bool isAutoAssign = false;
  bool isOtpVerifyOnPickupDelivery = true;

  TextEditingController distanceController = TextEditingController();
  TextEditingController chargeController = TextEditingController();
  String? distanceUnitType;

  TextEditingController currencySymbolController = TextEditingController();

  List<String> currencyPositionList = [
    CURRENCY_POSITION_LEFT,
    CURRENCY_POSITION_RIGHT
  ];
  String selectedCurrencyPosition = CURRENCY_POSITION_LEFT;

  String? currencyCode;
  String? currencySymbol;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(init);
  }

  void init() async {
    appStore.setLoading(true);
    await getAppSetting().then((value) {
      notificationSettings = value.notificationSettings!.toJson();
      isAutoAssign = value.autoAssign == 1;
      isOtpVerifyOnPickupDelivery = value.isOtpVerifyOnPickupDelivery == 1;
      distanceController.text = '${value.distance ?? ''}';
      distanceUnitType = value.distanceUnit;
      settingId = value.id!;
      currencySymbolController.text = value.currency ?? currencySymbolDefault;
      currencyCode = value.currencyCode;
      currencySymbol = value.currency;
      selectedCurrencyPosition =
          value.currencyPosition ?? CURRENCY_POSITION_LEFT;
      chargeController.text = value.carryPackagesCharges.toString();
      appStore.isShowVehicle = value.isVehicleInOrder!;
      log('-------------------------${appStore.isShowVehicle}');
      appStore.setLoading(false);
      setState(() {});
    }).catchError((error) {
      notificationSettings = getNotificationSetting();
      log("$error");
      setState(() {});
      appStore.setLoading(false);
    });
  }

  Future<void> saveAppSetting() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      //if (distanceUnitType == null && isAutoAssign) return toast(language.pleaseSelectDistanceUnit);
      if (distanceUnitType == null &&
              isAutoAssign &&
              (appStore.isShowVehicle == 1)
          ? true
          : false) return toast(language.pleaseSelectDistanceUnit);
      appStore.setLoading(true);
      Map req = isAutoAssign
          ? {
              "id": settingId != null ? settingId : "",
              "notification_settings":
                  NotificationSettings.fromJson(notificationSettings).toJson(),
              "auto_assign": isAutoAssign ? 1 : 0,
              "distance_unit": distanceUnitType,
              "distance": distanceController.text,
              "otp_verify_on_pickup_delivery":
                  isOtpVerifyOnPickupDelivery ? 1 : 0,
              "currency": currencySymbol ?? currencySymbolDefault,
              "currency_code": currencyCode ?? currencyCodeDefault,
              "currency_position": selectedCurrencyPosition,
              "carry_packages_charge": chargeController.text,
              "is_vehicle_in_order": appStore.isShowVehicle,
            }
          : {
              "id": settingId != null ? settingId : "",
              "auto_assign": isAutoAssign ? 1 : 0,
              "notification_settings":
                  NotificationSettings.fromJson(notificationSettings).toJson(),
              "otp_verify_on_pickup_delivery":
                  isOtpVerifyOnPickupDelivery ? 1 : 0,
              "currency": currencySymbol ?? currencySymbolDefault,
              "currency_code": currencyCode ?? currencyCodeDefault,
              "currency_position": selectedCurrencyPosition,
              "carry_packages_charge": chargeController.text,
              "is_vehicle_in_order": appStore.isShowVehicle,
            };
      await setNotification(req).then((value) {
        appStore.setLoading(false);
        settingId = value.data!.id;
        appStore.setCurrencyCode(currencyCode ?? currencyCodeDefault);
        appStore.setCurrencySymbol(currencySymbol ?? currencySymbolDefault);
        appStore.setCurrencyPosition(selectedCurrencyPosition);
        toast(value.message);
        Navigator.pop(context);
      }).catchError((error) {
        appStore.setLoading(false);
        log(error);
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.appSetting)),
      body: Observer(
        builder: (context) {
          return Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                controller: notificationController,
                padding: EdgeInsets.all(16),
                child: notificationSettings.isNotEmpty
                    ? Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: Colors.grey.withOpacity(0.3)),
                                color: appStore.isDarkMode
                                    ? scaffoldColorDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SwitchListTile(
                                    value: isAutoAssign,
                                    onChanged: (value) {
                                      isAutoAssign = value;
                                      setState(() {});
                                    },
                                    title: Text(language.orderAutoAssign,
                                        style: primaryTextStyle()),
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    inactiveTrackColor: appStore.isDarkMode
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                  if (isAutoAssign)
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(language.distance,
                                              style: primaryTextStyle()),
                                          SizedBox(height: 8),
                                          AppTextField(
                                            controller: distanceController,
                                            textFieldType: TextFieldType.OTHER,
                                            decoration: commonInputDecoration(),
                                            textInputAction:
                                                TextInputAction.next,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp('[0-9 .]')),
                                            ],
                                            validator: (s) {
                                              if (s!.trim().isEmpty)
                                                return language
                                                    .fieldRequiredMsg;
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          Text(language.distanceUnit,
                                              style: primaryTextStyle()),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  value: DISTANCE_UNIT_KM,
                                                  title: Text(DISTANCE_UNIT_KM,
                                                      style:
                                                          primaryTextStyle()),
                                                  groupValue: distanceUnitType,
                                                  onChanged: (value) {
                                                    distanceUnitType = value;
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  value: DISTANCE_UNIT_MILE,
                                                  title: Text(
                                                      DISTANCE_UNIT_MILE,
                                                      style:
                                                          primaryTextStyle()),
                                                  groupValue: distanceUnitType,
                                                  onChanged: (value) {
                                                    distanceUnitType = value;
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  SwitchListTile(
                                    value: isOtpVerifyOnPickupDelivery,
                                    onChanged: (value) {
                                      isOtpVerifyOnPickupDelivery = value;
                                      setState(() {});
                                    },
                                    title: Text(
                                        language
                                            .otpVerificationOnPickupDelivery,
                                        style: primaryTextStyle()),
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    inactiveTrackColor: appStore.isDarkMode
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Carry Packages Charge",
                                            style: primaryTextStyle()),
                                        SizedBox(height: 8),
                                        AppTextField(
                                          controller: chargeController,
                                          textFieldType: TextFieldType.OTHER,
                                          decoration: commonInputDecoration(),
                                          textInputAction: TextInputAction.next,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp('[0-9 .]')),
                                          ],
                                          validator: (s) {
                                            if (s!.trim().isEmpty)
                                              return language.fieldRequiredMsg;
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                  color: appStore.isDarkMode
                                      ? scaffoldColorDark
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                  boxShadow: commonBoxShadow()),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.currencySetting,
                                      style: boldTextStyle()),
                                  SizedBox(height: 16),
                                  Text(language.currencyPosition,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  DropdownButtonFormField(
                                    dropdownColor: Theme.of(context).cardColor,
                                    decoration: commonInputDecoration(),
                                    value: selectedCurrencyPosition,
                                    items: currencyPositionList
                                        .map<DropdownMenuItem<String>>((item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                            '${item[0].toUpperCase()}${item.substring(1)}',
                                            style: primaryTextStyle()),
                                      );
                                    }).toList(),
                                    onChanged: (String? value) {
                                      selectedCurrencyPosition = value!;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  Text(language.currencySymbol,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  AppTextField(
                                    controller: currencySymbolController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.15),
                                      counterText: '',
                                      suffixIcon: GestureDetector(
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Text(language.pick,
                                                    style: primaryTextStyle(
                                                        color: primaryColor))),
                                          ),
                                          onTap: () {
                                            showCurrencyPicker(
                                              theme: CurrencyPickerThemeData(
                                                  bottomSheetHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.8,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .cardColor,
                                                  titleTextStyle:
                                                      primaryTextStyle(
                                                          size: 17),
                                                  subtitleTextStyle:
                                                      primaryTextStyle(
                                                          size: 15)),
                                              context: context,
                                              showFlag: true,
                                              showSearchField: true,
                                              showCurrencyName: true,
                                              showCurrencyCode: true,
                                              onSelect: (Currency currency) {
                                                currencySymbolController.text =
                                                    currency.symbol;
                                                currencyCode = currency.code;
                                                currencySymbol =
                                                    currency.symbol;
                                                setState(() {});
                                              },
                                            );
                                          }),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              style: BorderStyle.none),
                                          borderRadius: BorderRadius.circular(
                                              defaultRadius)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: primaryColor),
                                          borderRadius: BorderRadius.circular(
                                              defaultRadius)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                          borderRadius: BorderRadius.circular(
                                              defaultRadius)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.red),
                                          borderRadius: BorderRadius.circular(
                                              defaultRadius)),
                                    ),
                                    textFieldType: TextFieldType.OTHER,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: Colors.grey.withOpacity(0.3)),
                                color: appStore.isDarkMode
                                    ? scaffoldColorDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.notificationSetting,
                                      style: boldTextStyle()),
                                  SizedBox(height: 16),
                                  Container(
                                    color: primaryColor.withOpacity(0.2),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Text(language.type,
                                                textAlign: TextAlign.start,
                                                style:
                                                    boldTextStyle(size: 14))),
                                        Expanded(
                                            child: Text(language.oneSingle,
                                                textAlign: TextAlign.center,
                                                style:
                                                    boldTextStyle(size: 14))),
                                        Expanded(
                                            child: Text(
                                                '${language.firebase} ${language.forAdmin}',
                                                textAlign: TextAlign.center,
                                                style:
                                                    boldTextStyle(size: 14))),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Column(
                                    children:
                                        notificationSettings.entries.map((e) {
                                      return Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  orderSettingStatus(e.key) ??
                                                      '',
                                                  style: primaryTextStyle())),
                                          Expanded(
                                            child: Checkbox(
                                              value: e.value[
                                                      "IS_ONESIGNAL_NOTIFICATION"] ==
                                                  "1",
                                              onChanged: (val) {
                                                Notifications notify =
                                                    Notifications.fromJson(
                                                        notificationSettings[
                                                            e.key]);
                                                if (val ?? false) {
                                                  notify.isOnesignalNotification =
                                                      "1";
                                                } else {
                                                  notify.isOnesignalNotification =
                                                      "0";
                                                }
                                                notificationSettings[e.key] =
                                                    notify.toJson();
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: Checkbox(
                                              value: e.value[
                                                      "IS_FIREBASE_NOTIFICATION"] ==
                                                  "1",
                                              onChanged: (val) {
                                                Notifications notify =
                                                    Notifications.fromJson(
                                                        notificationSettings[
                                                            e.key]);
                                                if (val ?? false) {
                                                  notify.isFirebaseNotification =
                                                      "1";
                                                } else {
                                                  notify.isFirebaseNotification =
                                                      "0";
                                                }
                                                notificationSettings[e.key] =
                                                    notify.toJson();
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            // Observer(builder: (context) {
                            //   return Container(
                            //     decoration: BoxDecoration(
                            //         color: appStore.isDarkMode
                            //             ? scaffoldColorDark
                            //             : Colors.white,
                            //         borderRadius:
                            //             BorderRadius.circular(defaultRadius),
                            //         boxShadow: commonBoxShadow()),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         SwitchListTile(
                            //           // value: appStore.isShowVehicle,
                            //           value: appStore.isShowVehicle == 1,
                            //           onChanged: (value) {
                            //             // appStore.isShowVehicle;
                            //             if (value)
                            //               appStore.isShowVehicle = 1;
                            //             else
                            //               appStore.isShowVehicle = 0;
                            //             print(appStore.isShowVehicle);

                            //             setState(() {});
                            //           },
                            //           title: Text("Vehicle",
                            //               style: primaryTextStyle()),
                            //           controlAffinity:
                            //               ListTileControlAffinity.trailing,
                            //           inactiveTrackColor: appStore.isDarkMode
                            //               ? Colors.white12
                            //               : Colors.black12,
                            //         ),
                            //       ],
                            //     ),
                            //   );
                            // })
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
              appStore.isLoading
                  ? loaderWidget()
                  : notificationSettings.isEmpty
                      ? emptyWidget()
                      : SizedBox()
            ],
          );
        },
      ),
      bottomNavigationBar: notificationSettings.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(16),
              child: dialogPrimaryButton(language.save, () {
                if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                  toast(language.demoAdminMsg);
                } else {
                  saveAppSetting();
                }
              }),
            )
          : SizedBox(),
    );
  }
}
