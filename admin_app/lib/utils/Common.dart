import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';
import 'package:lottie/lottie.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'Constants.dart';
import 'Extensions/app_common.dart';

getMenuWidth() {
  //return isMenuExpanded ? 240 : 80;
  return 270;
}

getBodyWidth(BuildContext context) {
  return MediaQuery.of(context).size.width - getMenuWidth();
}

InputDecoration commonInputDecoration(
    {String? text,
    String? hintText,
    IconData? suffixIcon,
    Function()? suffixOnTap,
    Widget? prefixIcon}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    filled: true,
    prefixIcon: prefixIcon,
    hintText: hintText != null ? hintText : '',
    hintStyle: secondaryTextStyle(),
    fillColor: Colors.grey.withOpacity(0.15),
    counterText: '',
    label: Text(text.validate()),
    suffixIcon: suffixIcon != null
        ? GestureDetector(
            child: Icon(suffixIcon, color: Colors.grey, size: 22),
            onTap: suffixOnTap)
        : null,
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
  );
}

Widget appCommonButton(String title, Function() onTap, {double? width}) {
  return SizedBox(
    width: width,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius)),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: primaryColor,
      ),
      child: Text(title, style: boldTextStyle(color: Colors.white)),
      onPressed: onTap,
    ),
  );
}

List<BoxShadow> commonBoxShadow() {
  return [BoxShadow(color: Colors.black12, blurRadius: 10.0, spreadRadius: 0)];
}

Widget actionIcon(String title, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(defaultSmallRadius),
    ),
    child: Text(title, style: primaryTextStyle(size: 12, color: Colors.white)),
  );
}

Widget outlineActionIcon(
    BuildContext context, IconData icon, Color color, Function() onTap,
    {String? title}) {
  return GestureDetector(
    child: Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(defaultSmallRadius),
          border: Border.all(color: color)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 14),
          if (title != null && title.isNotEmpty)
            Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(title,
                    style: secondaryTextStyle(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
        ],
      ),
    ),
    onTap: onTap,
  );
}

containerDecoration() {
  return BoxDecoration(
    border: Border.all(width: 1, color: Colors.grey.withOpacity(0.3)),
    color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
    borderRadius: BorderRadius.circular(17),
  );
}

Widget commonCachedNetworkImage(
  String? url, {
  double? height,
  double? width,
  BoxFit? fit,
  AlignmentGeometry? alignment,
  bool usePlaceholderIfUrlEmpty = true,
  double? radius,
}) {
  if (url != null && url.isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.network(url!,
        height: height,
        width: width,
        fit: fit,
        alignment: alignment ?? Alignment.center);
  }
}

Widget placeHolderWidget(
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    double? radius}) {
  return Image.asset('assets/placeholder.jpg',
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      alignment: alignment ?? Alignment.center);
}

Widget orderItemDetail(String title, String data) {
  return Container(
    width: statisticsItemWidth,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: secondaryTextStyle(), overflow: TextOverflow.ellipsis),
        SizedBox(height: 8),
        Text(data, style: primaryTextStyle(), overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

Widget informationWidget(String title, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: boldTextStyle(weight: FontWeight.w500)),
        Text(value, style: primaryTextStyle()),
      ],
    ),
  );
}

Widget addButton(String title, Function() onTap) {
  return GestureDetector(
    child: Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
          color: appStore.isDarkMode ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(defaultRadius)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add,
              color: appStore.isDarkMode ? Colors.white : primaryColor),
          SizedBox(width: 4),
          Text(title,
              style: boldTextStyle(
                  color: appStore.isDarkMode ? Colors.white : primaryColor)),
        ],
      ),
    ),
    onTap: onTap,
  );
}

Widget dialogSecondaryButton(String title, Function() onTap) {
  return SizedBox(
    height: 40,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defaultRadius),
              side: BorderSide(color: borderColor)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent),
      child: Text(title, style: boldTextStyle(color: Colors.grey)),
      onPressed: onTap,
    ),
  );
}

Widget dialogPrimaryButton(String title, Function() onTap, {Color? color}) {
  return SizedBox(
    height: 40,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius)),
        elevation: 0,
        backgroundColor: color ?? primaryColor,
      ),
      child: Text(title, style: boldTextStyle(color: Colors.white)),
      onPressed: onTap,
    ),
  );
}

