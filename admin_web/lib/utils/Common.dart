import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/bool_extensions.dart';
import '../utils/Extensions/constants.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/widget_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import 'ResponsiveWidget.dart';
import 'package:lottie/lottie.dart';
import 'Constants.dart';
import 'Extensions/colors.dart';
import 'Extensions/common.dart';
import 'Extensions/decorations.dart';
import 'Extensions/text_styles.dart';
import 'Images.dart';

getMenuWidth() {
  return appStore.isMenuExpanded ? 270 : 80;
}

getBodyWidth(BuildContext context) {
  return MediaQuery.of(context).size.width - getMenuWidth();
}

double getTableWidth(context) {
  return ResponsiveWidget.isLargeScreen(context) ? (getBodyWidth(context) - 40) * 0.5 : getBodyWidth(context) - 16;
}

double getWalletTableWidth(context) {
  return ResponsiveWidget.isLargeScreen(context) ? (getBodyWidth(context) - 40) * 0.8 : getBodyWidth(context) - 16;
}

double getDetailWidth(context) {
  return ResponsiveWidget.isLargeScreen(context) ? (getBodyWidth(context) - 40) * 0.2 : getBodyWidth(context) - 16;
}

double? getTableHeight(context) {
  return ResponsiveWidget.isLargeScreen(context) ? 570 : null;
}

Widget commonButton(String title, Function() onTap, {double? width}) {
  return SizedBox(
    width: width,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 20),
        backgroundColor: primaryColor,
      ),
      child: Text(title, style: boldTextStyle(color: Colors.white)),
      onPressed: onTap,
    ),
  );
}

List<BoxShadow> commonBoxShadow() {
  return [BoxShadow(color: Colors.black12, blurRadius: 2.0, spreadRadius: 0)];
}

containerDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(defaultRadius),
    color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
    border: Border.all(color: appStore.isDarkMode ? Colors.white12 : viewLineColor, width: 1.5),
  );
}

Widget commonCachedNetworkImage(String? url, {double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url != null && url.isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    );
  } else {
    return Image.network(url!, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center);
}

Widget informationWidget(String title, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title, style: boldTextStyle(weight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value, style: primaryTextStyle()),
        ),
      ],
    ),
  );
}

Widget addButton(String title, Function() onTap) {
  return InkWell(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Colors.white),
          SizedBox(width: 12),
          Text(title, style: boldTextStyle(color: Colors.white)),
        ],
      ),
    ),
    onTap: onTap,
  );
}

Widget dialogSecondaryButton(String title, Function() onTap) {
  return SizedBox(
    width: 120,
    height: 40,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: appStore.isDarkMode ? Colors.white12 : viewLineColor)),
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
    width: 120,
    height: 40,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
        elevation: 0,
        backgroundColor: color ?? primaryColor,
      ),
      child: Text(title, style: boldTextStyle(color: Colors.white)),
      onPressed: onTap,
    ),
  );
}

Widget loaderWidget() {
  return Center(child: Lottie.asset('assets/loader.json', width: 70, height: 70));
}

Widget emptyWidget() {
  return Center(child: Lottie.asset('assets/no_data.json', width: 250, height: 250));
}

String printDate(String date) {
  return DateFormat.yMd().add_jm().format(DateTime.parse(date).toLocal());
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
    return language.picked_up;
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

Future<void> logOutData({required BuildContext context, Function? onAccept}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false, // false = user must tap button, true = tap outside dialog
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        actionsPadding: EdgeInsets.all(16),
        content: SizedBox(
          width: 200,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.clear, color: primaryColor),
                  ),
                  SizedBox(height: 30),
                  Text(language.are_you_sure, style: primaryTextStyle(size: 24)),
                  SizedBox(height: 16),
                  Text(language.do_you_want_to_logout_from_the_app, style: boldTextStyle(), textAlign: TextAlign.center),
                  SizedBox(height: 16),
                ],
              ),
              Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget()))),
            ],
          ),
        ),
        actions: <Widget>[
          dialogSecondaryButton(language.no, () {
            Navigator.pop(context);
          }),
          dialogPrimaryButton(language.yes, () async {
            onAccept!();
            // await logout(context);
          }),
        ],
      );
    },
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

double countExtraCharge({required num totalAmount, required String chargesType, required num charges}) {
  if (chargesType == CHARGE_TYPE_PERCENTAGE) {
    return double.parse((totalAmount * charges * 0.01).toStringAsFixed(digitAfterDecimal));
  } else {
    return double.parse(charges.toStringAsFixed(digitAfterDecimal));
  }
}

