import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mightydelivery_admin_app/screens/UserListFragment.dart';
import 'package:mightydelivery_admin_app/screens/SettingFragment.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/LanguageDataModel.dart';
import 'package:mightydelivery_admin_app/models/AppSettingModel.dart';
import 'package:mightydelivery_admin_app/models/models.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import '../screens/HomeFragment.dart';
import '../screens/DeliveryBoyFragment.dart';
import '../screens/OrderListFragment.dart';

List<MenuItemModel> getAppDashboardItems() {
  List<MenuItemModel> list = [];
  list.add(MenuItemModel(
      index: DASHBOARD_INDEX,
      icon: AntDesign.home,
      title: language.dashboard,
      widget: HomeFragment()));
  list.add(MenuItemModel(
      index: ORDER_INDEX,
      icon: MaterialCommunityIcons.clipboard_text_outline,
      title: language.allOrder,
      widget: OrderListFragment()));
  list.add(MenuItemModel(
      index: USER_INDEX,
      icon: FontAwesome.user_o,
      title: language.users,
      widget: UserListFragment()));
  list.add(MenuItemModel(
      index: DELIVERY_PERSON_INDEX,
      icon: MaterialCommunityIcons.truck_delivery_outline,
      title: language.deliveryPerson,
      widget: DeliveryBoyFragment()));
  list.add(MenuItemModel(
      index: APP_SETTING_INDEX,
      icon: Ionicons.settings_outline,
      title: language.setting,
      widget: SettingFragment()));
  return list;
}

List<StaticPaymentModel> getStaticPaymentItems() {
  List<StaticPaymentModel> list = [];
  list.add(
      StaticPaymentModel(title: language.stripe, type: PAYMENT_GATEWAY_STRIPE));
  list.add(StaticPaymentModel(
      title: language.razorpay, type: PAYMENT_GATEWAY_RAZORPAY));
  list.add(StaticPaymentModel(
      title: language.payStack, type: PAYMENT_GATEWAY_PAYSTACK));
  list.add(StaticPaymentModel(
      title: language.flutterWave, type: PAYMENT_GATEWAY_FLUTTERWAVE));
  list.add(
      StaticPaymentModel(title: language.paypal, type: PAYMENT_GATEWAY_PAYPAL));
  list.add(StaticPaymentModel(
      title: language.payTabs, type: PAYMENT_GATEWAY_PAYTABS));
  list.add(StaticPaymentModel(
      title: language.mercadoPago, type: PAYMENT_GATEWAY_MERCADOPAGO));
  list.add(
      StaticPaymentModel(title: language.paytm, type: PAYMENT_GATEWAY_PAYTM));
  list.add(StaticPaymentModel(
      title: language.myFatoorah, type: PAYMENT_GATEWAY_MYFATOORAH));
  list.add(StaticPaymentModel(title: "Iyzico", type: PAYMENT_GATEWAY_IYZICO));
  list.add(StaticPaymentModel(title: "Google Pay", type: PAYMENT_GATEWAY_GPAY));
  return list;
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(
        id: 1,
        name: 'English',
        subTitle: 'English',
        languageCode: 'en',
        fullLanguageCode: 'en-US',
        flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(
        id: 2,
        name: 'Hindi',
        subTitle: 'हिंदी',
        languageCode: 'hi',
        fullLanguageCode: 'hi-IN',
        flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(
        id: 3,
        name: 'Arabic',
        subTitle: 'عربي',
        languageCode: 'ar',
        fullLanguageCode: 'ar-AR',
        flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(
        id: 1,
        name: 'Spanish',
        subTitle: 'Española',
        languageCode: 'es',
        fullLanguageCode: 'es-ES',
        flag: 'assets/flag/ic_spain.png'),
    LanguageDataModel(
        id: 2,
        name: 'Afrikaans',
        subTitle: 'Afrikaans',
        languageCode: 'af',
        fullLanguageCode: 'af-AF',
        flag: 'assets/flag/ic_south_africa.png'),
    LanguageDataModel(
        id: 3,
        name: 'French',
        subTitle: 'Français',
        languageCode: 'fr',
        fullLanguageCode: 'fr-FR',
        flag: 'assets/flag/ic_france.png'),
    LanguageDataModel(
        id: 1,
        name: 'German',
        subTitle: 'Deutsch',
        languageCode: 'de',
        fullLanguageCode: 'de-DE',
        flag: 'assets/flag/ic_germany.png'),
    LanguageDataModel(
        id: 2,
        name: 'Indonesian',
        subTitle: 'bahasa Indonesia',
        languageCode: 'id',
        fullLanguageCode: 'id-ID',
        flag: 'assets/flag/ic_indonesia.png'),
    LanguageDataModel(
        id: 3,
        name: 'Portuguese',
        subTitle: 'Português',
        languageCode: 'pt',
        fullLanguageCode: 'pt-PT',
        flag: 'assets/flag/ic_portugal.png'),
    LanguageDataModel(
        id: 1,
        name: 'Turkish',
        subTitle: 'Türkçe',
        languageCode: 'tr',
        fullLanguageCode: 'tr-TR',
        flag: 'assets/flag/ic_turkey.png'),
    LanguageDataModel(
        id: 2,
        name: 'vietnamese',
        subTitle: 'Tiếng Việt',
        languageCode: 'vi',
        fullLanguageCode: 'vi-VI',
        flag: 'assets/flag/ic_vitnam.png'),
    LanguageDataModel(
        id: 3,
        name: 'Dutch',
        subTitle: 'Nederlands',
        languageCode: 'nl',
        fullLanguageCode: 'nl-NL',
        flag: 'assets/flag/ic_dutch.png'),
  ];
}

String? orderSettingStatus(String orderStatus) {
  if (orderStatus == ORDER_CREATED) {
    return language.create;
  } else if (orderStatus == ORDER_ACCEPTED) {
    return language.active;
  } else if (orderStatus == ORDER_ASSIGNED) {
    return language.courierAssigned;
  } else if (orderStatus == ORDER_TRANSFER) {
    return language.courierTransfer;
  } else if (orderStatus == ORDER_ARRIVED) {
    return language.courierArrived;
  } else if (orderStatus == ORDER_DELAYED) {
    return language.delayed;
  } else if (orderStatus == ORDER_CANCELLED) {
    return language.cancel;
  } else if (orderStatus == ORDER_PICKED_UP) {
    return language.courierPickedUp;
  } else if (orderStatus == ORDER_DEPARTED) {
    return language.courierDeparted;
  } else if (orderStatus == ORDER_PAYMENT) {
    return language.paymentStatusMessage;
  } else if (orderStatus == ORDER_FAIL) {
    return language.failed;
  } else if (orderStatus == ORDER_DELIVERED) {
    return language.completed;
  }
  return ORDER_CREATED;
}

Map<String, dynamic> getNotificationSetting() {
  List<NotificationSettings> list = [];
  list.add(NotificationSettings(
      active: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      create: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courierAssigned: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courierTransfer: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courierArrived: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      delayed: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      cancelled: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courierPickedUp: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courierDeparted: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      completed: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      paymentStatusMessage: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      failed: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));

  Map<String, dynamic> map = Map.fromIterable(list,
      key: (e) => e.toJson().keys.first.toString(),
      value: (e) => e.toJson().values.first);

  return map;
}