Widget userDetailWidget({String? title, String? subtitle}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: Text(title!, style: boldTextStyle())),
      Expanded(
        child: Text(subtitle!,
            style: primaryTextStyle(),
            maxLines: 2,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.right),
      ),
    ],
  );
}

Widget paginationWidget(
    {required int currentPage,
    required int totalPage,
    required Function(int) onUpdate}) {
  return Align(
    alignment: AlignmentDirectional.bottomEnd,
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
            color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
        //border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.only(left: 12, right: 12),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${language.page} $currentPage ${language.lblOf} $totalPage',
                style: primaryTextStyle()),
            SizedBox(width: 12),
            VerticalDivider(color: borderColor),
            //VerticalDivider(),
            SizedBox(width: 12),
            DropdownButton<int>(
                underline: SizedBox(),
                focusColor: Colors.transparent,
                value: currentPage,
                dropdownColor:
                    appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
                items: List.generate(totalPage, (index) {
                  return DropdownMenuItem(
                      child: Text('${index + 1}', style: primaryTextStyle()),
                      value: index + 1);
                  //return DropdownMenuItem(child: Text('${index + 1}'), value: index + 1);
                }),
                onChanged: (value) {
                  currentPage = value!;
                  onUpdate.call(currentPage);
                }),
          ],
        ),
      ),
    ),
  );
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Widget loaderWidget() {
  return Center(
      child: Lottie.asset('assets/loader.json', width: 70, height: 70));
}

Widget emptyWidget() {
  return Center(
      child: Lottie.asset('assets/no_data.json', width: 250, height: 250));
}

String printDate(String date) {
  return DateFormat.yMd().add_jm().format(DateTime.parse(date).toLocal());
}

Widget tiTleWidget({String? title, required BuildContext context}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title!, style: boldTextStyle(size: 18)),
      Container(
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(defaultRadius)),
        child: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      )
    ],
  );
}