Widget backButton(BuildContext context, {bool? value}) {
  return ElevatedButton(
    onPressed: () {
      if (value != null) {
        finish(context, value);
      } else {
        finish(context);
      }
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_back_ios, color: Colors.white, size: 12),
        SizedBox(width: 8),
        Text(language.back, style: primaryTextStyle(color: Colors.white)),
      ],
    ),
    style: ElevatedButton.styleFrom(padding: EdgeInsets.all(12)),
  );
}

Widget scheduleOptionWidget({required BuildContext context, required bool isSelected, required String imagePath, required String title, required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), border: Border.all(color: isSelected ? primaryColor : Theme.of(context).dividerColor), color: Theme.of(context).cardColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(AssetImage(imagePath), size: 20, color: isSelected ? primaryColor : Colors.grey),
          SizedBox(width: 16),
          Text(title, style: boldTextStyle()),
        ],
      ),
    ),
  );
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return double.tryParse((12742 * asin(sqrt(a))).toStringAsFixed(digitAfterDecimal))!;
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
    return language.on_pickup;
  } else if (paymentType.toLowerCase() == PAYMENT_ON_DELIVERY.toLowerCase()) {
    return language.on_delivery;
  }
  return language.on_pickup;
}

String paymentType(String paymentType) {
  if (paymentType.toLowerCase() == PAYMENT_TYPE_STRIPE.toLowerCase()) {
    return language.stripe;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_RAZORPAY.toLowerCase()) {
    return language.razorpay;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_PAYSTACK.toLowerCase()) {
    return language.pay_stack;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_FLUTTERWAVE.toLowerCase()) {
    return language.flutter_wave;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_MERCADOPAGO.toLowerCase()) {
    return language.mercado_pago;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_PAYPAL.toLowerCase()) {
    return language.paypal;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_PAYTABS.toLowerCase()) {
    return language.paytabs;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_PAYTM.toLowerCase()) {
    return language.paytm;
  } else if (paymentType.toLowerCase() == PAYMENT_TYPE_MYFATOORAH.toLowerCase()) {
    return language.my_fatoorah;
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

Future<void> saveFcmTokenId() async {
  await FirebaseMessaging.instance.getToken().then((value) {
    if (value.validate().isNotEmpty) setValue(FCM_TOKEN, value.validate());
  });
}

String printAmount(num amount) {
  return appStore.currencyPosition == CURRENCY_POSITION_LEFT ? '${appStore.currencySymbol} ${amount.toStringAsFixed(digitAfterDecimal)}' : '${amount.toStringAsFixed(digitAfterDecimal)} ${appStore.currencySymbol}';
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

double mCommonPadding(BuildContext context) {
  return ResponsiveWidget.isLessMediumScreen(context) ? context.width() * 0.02 : context.width() * 0.13;
}

double mCommonPadding1(BuildContext context) {
  return context.width() * 0.05;
}

InputDecoration commonInputDecoration({Color? fillColor, String? hintText, IconData? suffixIcon, Function()? suffixOnTap, Widget? prefixIcon, Widget? suffix}) {
  return InputDecoration(
    prefixIcon: prefixIcon,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    filled: true,
    hintText: hintText != null ? hintText : '',
    hintStyle: secondaryTextStyle(),
    fillColor: Colors.grey.withOpacity(0.15),
    counterText: '',
    suffixIcon: suffixIcon != null ? GestureDetector(child: Icon(suffixIcon, color: Colors.grey, size: 22), onTap: suffixOnTap) : null,
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor), borderRadius: BorderRadius.circular(defaultRadius)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
    suffixIconColor: textSecondaryColorGlobal,
    prefixIconColor: textSecondaryColorGlobal,
    hoverColor: fillColor ?? editTextBackgroundColor,
    suffix: suffix,
  );
}

Widget clientScheduleOptionWidget(BuildContext context, bool isSelected, IconData imagePath, String title) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: boxDecorationWithRoundedCorners(border: Border.all(color: isSelected ? primaryColor : borderColor), backgroundColor: context.cardColor),
    child: Row(
      children: [
        Icon(imagePath, size: 20, color: isSelected ? primaryColor : textPrimaryColorGlobal),
        8.width,
        Text(title, style: boldTextStyle(color: isSelected ? primaryColor : textPrimaryColorGlobal)).paddingTop(2).expand(),
      ],
    ),
  );
}

