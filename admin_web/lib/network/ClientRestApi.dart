import 'dart:io';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../models/WithdrawModel.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../models/CityListModel.dart';
import '../models/Client/ClientDashboardModel.dart';
import '../models/Client/WalletListModel.dart';
import '../models/DocumentListModel.dart';
import '../models/LDBaseResponse.dart';
import '../models/LoginResponse.dart';
import '../models/OrderListModel.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/common.dart';
import '../utils/Extensions/shared_pref.dart';
import 'NetworkUtils.dart';
import 'RestApis.dart';


Future<ClientDashboardModel> getClientDashboard() async{
  return ClientDashboardModel.fromJson(await handleResponse(await buildHttpResponse('client-dashboard', method: HttpMethod.GET)));
}

Future<CityListModel> getClientCityList({required int countryId, String? name}) async {
  return CityListModel.fromJson(
      await handleResponse(await buildHttpResponse(name != null ? 'city-list?country_id=$countryId&name=$name&per_page=-1' : 'city-list?country_id=$countryId&per_page=-1', method: HttpMethod.GET)));
}

/// Country
Future updateCountryCity({int? countryId, int? cityId}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
  multiPartRequest.fields['city_id'] = cityId.toString();
  multiPartRequest.fields['country_id'] = countryId.toString();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      LoginResponse res = LoginResponse.fromJson(data);

      await setValue(COUNTRY_ID, res.data!.countryId.validate());
      await setValue(CITY_ID, res.data!.cityId.validate());
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

/// get OrderList
Future<OrderListModel> getClientOrderList({required int page,int? perPage, String? orderStatus, String? fromDate, String? toDate}) async {
  String endPoint = 'order-list?client_id=${getIntAsync(USER_ID)}&city_id=${getIntAsync(CITY_ID)}&page=$page&per_page=$perPage';

  if (orderStatus.validate().isNotEmpty) {
    endPoint += '&status=$orderStatus';
  }

  if (fromDate.validate().isNotEmpty && toDate.validate().isNotEmpty) {
    endPoint += '&from_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate.validate()))}&to_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(toDate.validate()))}';
  }

  return OrderListModel.fromJson(await handleResponse(await buildHttpResponse(endPoint, method: HttpMethod.GET)));
}

/// update order
Future updateOrder({
  String? pickupDatetime,
  String? deliveryDatetime,
  String? clientName,
  String? deliveryman,
  String? orderStatus,
  String? reason,
  int? orderId,
  File? picUpSignature,
  File? deliverySignature,
}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('order-update/$orderId');
  if (pickupDatetime != null) multiPartRequest.fields['pickup_datetime'] = pickupDatetime;
  if (deliveryDatetime != null) multiPartRequest.fields['delivery_datetime'] = deliveryDatetime;
  if (clientName != null) multiPartRequest.fields['pickup_confirm_by_client'] = clientName;
  if (deliveryman != null) multiPartRequest.fields['pickup_confirm_by_delivery_man'] = deliveryman;
  if (reason != null) multiPartRequest.fields['reason'] = reason;
  if (orderStatus != null) multiPartRequest.fields['status'] = orderStatus;

  if (picUpSignature != null) multiPartRequest.files.add(await MultipartFile.fromPath('pickup_time_signature', picUpSignature.path));
  if (deliverySignature != null) multiPartRequest.files.add(await MultipartFile.fromPath('delivery_time_signature', deliverySignature.path));

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<LDBaseResponse> savePayment(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('payment-save', request: request, method: HttpMethod.POST)));
}

Future<WithDrawListModel> getClientWithDrawList({int? page}) async {
  return WithDrawListModel.fromJson(await handleResponse(await buildHttpResponse('withdrawrequest-list?page=$page', method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWithDrawRequest(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('save-withdrawrequest', method: HttpMethod.POST, request: request)));
}

/// Get Document List
Future<DocumentListModel> getClientDocumentList({int? page}) async {
  return DocumentListModel.fromJson(await handleResponse(await buildHttpResponse('document-list?status=1&per_page=-1', method: HttpMethod.GET)));
}

/// Cancel AutoAssign order
Future<LDBaseResponse> cancelAutoAssignOrder(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('order-auto-assign', request: request, method: HttpMethod.POST)));
}

Future<WalletListModel> getClientWalletList({required int page}) async {
  return WalletListModel.fromJson(await handleResponse(await buildHttpResponse('wallet-list?page=$page', method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWallet(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse('save-wallet', method: HttpMethod.POST, request: request)));
}

/// Update Bank Info
Future updateBankDetail({String? bankName, String? bankCode, String? accountName, String? accountNumber}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
  multiPartRequest.fields['email'] = getStringAsync(USER_EMAIL).validate();
  multiPartRequest.fields['contact_number'] = getStringAsync(USER_CONTACT_NUMBER).validate();
  multiPartRequest.fields['username'] = getStringAsync(USER_NAME).validate();
  multiPartRequest.fields['user_bank_account[bank_name]'] = bankName.validate();
  multiPartRequest.fields['user_bank_account[bank_code]'] = bankCode.validate();
  multiPartRequest.fields['user_bank_account[account_holder_name]'] = accountName.validate();
  multiPartRequest.fields['user_bank_account[account_number]'] = accountNumber.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}