commonConfirmationDialog(
    BuildContext context, String dialogType, Function() onSuccess,
    {bool isForceDelete = false, String? title, String? subtitle}) {
  IconData? icon;
  Color? color;
  if (dialogType == DIALOG_TYPE_DELETE) {
    icon = isForceDelete ? Icons.delete_forever : Icons.delete;
    color = Colors.red;
  } else if (dialogType == DIALOG_TYPE_RESTORE) {
    icon = Icons.restore;
    color = Colors.green;
  } else if (dialogType == DIALOG_TYPE_ENABLE) {
    color = primaryColor;
  } else if (dialogType == DIALOG_TYPE_DISABLE) {
    color = Colors.red;
  } else if (dialogType == DIALOG_TYPE_ASSIGN) {
    icon = MaterialIcons.assignment_turned_in;
    color = primaryColor;
  } else if (dialogType == DIALOG_TYPE_TRANSFER) {
    icon = MaterialCommunityIcons.transfer_right;
    color = primaryColor;
  }
  showDialog<void>(
    context: context,
    barrierDismissible:
        false, // false = user must tap button, true = tap outside dialog
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(16),
        titlePadding: EdgeInsets.only(left: 16, right: 8, top: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon != null
                ? Container(
                    decoration: BoxDecoration(
                        color: color!.withOpacity(0.2), shape: BoxShape.circle),
                    padding: EdgeInsets.all(16),
                    child: Icon(icon, color: color),
                  )
                : SizedBox(),
            SizedBox(height: 30),
            Text(title.validate(),
                style: primaryTextStyle(size: 24), textAlign: TextAlign.center),
            SizedBox(height: 16),
            Text(subtitle.validate(),
                style: secondaryTextStyle(), textAlign: TextAlign.center),
            SizedBox(height: 8),
            if (isForceDelete)
              Text(language.youDeleteThisRecoverIt,
                  style: secondaryTextStyle(), textAlign: TextAlign.center),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: dialogSecondaryButton(language.no, () {
                    Navigator.pop(context);
                  }),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: dialogPrimaryButton(language.yes, () {
                    onSuccess.call();
                  }, color: color),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void afterBuildCreated(Function()? onCreated) {
  SchedulerBinding.instance.addPostFrameCallback((_) => onCreated?.call());
}

String orderStatus(String orderStatus) {
  if (orderStatus == ORDER_ASSIGNED) {
    return language.assigned;
  } else if (orderStatus == ORDER_DRAFT) {
    return language.draft;
  } else if (orderStatus == ORDER_CREATED) {
    return language.created;
  } else if (orderStatus == ORDER_ACCEPTED) {
    return language.accepted;
  } else if (orderStatus == ORDER_PICKED_UP) {
    return language.pickedUp;
  } else if (orderStatus == ORDER_ARRIVED) {
    return language.arrived;
  } else if (orderStatus == ORDER_DEPARTED) {
    return language.departed;
  } else if (orderStatus == ORDER_DELIVERED) {
    return language.delivered;
  } else if (orderStatus == ORDER_CANCELLED) {
    return language.cancelled;
  }
  return language.assigned;
}

String notificationTypeIcon({String? type}) {
  String icon = 'assets/icons/ic_create.png';
  if (type == ORDER_ASSIGNED) {
    icon = 'assets/icons/ic_assign.png';
  } else if (type == ORDER_ACCEPTED) {
    icon = 'assets/icons/ic_active.png';
  } else if (type == ORDER_PICKED_UP) {
    icon = 'assets/icons/ic_picked.png';
  } else if (type == ORDER_ARRIVED) {
    icon = 'assets/icons/ic_arrived.png';
  } else if (type == ORDER_DEPARTED) {
    icon = 'assets/icons/ic_departed.png';
  } else if (type == ORDER_DELIVERED) {
    icon = 'assets/icons/ic_completed.png';
  } else if (type == ORDER_CANCELLED) {
    icon = 'assets/icons/ic_cancelled.png';
  } else if (type == ORDER_CREATED) {
    icon = 'assets/icons/ic_create.png';
  } else if (type == ORDER_DRAFT) {
    icon = 'assets/icons/ic_draft.png';
  }
  return icon;
}

String withdrawStatus(String mStatus) {
  if (mStatus == DECLINE) {
    return language.declined;
  } else if (mStatus == APPROVED) {
    return language.approved;
  }
  return language.requested;
}

Color withdrawStatusColor(String mStatus) {
  if (mStatus == DECLINE) {
    return Colors.red;
  } else if (mStatus == APPROVED) {
    return Colors.green;
  }
  return primaryColor;
}

Future<void> logOutData({required BuildContext context}) async {
  showDialog<void>(
    context: context,
    barrierDismissible:
        false, // false = user must tap button, true = tap outside dialog
    builder: (BuildContext dialogContext) {
      return Stack(
        children: [
          AlertDialog(
            actionsPadding: EdgeInsets.all(16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle),
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.clear, color: primaryColor),
                ),
                SizedBox(height: 30),
                Text(language.areYouSure, style: primaryTextStyle(size: 24)),
                SizedBox(height: 16),
                Text(language.doYouWantToLogoutFromTheApp,
                    style: boldTextStyle(), textAlign: TextAlign.center),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: dialogSecondaryButton(language.no, () {
                        Navigator.pop(context);
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: dialogPrimaryButton(language.yes, () async {
                        //appStore.setLoading(true);
                        await logout(context);
                        //appStore.setLoading(false);
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Observer(
              builder: (context) => Visibility(
                  visible: appStore.isLoading,
                  child: Positioned.fill(child: loaderWidget()))),
        ],
      );
    },
  );
}

Widget settingData(
    {String? name,
    IconData? icon,
    required BuildContext context,
    Function()? onTap}) {
  return ListTile(
    leading: Icon(icon!, color: Theme.of(context).iconTheme.color),
    title: Text(name!, style: boldTextStyle()),
    onTap: onTap,
  );
}

Color statusColor(String status) {
  Color color = primaryColor;
  switch (status) {
    case ORDER_ACCEPTED:
      return primaryColor;
    case ORDER_CANCELLED:
      return Colors.red;
    case ORDER_DELIVERED:
      return Colors.green;
    case ORDER_DRAFT:
      return Colors.grey;
    case ORDER_DELAYED:
      return Colors.grey;
  }
  return color;
}

double countExtraCharge(
    {required num totalAmount,
    required String chargesType,
    required num charges}) {
  if (chargesType == CHARGE_TYPE_PERCENTAGE) {
    return double.parse(
        (totalAmount * charges * 0.01).toStringAsFixed(digitAfterDecimal));
  } else {
    return double.parse(charges.toStringAsFixed(digitAfterDecimal));
  }
}

Widget backButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_back_ios, color: Colors.white, size: 12),
        SizedBox(width: 8),
        Text(language.back, style: primaryTextStyle(color: Colors.white)),
      ],
    ),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.all(12),
    ),
  );
}

