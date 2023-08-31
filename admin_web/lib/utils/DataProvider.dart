import 'package:flutter/material.dart';
import 'package:local_delivery_admin/screens/Admin/VehicleScreen.dart';
import '../screens/Admin/AdminHomeScreen.dart';
import '../screens/Admin/CityScreen.dart';
import '../components/Admin/CoorporateWidget.dart';
import '../screens/Admin/CountryScreen.dart';
import '../components/Client/OrderComponent.dart';
import '../screens/Admin/CreateOrderScreen.dart';
import '../screens/Admin/DeliveryBoyScreen.dart';
import '../screens/Admin/DeliveryPersonDocumentScreen.dart';
import '../screens/Admin/DocumentScreen.dart';
import '../screens/Admin/ExtraChargesScreen.dart';
import '../screens/Admin/OrderScreen.dart';
import '../screens/Admin/ParcelTypeScreen.dart';
import '../screens/Admin/PaymentGatewayScreen.dart';
import '../screens/Admin/UserScreen.dart';
import '../screens/Admin/WithdrawScreen.dart';
import '../screens/Client/DraftOrderScreen.dart';
import '../screens/Client/OrderListScreen.dart';
import '../screens/Client/PrivacyPolicyScreen.dart';
import '../utils/Extensions/string_extensions.dart';
import '../main.dart';
import '../models/LanguageDataModel.dart';
import '../models/AppSettingModel.dart';
import '../models/models.dart';
import '../screens/Admin/DriverInvoiceScreen.dart';
import '../screens/Admin/UserInvoiceFilter.dart';
import '../screens/Client/AboutUsScreen.dart';
import '../screens/Client/AccountSettingScreen.dart';
import '../screens/Client/BankDetailScreen.dart';
import '../components/Client/ChangePasswordComponent.dart';
import '../screens/Client/ContactUsScreen.dart';
import '../screens/Client/DeliveryPartnerScreen.dart';
import '../components/Client/WalletComponent.dart';
import '../components/Client/WithdrawHistoryComponent.dart';
import '../utils/Constants.dart';

import '../screens/Admin/AppSettingScreen.dart';

List<MenuItemModel> getMenuItems() {
  List<MenuItemModel> list = [];
  list.add(MenuItemModel(
      index: DASHBOARD_INDEX,
      imagePath: 'assets/icons/ic_dashboard.png',
      title: language.dashboard,
      route: AdminHomeScreen.route));
  list.add(MenuItemModel(
      index: COUNTRY_INDEX,
      imagePath: 'assets/icons/ic_country.png',
      title: language.country,
      route: CountryScreen.route));
  list.add(MenuItemModel(
      index: CITY_INDEX,
      imagePath: 'assets/icons/ic_city.png',
      title: language.city,
      route: CityScreen.route));
  list.add(MenuItemModel(
      index: VEHICLE_INDEX,
      imagePath: 'assets/icons/ic_scooter.png',
      title: language.vehicle,
      route: VehicleScreen.route));
  list.add(MenuItemModel(
      index: EXTRA_CHARGES_INDEX,
      imagePath: 'assets/icons/ic_extra_charges.png',
      title: language.extra_charges,
      route: ExtraChargesScreen.route));
  list.add(MenuItemModel(
      index: PARCEL_TYPE_INDEX,
      imagePath: 'assets/icons/ic_parcel_type.png',
      title: language.parcel_type,
      route: ParcelTypeScreen.route));
  list.add(MenuItemModel(
      index: PAYMENT_GATEWAY_INDEX,
      imagePath: 'assets/icons/ic_payment_gateway.png',
      title: language.payment_gateway,
      route: PaymentGatewayScreen.route));
  list.add(MenuItemModel(
      index: CREATE_ORDER_INDEX,
      imagePath: 'assets/icons/ic_create_order.png',
      title: language.create_order,
      route: CreateOrderScreen.route));
  list.add(MenuItemModel(
      index: ORDER_INDEX,
      imagePath: 'assets/icons/ic_orders.png',
      title: language.all_order,
      route: OrderScreen.route));
  list.add(MenuItemModel(
      index: DOCUMENT_INDEX,
      imagePath: 'assets/icons/ic_document.png',
      title: language.document,
      route: DocumentScreen.route));
  list.add(MenuItemModel(
      index: DELIVERY_PERSON_DOCUMENT_INDEX,
      imagePath: 'assets/icons/ic_document.png',
      title: language.delivery_person_documents,
      route: DeliveryPersonDocumentScreen.route));
  list.add(MenuItemModel(
      index: USER_INDEX,
      imagePath: 'assets/icons/ic_users.png',
      title: language.users,
      route:UsersScreen.route ));
  list.add(MenuItemModel(
      index: Coorporate_INDEX,
      imagePath: 'assets/icons/ic_users.png',
      title: "Coorporate Users",
      route: CoorporateWidget.route));
  list.add(MenuItemModel(
      index: DELIVERY_PERSON_INDEX,
      imagePath: 'assets/icons/ic_delivery_boy.png',
      title: language.delivery_person,
      route: DeliveryBoyScreen.route));
  list.add(MenuItemModel(
      index: APP_SETTING_INDEX,
      imagePath: 'assets/icons/ic_notification_setting.png',
      title: language.appSetting,
      route: AppSettingScreen.route));
  list.add(MenuItemModel(
      index: DRIVER_INVOICES,
      imagePath: 'assets/icons/ic_notification_setting.png',
      title: "Drivers Invoice",
      route: DriverInvoices.route));
  list.add(MenuItemModel(
      index: USER_INVOICES,
      imagePath: 'assets/icons/ic_notification_setting.png',
      title: "Users Invoice",
      route: UsersInvoices.route));
  list.add(MenuItemModel(
      index: WITHDRAW_INDEX,
      imagePath: 'assets/icons/ic_document.png',
      title: language.withdrawRequest,
      route: WithdrawScreen.route));
  return list;
}

