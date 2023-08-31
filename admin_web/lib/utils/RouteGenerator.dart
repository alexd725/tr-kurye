import 'package:flutter/material.dart';
import 'package:local_delivery_admin/utils/Extensions/bool_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/shared_pref.dart';
import 'package:local_delivery_admin/utils/Extensions/string_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/widget_extensions.dart';
import '../components/Admin/CoorporateWidget.dart';
import '../main.dart';
import '../screens/Admin/AdminHomeScreen.dart';
import '../screens/Admin/AdminLoginScreen.dart';
import '../screens/Admin/AdminOrderDetailScreen.dart';
import '../screens/Admin/AppSettingScreen.dart';
import '../screens/Admin/CityScreen.dart';
import '../screens/Admin/CountryScreen.dart';
import '../screens/Admin/CreateOrderScreen.dart';
import '../screens/Admin/DeliveryBoyDetailScreen.dart';
import '../screens/Admin/DeliveryBoyScreen.dart';
import '../screens/Admin/DeliveryPersonDocumentScreen.dart';
import '../screens/Admin/DocumentScreen.dart';
import '../screens/Admin/DriverInvoiceScreen.dart';
import '../screens/Admin/ExtraChargesScreen.dart';
import '../screens/Admin/NotificationViewAllScreen.dart';
import '../screens/Admin/OrderScreen.dart';
import '../screens/Admin/ParcelTypeScreen.dart';
import '../screens/Admin/PaymentGatewayScreen.dart';
import '../screens/Admin/PaymentSetupScreen.dart';
import '../screens/Admin/UserInvoiceFilter.dart';
import '../screens/Admin/UserScreen.dart';
import '../screens/Admin/VehicleScreen.dart';
import '../screens/Admin/WithdrawScreen.dart';
import '../screens/Client/AboutUsScreen.dart';
import '../screens/Client/ChatScreen.dart';
import '../screens/Client/ContactUsScreen.dart';
import '../screens/Client/DashboardScreen.dart';
import '../screens/Client/DeliveryPartnerScreen.dart';
import '../screens/Client/NotificationScreen.dart';
import '../screens/Client/OrderDetailScreen.dart';
import '../screens/Client/PrivacyPolicyScreen.dart';
import '../screens/Client/ProfileScreen.dart';
import '../screens/Client/SendPackageFragment.dart';
import '../screens/Client/TermAndConditionScreen.dart';
import 'Common.dart';

Route<dynamic>? onGenerateRoute(settings) {
  var uriData = Uri.parse(settings.name!);
  final queryParameters = uriData.queryParameters;
  MaterialPageRoute clientDashboardRoute = MaterialPageRoute(builder: (context) => DashboardScreen(), settings: RouteSettings(name: DashboardScreen.route));
  MaterialPageRoute adminLoginRoute = MaterialPageRoute(builder: (context) => AdminLoginScreen(), settings: RouteSettings(name: AdminLoginScreen.route));
  if (settings.name == OrderDetailScreen.route + "?order_Id=${queryParameters['order_Id']}") {
    return isClientLogin ? MaterialPageRoute(builder: (context) => OrderDetailScreen(orderId: queryParameters['order_Id'].toInt()), settings: settings) : clientDashboardRoute;
  }
  if (settings.name == SendPackageFragment.route + "?order_Id=${queryParameters['order_Id']}") {
    return isClientLogin ? MaterialPageRoute(builder: (context) => SendPackageFragment(orderId: queryParameters['order_Id'].toInt()), settings: settings) : clientDashboardRoute;
  }
  if (settings.name == ChatScreen.route + "?user_Id=${queryParameters['user_Id']}") {
    return isClientLogin ? MaterialPageRoute(builder: (context) => ChatScreen(userId: queryParameters['user_Id'].toInt()), settings: settings) : clientDashboardRoute;
  }
  if (settings.name == SendPackageFragment.route) {
    return isClientLogin ? MaterialPageRoute(builder: (context) => SendPackageFragment(), settings: settings) : clientDashboardRoute;
  }
  if (settings.name == NotificationScreen.route) {
    return isClientLogin ? MaterialPageRoute(builder: (context) => NotificationScreen(), settings: settings) : clientDashboardRoute;
  }
  if (settings.name == AdminOrderDetailScreen.route + "?order_Id=${queryParameters['order_Id']}") {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => AdminOrderDetailScreen(orderId: queryParameters['order_Id'].toInt()), settings: settings) : adminLoginRoute;
  }
  if (settings.name == PaymentSetupScreen.route + "?payment_type=${queryParameters['payment_type']}") {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => PaymentSetupScreen(paymentType: queryParameters['payment_type']), settings: settings) : adminLoginRoute;
  }
  if (settings.name == DeliveryPersonDocumentScreen.route + "?delivery_man_id=${queryParameters['delivery_man_id']}") {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => DeliveryPersonDocumentScreen(deliveryManId: queryParameters['delivery_man_id'].toInt()), settings: settings) : adminLoginRoute;
  }
  if (settings.name == DeliveryPersonDetailScreen.route + "?user_Id=${queryParameters['user_Id']}") {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => DeliveryPersonDetailScreen(userId: queryParameters['user_Id'].toInt()), settings: settings) : adminLoginRoute;
  }
  if (settings.name == DeliveryPersonDetailScreen.route + "?delivery_man_id=${queryParameters['delivery_man_id']}") {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => DeliveryPersonDetailScreen(userId: queryParameters['delivery_man_id'].toInt()), settings: settings) : adminLoginRoute;
  }
  if (settings.name == NotificationViewAllScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => NotificationViewAllScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == PaymentSetupScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => PaymentSetupScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == AdminHomeScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => AdminHomeScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == CountryScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => CountryScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == CityScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => CityScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == ExtraChargesScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => ExtraChargesScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == ParcelTypeScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => ParcelTypeScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == PaymentGatewayScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => PaymentGatewayScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == CreateOrderScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => CreateOrderScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == OrderScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => OrderScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == DocumentScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => DocumentScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == DeliveryPersonDocumentScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => DeliveryPersonDocumentScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == UsersScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => UsersScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == CoorporateWidget.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => CoorporateWidget(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == DeliveryBoyScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => DeliveryBoyScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == UsersInvoices.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => UsersInvoices(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == DriverInvoices.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => DriverInvoices(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == WithdrawScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => WithdrawScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == AppSettingScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => AppSettingScreen(), settings: settings) : adminLoginRoute;
  }
  if (settings.name == VehicleScreen.route) {
    return isAdminLogin ? MaterialPageRoute(builder: (context) => VehicleScreen(), settings: settings) : adminLoginRoute;
  }
  return null;
}

Map<String, WidgetBuilder> route = {
  DashboardScreen.route: (context) => DashboardScreen(),
  AboutUsScreen.route: (context) => AboutUsScreen(),
  DeliveryPartnerScreen.route: (context) => DeliveryPartnerScreen(),
  ProfileScreen.route: (context) => ProfileScreen(),
  ContactUsScreen.route: (context) => ContactUsScreen(),
  AdminLoginScreen.route: (context) => AdminLoginScreen(),
  PrivacyPolicyScreen.route: (context) => PrivacyPolicyScreen(),
  TermAndConditionScreen.route: (context) => TermAndConditionScreen(),
};