Widget outlineActionIcon(IconData icon, Color color, String message, Function() onTap, {String? title}) {
  return GestureDetector(
    child: Tooltip(
      message: message,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              if (!title.isEmptyOrNull) 4.width,
              if (!title.isEmptyOrNull) Text(title.validate(), style: boldTextStyle(color: color)),
              if (!title.isEmptyOrNull) 4.width,
            ],
          ),
        ),
      ),
    ),
    onTap: onTap,
  );
}

Future<void> launchUrlWidget(String url, {bool forceWebView = false}) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((e) {
    log(e);
  });
}

Widget mHeading(String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: boldTextStyle(size: 35, letterSpacing: 1.5, weight: FontWeight.w500)),
      8.height,
      Row(
        children: [
          Container(width: 90, height: 4, decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: primaryColor)),
          8.width,
          Container(width: 25, height: 4, decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8), backgroundColor: primaryColor))
        ],
      ),
      20.height,
    ],
  );
}

downloadWidget() {
  return Row(
    children: [
      Image.asset(ic_play_store, height: 40, width: 100).onTap(() {
        launchUrlWidget(builderResponse.playStoreLink.validate());
      }),
      16.width,
      Image.asset(ic_app_store, height: 40, width: 100).onTap(() {
        launchUrlWidget(builderResponse.appStoreLink.validate());
      }),
    ],
  );
}

socialWidget({bool? isAbout = false}) {
  return Wrap(
    spacing: 24,
    runSpacing: 24,
    children: [
      InkWell(
        onTap: () {
          launchUrlWidget(builderResponse.facebookUrl.validate());
        },
        child: Icon(FontAwesome.facebook_f, size: 24, color: isAbout.validate() ? textSecondaryColorGlobal : Colors.white),
      ).visible(builderResponse.facebookUrl.validate().isNotEmpty),
      InkWell(
        onTap: () {
          launchUrlWidget(builderResponse.twitterUrl.validate());
        },
        child: Icon(AntDesign.twitter, size: 24, color: isAbout.validate() ? textSecondaryColorGlobal : Colors.white),
      ).visible(builderResponse.twitterUrl.validate().isNotEmpty),
      InkWell(
        onTap: () {
          launchUrlWidget(builderResponse.linkedinUrl.validate());
        },
        child: Icon(Entypo.linkedin, size: 24, color: isAbout.validate() ? textSecondaryColorGlobal : Colors.white),
      ).visible(builderResponse.linkedinUrl.validate().isNotEmpty),
      InkWell(
        onTap: () {
          launchUrlWidget(builderResponse.instagramUrl.validate());
        },
        child: Icon(AntDesign.instagram, size: 24, color: isAbout.validate() ? textSecondaryColorGlobal : Colors.white),
      ).visible(builderResponse.instagramUrl.validate().isNotEmpty),
    ],
  );
}

String transactionType(String type) {
  if (type == TRANSACTION_ORDER_FEE) {
    return language.orderFee;
  } else if (type == TRANSACTION_TOPUP) {
    return language.topUp;
  } else if (type == TRANSACTION_ORDER_CANCEL_CHARGE) {
    return language.orderCancelCharge;
  } else if (type == TRANSACTION_ORDER_CANCEL_REFUND) {
    return language.orderCancelRefund;
  } else if (type == TRANSACTION_CORRECTION) {
    return language.correction;
  } else if (type == TRANSACTION_COMMISSION) {
    return language.commission;
  } else if (type == TRANSACTION_WITHDRAW) {
    return language.withdraw;
  }
  return '';
}

cashConfirmDialog() {
  showDialog(
    context: getContext,
    builder: (p0) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(language.balLessOrderCreateCash, style: primaryTextStyle(size: 16), textAlign: TextAlign.center),
            30.height,
            appButton(getContext, title: language.ok, onCall: () {
              finish(getContext);
            }),
          ],
        ),
      );
    },
  );
}

bool get isClientLogin => appStore.isLoggedIn && getStringAsync(USER_TYPE) == CLIENT;

bool get isAdminLogin => appStore.isLoggedIn && (getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN);

String documentData(String name) {
  if (name == PENDING) {
    return language.pending;
  } else if (name == APPROVEDText) {
    return language.approved;
  } else if (name == REJECTED) {
    return language.rejected;
  }
  return language.pending;
}