Widget scheduleOptionWidget(
    {required BuildContext context,
    required bool isSelected,
    required String imagePath,
    required String title,
    required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultRadius),
          border: Border.all(
              color: isSelected
                  ? primaryColor
                  : appStore.isDarkMode
                      ? Colors.transparent
                      : borderColor),
          color: Theme.of(context).cardColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(AssetImage(imagePath),
              size: 20, color: isSelected ? primaryColor : Colors.grey),
          SizedBox(width: 16),
          Text(title, style: boldTextStyle()),
        ],
      ),
    ),
  );
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return double.tryParse(
      (12742 * asin(sqrt(a))).toStringAsFixed(digitAfterDecimal))!;
}

String paymentStatus(String paymentStatus) {
  if (paymentStatus.toLowerCase() == PAYMENT_PENDING.toLowerCase()) {
    return language.pending;
  } else if (paymentStatus.toLowerCase() == PAYMENT_FAILED.toLowerCase()) {
    return language.failed;
  } else if (paymentStatus.toLowerCase() == PAYMENT_PAID.toLowerCase()) {
    return language.paid;
  }
  return language.pending;
}

String? paymentCollectForm(String paymentType) {
  if (paymentType.toLowerCase() == PAYMENT_ON_PICKUP.toLowerCase()) {
    return language.onPickup;
  } else if (paymentType.toLowerCase() == PAYMENT_ON_DELIVERY.toLowerCase()) {
    return language.onDelivery;
  }
  return language.onPickup;
}

String paymentType(String paymentType) {
  if (paymentType.toLowerCase() == PAYMENT_GATEWAY_STRIPE.toLowerCase()) {
    return language.stripe;
  } else if (paymentType.toLowerCase() ==
      PAYMENT_GATEWAY_RAZORPAY.toLowerCase()) {
    return language.razorpay;
  } else if (paymentType.toLowerCase() ==
      PAYMENT_GATEWAY_PAYSTACK.toLowerCase()) {
    return language.payStack;
  } else if (paymentType.toLowerCase() ==
      PAYMENT_GATEWAY_FLUTTERWAVE.toLowerCase()) {
    return language.flutterWave;
  } else if (paymentType.toLowerCase() ==
      PAYMENT_GATEWAY_MERCADOPAGO.toLowerCase()) {
    return language.mercadoPago;
  } else if (paymentType.toLowerCase() ==
      PAYMENT_GATEWAY_PAYPAL.toLowerCase()) {
    return language.paypal;
  } else if (paymentType.toLowerCase() ==
      PAYMENT_GATEWAY_PAYTABS.toLowerCase()) {
    return language.payTabs;
  } else if (paymentType.toLowerCase() == PAYMENT_GATEWAY_PAYTM.toLowerCase()) {
    return language.paytm;
  } else if (paymentType.toLowerCase() ==
      PAYMENT_GATEWAY_MYFATOORAH.toLowerCase()) {
    return language.myFatoorah;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_CASH.toLowerCase()) {
    return language.cash;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_WALLET.toLowerCase()) {
    return language.wallet;
  }
  return language.cash;
}

String statusTypeIcon({String? type}) {
  String icon = 'assets/icons/ic_create.png';
  if (type == ORDER_ASSIGNED) {
    icon = 'assets/icons/ic_assign.png';
  } else if (type == ORDER_ACCEPTED) {
    icon = 'assets/icons/ic_active.png';
  } else if (type == ORDER_PICKED_UP) {
    icon = 'assets/icons/ic_picked.png';
  } else if (type == ORDER_ARRIVED) {
    icon = 'assets/icons/ic_arrived.png';
  } else if (type == ORDER_DEPARTED) {
    icon = 'assets/icons/ic_departed.png';
  } else if (type == ORDER_DELIVERED) {
    icon = 'assets/icons/ic_completed.png';
  } else if (type == ORDER_CANCELLED) {
    icon = 'assets/icons/ic_cancelled.png';
  } else if (type == ORDER_CREATED) {
    icon = 'assets/icons/ic_create.png';
  } else if (type == ORDER_DRAFT) {
    icon = 'assets/icons/ic_draft.png';
  }
  return icon;
}

