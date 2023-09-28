import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../main.dart';
import '../../models/AppSettingModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/DataProvider.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class AppSettingScreen extends StatefulWidget {
  static String route = '/admin/appsetting';

  @override
  AppSettingScreenState createState() => AppSettingScreenState();
}

class AppSettingScreenState extends State<AppSettingScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController horizontalScrollController = ScrollController();

  ScrollController notificationController = ScrollController();
  TextEditingController currencySymbolController = TextEditingController();

  Map<String, dynamic> notificationSettings = {};
  int? settingId;
  bool isAutoAssign = false;
  bool isOtpVerifyOnPickupDelivery = true;

  TextEditingController distanceController = TextEditingController();
  TextEditingController chargeController = TextEditingController();
  String? distanceUnitType;

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
    init();
  }

  void init() async {
    appStore.setSelectedMenuIndex(APP_SETTING_INDEX);
    appStore.setLoading(true);
    await getAppSetting().then((value) {
      notificationSettings = value.notification_settings!.toJson();
      isAutoAssign = value.autoAssign == 1;
      isOtpVerifyOnPickupDelivery = value.otpVerifyOnPickupDelivery == 1;
      distanceController.text = '${value.distance ?? ''}';
      distanceUnitType = value.distanceUnit;
      settingId = value.id!;
      currencySymbolController.text =
          value.currency.validate(value: currencySymbolDefault);
      currencyCode = value.currencyCode;
      currencySymbol = value.currency;
      selectedCurrencyPosition =
          value.currencyPosition ?? CURRENCY_POSITION_LEFT;
          print('cary pakcage charge => ${value.carryPackagesCharge.toString()}');
      chargeController.text = value.carryPackagesCharge.toString();
      appStore.isShowVehicle = value.isVehicleInOrder!;
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
      if (distanceUnitType == null &&
              isAutoAssign &&
              (appStore.isShowVehicle == 1)
          ? true
          : false) return toast(language.please_select_distance_unit);
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
              "otp_verify_on_pickup_delivery":
                  isOtpVerifyOnPickupDelivery ? 1 : 0,
              "notification_settings":
                  NotificationSettings.fromJson(notificationSettings).toJson(),
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
    Widget saveSettingButton() {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(defaultRadius)),
          child: Text(language.save, style: boldTextStyle(color: Colors.white)),
        ),
        onTap: () {
          if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
            toast(language.demo_admin_msg);
          } else {
            saveAppSetting();
          }
        },
      );
    }

    Widget notificationSettingWidget() {
      return RawScrollbar(
        scrollbarOrientation: ScrollbarOrientation.bottom,
        controller: horizontalScrollController,
        thumbVisibility: true,
        thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
        radius: Radius.circular(defaultRadius),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
              color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
              borderRadius: BorderRadius.circular(defaultRadius),
              boxShadow: commonBoxShadow()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.notification_setting, style: boldTextStyle()),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: horizontalScrollController,
                  padding: EdgeInsets.only(bottom: 16, top: 16),
                  child: DataTable(
                    headingTextStyle: boldTextStyle(size: 14),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultRadius)),
                    dataTextStyle: primaryTextStyle(),
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => primaryColor.withOpacity(0.1)),
                    showCheckboxColumn: false,
                    dataRowHeight: 45,
                    headingRowHeight: 45,
                    horizontalMargin: 16,
                    columns: [
                      DataColumn(label: Text(language.type)),
                      DataColumn(
                          label: Text(language.one_single), numeric: true),
                      DataColumn(
                          label: Text(
                              '${language.firebase} ${language.for_admin}'),
                          numeric: true),
                    ],
                    rows: notificationSettings.entries.map((e) {
                      return DataRow(
                        cells: [
                          DataCell(Text(orderSettingStatus(e.key) ?? '',
                              style: primaryTextStyle())),
                          DataCell(
                            Checkbox(
                              value:
                                  e.value["IS_ONESIGNAL_NOTIFICATION"] == "1",
                              onChanged: (val) {
                                Notifications notify = Notifications.fromJson(
                                    notificationSettings[e.key]);
                                if (val ?? false) {
                                  notify.isOnesignalNotification = "1";
                                } else {
                                  notify.isOnesignalNotification = "0";
                                }
                                notificationSettings[e.key] = notify.toJson();
                                setState(() {});
                              },
                            ),
                          ),
                          DataCell(
                            Checkbox(
                              value: e.value["IS_FIREBASE_NOTIFICATION"] == "1",
                              onChanged: (val) {
                                Notifications notify = Notifications.fromJson(
                                    notificationSettings[e.key]);
                                if (val ?? false) {
                                  notify.isFirebaseNotification = "1";
                                } else {
                                  notify.isFirebaseNotification = "0";
                                }
                                notificationSettings[e.key] = notify.toJson();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget currencySettingWidget() {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                borderRadius: BorderRadius.circular(defaultRadius),
                boxShadow: commonBoxShadow()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  value: isAutoAssign,
                  onChanged: (value) {
                    isAutoAssign = value;
                    setState(() {});
                  },
                  title: Text(language.order_auto_assign,
                      style: primaryTextStyle()),
                  controlAffinity: ListTileControlAffinity.trailing,
                  inactiveTrackColor:
                      appStore.isDarkMode ? Colors.white12 : Colors.black12,
                ),
                if (isAutoAssign)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.distance, style: primaryTextStyle()),
                        SizedBox(height: 8),
                        AppTextField(
                          controller: distanceController,
                          textFieldType: TextFieldType.OTHER,
                          decoration: commonInputDecoration(),
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp('[0-9 .]')),
                          ],
                          validator: (s) {
                            if (s!.trim().isEmpty)
                              return language.field_required_msg;
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        Text(language.distance_unit, style: primaryTextStyle()),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                value: DISTANCE_UNIT_KM,
                                title: Text(DISTANCE_UNIT_KM,
                                    style: primaryTextStyle()),
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
                                title: Text(DISTANCE_UNIT_MILE,
                                    style: primaryTextStyle()),
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
                  title: Text(language.otpVerificationOnPickupDelivery,
                      style: primaryTextStyle()),
                  controlAffinity: ListTileControlAffinity.trailing,
                  inactiveTrackColor:
                      appStore.isDarkMode ? Colors.white12 : Colors.black12,
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Carry Packages Charge", style: primaryTextStyle()),
                      SizedBox(height: 8),
                      AppTextField(
                        controller: chargeController,
                        textFieldType: TextFieldType.OTHER,
                        decoration: commonInputDecoration(),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9 .]')),
                        ],
                        validator: (s) {
                          if (s!.trim().isEmpty)
                            return language.field_required_msg;
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
                color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                borderRadius: BorderRadius.circular(defaultRadius),
                boxShadow: commonBoxShadow()),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.currencySetting, style: boldTextStyle()),
                SizedBox(height: 16),
                Text(language.currencyPosition, style: primaryTextStyle()),
                SizedBox(height: 8),
                DropdownButtonFormField(
                  decoration: commonInputDecoration(),
                  value: selectedCurrencyPosition,
                  dropdownColor: Theme.of(context).cardColor,
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
                Text(language.currencySymbol, style: primaryTextStyle()),
                SizedBox(height: 8),
                AppTextField(
                  controller: currencySymbolController,
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.15),
                    counterText: '',
                    suffixIcon: GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(language.pick,
                                  style:
                                      primaryTextStyle(color: primaryColor))),
                        ),
                        onTap: () {
                          showCurrencyPicker(
                            theme: CurrencyPickerThemeData(
                              bottomSheetHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                              backgroundColor: Theme.of(context).cardColor,
                              titleTextStyle: primaryTextStyle(size: 17),
                              subtitleTextStyle: primaryTextStyle(size: 15),
                            ),
                            context: context,
                            showFlag: true,
                            showSearchField: true,
                            showCurrencyName: true,
                            showCurrencyCode: true,
                            onSelect: (Currency currency) {
                              currencySymbolController.text = currency.symbol;
                              currencyCode = currency.code;
                              currencySymbol = currency.symbol;
                              setState(() {});
                            },
                          );
                        }),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(defaultRadius)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                        borderRadius: BorderRadius.circular(defaultRadius)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(defaultRadius)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(defaultRadius)),
                  ),
                  textFieldType: TextFieldType.OTHER,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Observer(builder: (context) {
          //   return Container(
          //     decoration: BoxDecoration(
          //         color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
          //         borderRadius: BorderRadius.circular(defaultRadius),
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
          //           title: Text(language.vehicle, style: primaryTextStyle()),
          //           controlAffinity: ListTileControlAffinity.trailing,
          //           inactiveTrackColor:
          //               appStore.isDarkMode ? Colors.white12 : Colors.black12,
          //         ),
          //       ],
          //     ),
          //   );
          // })
        ],
      );
    }

    return Observer(
      builder: (context) {
        return BodyCornerWidget(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                controller: notificationController,
                padding:
                    EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 50),
                child: notificationSettings.isNotEmpty
                    ? Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResponsiveWidget.isSmallScreen(context) &&
                                    appStore.isMenuExpanded
                                ? Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(language.appSetting,
                                          style: boldTextStyle(
                                              size: 22, color: primaryColor)),
                                      saveSettingButton(),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(language.appSetting,
                                          style: boldTextStyle(
                                              size: 22, color: primaryColor)),
                                      saveSettingButton(),
                                    ],
                                  ),
                            SizedBox(height: 16),
                            ResponsiveWidget.isLargeScreen(context)
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: notificationSettingWidget(),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: currencySettingWidget(),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      notificationSettingWidget(),
                                      SizedBox(height: 16),
                                      currencySettingWidget(),
                                    ],
                                  ),
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
          ),
        );
      },
    );
  }
}