List<StaticPaymentModel> getStaticPaymentItems() {
  List<StaticPaymentModel> list = [];
  list.add(
      StaticPaymentModel(title: language.stripe, type: PAYMENT_TYPE_STRIPE));
  list.add(StaticPaymentModel(
      title: language.razorpay, type: PAYMENT_TYPE_RAZORPAY));
  list.add(StaticPaymentModel(
      title: language.pay_stack, type: PAYMENT_TYPE_PAYSTACK));
  list.add(StaticPaymentModel(
      title: language.flutter_wave, type: PAYMENT_TYPE_FLUTTERWAVE));
  list.add(
      StaticPaymentModel(title: language.paypal, type: PAYMENT_TYPE_PAYPAL));
  list.add(
      StaticPaymentModel(title: language.paytabs, type: PAYMENT_TYPE_PAYTABS));
  list.add(StaticPaymentModel(
      title: language.mercado_pago, type: PAYMENT_TYPE_MERCADOPAGO));
  list.add(StaticPaymentModel(title: language.paytm, type: PAYMENT_TYPE_PAYTM));
  list.add(StaticPaymentModel(
      title: language.my_fatoorah, type: PAYMENT_TYPE_MYFATOORAH));
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
    return language.courier_assigned;
  } else if (orderStatus == ORDER_TRANSFER) {
    return language.courier_transfer;
  } else if (orderStatus == ORDER_ARRIVED) {
    return language.courier_arrived;
  } else if (orderStatus == ORDER_DELAYED) {
    return language.delayed;
  } else if (orderStatus == ORDER_CANCELLED) {
    return language.cancel;
  } else if (orderStatus == ORDER_PICKED_UP) {
    return language.courier_picked_up;
  } else if (orderStatus == ORDER_DEPARTED) {
    return language.courier_departed;
  } else if (orderStatus == ORDER_PAYMENT) {
    return language.payment_status_message;
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
      courier_assigned: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courier_transfer: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courier_arrived: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      delayed: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      cancelled: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courier_picked_up: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      courier_departed: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      completed: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      payment_status_message: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));
  list.add(NotificationSettings(
      failed: Notifications(
          isOnesignalNotification: '0', isFirebaseNotification: '0')));

  Map<String, dynamic> map = Map.fromIterable(list,
      key: (e) => e.toJson().keys.first.toString(),
      value: (e) => e.toJson().values.first);

  return map;
}

class ClientMenuItemModel {
  int? index;
  String? title;
  Widget? widget;
  String? widgetRoute;
  bool? mISCheck;
  IconData? img;
  String? link;

  ClientMenuItemModel(
      {this.index,
      this.title,
      this.widget,
      this.mISCheck = false,
      this.img,
      this.widgetRoute,
      this.link});
}