bool get isWeb => kIsWeb;

bool get isMobile => !isWeb && (Platform.isIOS || Platform.isAndroid);

bool get isDesktop =>
    !isWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

Widget totalUserWidget(BuildContext context,
    {String? title,
    var totalCount,
    Color? bgColor,
    Color? color,
    bool isThree = true}) {
  return Container(
    width: isThree
        ? (MediaQuery.of(context).size.width - 52) / 3
        : (MediaQuery.of(context).size.width - 48) / 2,
    height: isThree ? 90 : 110,
    padding: EdgeInsets.all(8),
    alignment: Alignment.center,
    decoration: BoxDecoration(
        color: bgColor ?? primaryColor.withOpacity(0.1),
        border: Border.all(width: 1, color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(totalCount.toString(),
            style: boldTextStyle(
                color: color ?? primaryColor, size: isThree ? 18 : 30),
            maxLines: 2),
        SizedBox(height: 8),
        Text(title.validate(),
            style: secondaryTextStyle(color: color ?? primaryColor, size: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center),
      ],
    ),
  );
}

/*Widget totalUserWidget(BuildContext context, {String? title, int? totalCount,Color? bgColor,Color? color}) {
  return Container(
    width: (MediaQuery.of(context).size.width - 48) / 2,
    height: 110,
    padding: EdgeInsets.all(12),
    alignment: Alignment.center,
    decoration: BoxDecoration(color: bgColor, border: Border.all(width: 1, color: Colors.grey.withOpacity(0.3)),borderRadius: BorderRadius.circular(16)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(totalCount.toString(), style: boldTextStyle(color: color, size: 30)),
        SizedBox(height: 8),
        Text(title.validate(), style: secondaryTextStyle(color: color, size: 14), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
      ],
    ),
  );
}*/

Future<void> saveOneSignalPlayerId() async {
  await OneSignal.shared.getDeviceState().then((value) async {
    if (value!.userId.validate().isNotEmpty)
      await sharedPref.setString(PLAYER_ID, value.userId.validate());
  });
}

/*String printAmount(num amount){
  return appStore.currencyPosition==CURRENCY_POSITION_LEFT ? '${appStore.currencySymbol} $amount' : '$amount ${appStore.currencySymbol}';
}*/

String printAmount(num amount) {
  return appStore.currencyPosition == CURRENCY_POSITION_LEFT
      ? '${appStore.currencySymbol} $amount'
      : '$amount ${appStore.currencySymbol}';
}

String dayTranslate(String day) {
  String dayLanguage = "";
  if (day == "Sunday") {
    dayLanguage = language.sunday;
  } else if (day == "Monday") {
    dayLanguage = language.monday;
  } else if (day == "Tuesday") {
    dayLanguage = language.tuesday;
  } else if (day == "Wednesday") {
    dayLanguage = language.wednesday;
  } else if (day == "Thursday") {
    dayLanguage = language.thursday;
  } else if (day == "Friday") {
    dayLanguage = language.friday;
  } else if (day == "Saturday") {
    dayLanguage = language.saturday;
  }
  return dayLanguage;
}

String transactionType(String type) {
  if (type == TRANSACTION_ORDER_FEE) {
    return 'Order Fee';
  } else if (type == TRANSACTION_TOPUP) {
    return "Top Up";
  } else if (type == TRANSACTION_ORDER_CANCEL_CHARGE) {
    return "Order Cancel Charge";
  } else if (type == TRANSACTION_ORDER_CANCEL_REFUND) {
    return "Order Cancel Refund";
  } else if (type == TRANSACTION_CORRECTION) {
    return "Correction";
  } else if (type == TRANSACTION_COMMISSION) {
    return "Commission";
  } else if (type == TRANSACTION_WITHDRAW) {
    return "Withdraw";
  }
  return '';
}