List<ClientMenuItemModel> getClientMenuItems() {
  List<ClientMenuItemModel> list = [];
  list.add(ClientMenuItemModel(
      index: ORDER_LIST_INDEX,
      title: language.orderList,
      widget: OrderListScreen()));
  list.add(ClientMenuItemModel(
      index: DRAFT_LIST_INDEX,
      title: language.draft,
      widget: DraftOrderScreen()));
  list.add(ClientMenuItemModel(
      index: WALLET_INDEX, title: language.wallet, widget: WalletScreen()));
  list.add(ClientMenuItemModel(
      index: WITHDRAW_HISTORY_INDEX,
      title: language.withdraw,
      widget: WithDrawHistoryScreen()));
  list.add(ClientMenuItemModel(
      index: BANK_DETAIL_INDEX,
      title: language.bankDetails,
      widget: BankDetailScreen()));
  list.add(ClientMenuItemModel(
      index: CHANGE_PASSWORD_INDEX,
      title: language.changePassword,
      widget: ChangePasswordScreen()));
  list.add(ClientMenuItemModel(
      index: DELETE_ACCOUNT_INDEX,
      title: language.appSetting,
      widget: AccountSettingScreen()));
  list.add(ClientMenuItemModel(
      index: ABOUT_US_INDEX,
      title: language.about_us,
      widget: AboutUsScreen(),
      widgetRoute: AboutUsScreen.route));
  return list;
}

List<ClientMenuItemModel> footerList = [
  ClientMenuItemModel(
      index: 0,
      title: language.about_us,
      widget: AboutUsScreen(),
      widgetRoute: AboutUsScreen.route),
  ClientMenuItemModel(
      index: 1,
      title: language.contactUs,
      widget: ContactUsScreen(),
      widgetRoute: ContactUsScreen.route),
  ClientMenuItemModel(
      index: 2,
      title: language.privacyPolicy,
      widget: PrivacyPolicyScreen(),
      widgetRoute: PrivacyPolicyScreen.route),
  ClientMenuItemModel(
      index: 3,
      title: "${builderResponse.appName.validate()} for partner",
      widget: DeliveryPartnerScreen(),
      widgetRoute: DeliveryPartnerScreen.route),
];

List<FooterPageSocialLinkModel> contactList = [
  FooterPageSocialLinkModel(
      ind: 1,
      name: builderResponse.contactEmail,
      link: builderResponse.contactEmail,
      icon: Icon(Icons.mail, color: Colors.white)),
  FooterPageSocialLinkModel(
      ind: 2,
      name: builderResponse.contactNumber,
      link: builderResponse.contactNumber,
      icon: Icon(Icons.call, color: Colors.white)),
  FooterPageSocialLinkModel(
      ind: 3,
      name: builderResponse.address,
      icon: Icon(Icons.location_on_rounded, color: Colors.white)),
];

List<String> getCancelReasonList() {
  List<String> list = [];
  list.add(language.cancelOrder1);
  list.add(language.cancelOrder2);
  list.add(language.cancelOrder3);
  list.add(language.cancelOrder4);
  list.add(language.cancelOrder5);
  list.add(language.cancelOrder6);
  list.add(language.cancelOrder7);
  return list;
}

List<String> getReturnReasonList() {
  List<String> list = [];
  list.add(language.returnOrder1);
  list.add(language.returnOrder2);
  list.add(language.returnOrder3);
  list.add(language.returnOrder4);
  list.add(language.returnOrder5);
  return list;
}

class StaticDashboardModel {
  String? name;
  String? description;
  String? img;
  int? ind;
  String? widgetRoute;
  Widget? onTap;

  StaticDashboardModel(
      {this.name,
      this.description,
      this.img,
      this.ind,
      this.onTap,
      this.widgetRoute});
}

class FilterAttributeModel {
  String? orderStatus;
  String? fromDate;
  String? toDate;

  FilterAttributeModel({this.orderStatus, this.fromDate, this.toDate});

  FilterAttributeModel.fromJson(Map<String, dynamic> json) {
    orderStatus = json['order_status'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_status'] = this.orderStatus;
    data['from_date'] = this.fromDate;
    data['to_date'] = this.toDate;
    return data;
  }
}

class FooterPageSocialLinkModel {
  int? ind;
  String? name;
  String? link;
  Icon? icon;
  IconData? img;

  FooterPageSocialLinkModel({this.ind, this.name, this.link, this.icon});
}
