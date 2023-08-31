import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/AppSettingModel.dart';
import '../models/AutoCompletePlacesListModel.dart';
import '../models/CityListModel.dart';
import '../models/CountryListModel.dart';
import '../models/DashboardModel.dart';
import '../models/DeliveryDocumentListModel.dart';
import '../models/DocumentListModel.dart';
import '../models/ExtraChragesListModel.dart';
import '../models/LDBaseResponse.dart';
import '../models/LoginResponse.dart';
import '../models/MonthlyChartModel.dart';
import '../models/NotificationModel.dart';
import '../models/OrderDetailModel.dart';
import '../models/OrderListModel.dart';
import '../models/ParcelTypeListModel.dart';
import '../models/PaymentGatewayListModel.dart';
import '../models/PlaceIdDetailModel.dart';
import '../models/UpdateUserStatus.dart';
import '../models/UserDetailModel.dart';
import '../models/UserListModel.dart';
import '../models/UserModel.dart';
import '../models/VehicleListModel.dart';
import '../models/WithdrawModel.dart';
import '../network/NetworkUtils.dart';
import '../screens/Admin/AdminLoginScreen.dart';
import '../screens/Client/DashboardScreen.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/common.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/shared_pref.dart';
import '../utils/Extensions/string_extensions.dart';

Future<LoginResponse> signUpApi(Map request) async {
  Response response = await buildHttpResponse('register',
      request: request, method: HttpMethod.POST);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }
  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    // if (getStringAsync(USER_TYPE) != ADMIN && getStringAsync(USER_TYPE) != DEMO_ADMIN) {
    //   await setValue(USER_ID, loginResponse.data!.id.validate());
    //   await setValue(USER_NAME, loginResponse.data!.name.validate());
    //   await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    //   await setValue(TOKEN, loginResponse.data!.fcmToken.validate());
    //   await setValue(USER_CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
    //   await setValue(USER_PROFILE_PHOTO, loginResponse.data!.profileImage.validate());
    //   await setValue(USER_TYPE, loginResponse.data!.userType.validate());
    //   await setValue(USER_NAME, loginResponse.data!.username.validate());
    //   await setValue(USER_ADDRESS, loginResponse.data!.address.validate());
    //   await setValue(COUNTRY_ID, loginResponse.data!.countryId.validate());
    //   await setValue(CITY_ID, loginResponse.data!.cityId.validate());
    //   await setValue(IS_VERIFIED_DELIVERY_MAN, loginResponse.data!.isVerifiedDeliveryMan == 1);
    //
    //   await userService.getUser(email: loginResponse.data!.email.validate()).then((value) async {
    //     await setValue(UID, loginResponse.data!.uid.validate());
    //   }).catchError((e) {
    //     log(e.toString());
    //     if (e.toString() == "User not found") {
    //       toast('user Not Found');
    //     }
    //   });
    //
    //   await clientStore.setClientEmail(loginResponse.data!.email.validate());
    //   await appStore.setLoggedIn(true);
    //
    //   await setValue(USER_PASSWORD, request['password']);
    // }

    return loginResponse;
  }).catchError((e) {
    log(e.toString());
    throw e.toString();
  });
}

Future<LoginResponse> logInApi(Map request,
    {bool isSocialLogin = false}) async {
  Response response = await buildHttpResponse('login',
      request: request, method: HttpMethod.POST);
  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    /*if (request['login_type'] == LoginTypeGoogle) {
      await setValue(USER_PHOTO_URL, request['image']);
    } else {
      await setValue(USER_PHOTO_URL, loginResponse.userData!.profile_image.validate());
    }

    await setValue(GENDER, loginResponse.userData!.gender.validate());
    await setValue(NAME, loginResponse.userData!.name.validate());
    await setValue(BIO, loginResponse.userData!.bio.validate());
    await setValue(DOB, loginResponse.userData!.dob.validate());
*/

    await setValue(USER_ID, loginResponse.data!.id.validate());
    await setValue(NAME, loginResponse.data!.name.validate());
    await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    await setValue(TOKEN, loginResponse.data!.apiToken.validate());
    await setValue(
        USER_CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
    await setValue(
        USER_PROFILE_PHOTO, loginResponse.data!.profileImage.validate());
    await setValue(USER_TYPE, loginResponse.data!.userType.validate());
    await setValue(USER_NAME, loginResponse.data!.username.validate());
    await setValue(USER_STATUS, loginResponse.data!.status.validate());
    await setValue(USER_ADDRESS, loginResponse.data!.address.validate());
    await setValue(COUNTRY_ID, loginResponse.data!.countryId.validate());
    await setValue(CITY_ID, loginResponse.data!.cityId.validate());

    await userService
        .getUser(email: loginResponse.data!.email.validate())
        .then((value) async {
      await setValue(UID, value.uid.validate());
    }).catchError((e) {
      log(e.toString());
      if (e.toString() == "User not found") {
        toast('user Not Found');
      }
    });

    await setValue(IS_VERIFIED_DELIVERY_MAN,
        loginResponse.data!.isVerifiedDeliveryMan == 1);
    await clientStore.setClientEmail(loginResponse.data!.email.validate());
    if (getIntAsync(USER_STATUS) == 1) {
      await appStore.setLoggedIn(true);
    } else {
      await appStore.setLoggedIn(false);
    }

    await setValue(USER_PASSWORD, request['password']);
    appStore.setUserProfile(getStringAsync(USER_PROFILE_PHOTO));

    return loginResponse;
  }).catchError((e) {
    throw e.toString();
  });
}

Future<void> logout(BuildContext context,
    {bool isFromLogin = false, bool isDeleteAccount = false}) async {
  clearData() async {
    await removeKey(USER_ID);
    await removeKey(USER_NAME);
    await removeKey(TOKEN);
    await removeKey(USER_CONTACT_NUMBER);
    await removeKey(USER_PROFILE_PHOTO);
    await removeKey(USER_TYPE);
    await removeKey(USER_NAME);
    await removeKey(USER_ADDRESS);
    await removeKey(USER_STATUS);
    await removeKey(COUNTRY_ID);
    await removeKey(COUNTRY_DATA);
    await removeKey(CITY_ID);
    await removeKey(CITY_DATA);
    await removeKey(FILTER_DATA);
    await removeKey(IS_VERIFIED_DELIVERY_MAN);
    await removeKey(IS_LOGGED_IN);
    await removeKey(FCM_TOKEN);
    await appStore.setLoggedIn(false);
    clientStore.setFiltering(false);
    clientStore.availableBal = 0;

    if (!getBoolAsync(REMEMBER_ME) ||
        getStringAsync(USER_TYPE) == ADMIN ||
        getStringAsync(USER_TYPE) == DEMO_ADMIN) {
      await removeKey(USER_EMAIL);
      await removeKey(USER_PASSWORD);
    }
    if (isFromLogin) {
      toast('These credential do not match our records');
    } else {
      if (getStringAsync(USER_TYPE) == ADMIN ||
          getStringAsync(USER_TYPE) == DEMO_ADMIN) {
        Navigator.pushNamedAndRemoveUntil(context, AdminLoginScreen.route,
            (route) {
          return true;
        });
      } else {
        Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route,
            (route) {
          return true;
        });
      }
    }
    appStore.setLoading(false);
  }

  if (getStringAsync(USER_TYPE) == ADMIN ||
      getStringAsync(USER_TYPE) == DEMO_ADMIN) {
    removeKey(THEME_MODE_INDEX);
    appStore.setDarkMode(false);
    if (!isFromLogin) {
      Navigator.pop(context);
      appStore.setLoading(true);
    }
  }
  if (isDeleteAccount) {
    clearData();
  } else {
    await logoutApi().then((value) async {
      clearData();
    }).catchError((e) {
      appStore.setLoading(false);
      throw e.toString();
    });
  }
}

List<UserModel> driversList = [];

List<UserModel> usersList = [];
Future<void> getAllDriver() async {
  final res = await http.get(Uri.parse(mBaseUrl + "getalldriveramount"));
  final response = jsonDecode(res.body);

  if (res.statusCode == 200) {
    driversList.clear(); // Clear the driversList before adding new data

    response.forEach((element) {
      driversList.add(
        UserModel(
          name: element["name"],
          createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
          createdAtMonth: DateTime.parse(element["created_at"]).month.toString(),
          idNo: element["id_no"],
          orderAmount: element["delivery_man_order"],
          userType: element["user_type"],
          amount: element["delivery_man_order"].length == 0 ? "0" : element["delivery_man_order"][0]["total_amount"].toString(),
        ),
      );
    });

    print(response);
  }
}

// Future getAllDriver() async {
//   final res = await http.get(Uri.parse(mBaseUrl + "getalldriveramount"));
//   final response = jsonDecode(res.body);
//
//   if (res.statusCode == 200) {
//     response.forEach((element) {
//       driversList.add(
//         UserModel(
//           name: element["name"],
//           createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
//           createdAtMonth:
//               DateTime.parse(element["created_at"]).month.toString(),
//           idNo: element["id_no"],
//           orderAmount: element["delivery_man_order"],
//           userType: element["user_type"],
//           amount: element["delivery_man_order"].length == 0
//               ? "0"
//               : element["delivery_man_order"][0]["total_amount"].toString(),
//         ),
//       );
//     });
//     print(response);
//   }
// }

Future searchDriver(String username) async {
  driversList.clear();
  final res = await http.get(Uri.parse(mBaseUrl + "searchdrivers/$username/"));
  final response = jsonDecode(res.body);

  if (res.statusCode == 200) {
    response.forEach((element) {
      driversList.add(
        UserModel(
          name: element["name"],
          createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
          createdAtMonth:
              DateTime.parse(element["created_at"]).month.toString(),
          idNo: element["id_no"],
          orderAmount: element["order"] ?? [],
          userType: element["user_type"],
        ),
      );
    });
    print(response);
  }
}

Future searchDriverByPlate(String plate) async {
  driversList.clear();
  final res =
      await http.get(Uri.parse(mBaseUrl + "searchdriversbyplate/$plate/"));
  final response = jsonDecode(res.body);

  if (res.statusCode == 200) {
    response.forEach((element) {
      driversList.add(
        UserModel(
          name: element["name"],
          createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
          createdAtMonth:
              DateTime.parse(element["created_at"]).month.toString(),
          idNo: element["id_no"],
          orderAmount: element["order"] ?? [],
          userType: element["user_type"],
        ),
      );
    });
    print(response);
  }
}

//-------------------------------------------------------------------------------------------------------------------------
Future<void> getAllUsers() async {
  final res = await http.get(Uri.parse(mBaseUrl + "getallusers"));
  final response = jsonDecode(res.body);

  if (res.statusCode == 200) {
    usersList.clear(); // Clear the usersList before adding new data

    response.forEach((element) {
      usersList.add(
        UserModel(
          name: element["name"] ?? "No Data",
          createdAtYear: DateTime.parse(element["created_at"]).year.toString() ?? "No Data",
          createdAtMonth: DateTime.parse(element["created_at"]).month.toString() ?? "No Data",
          idNo: element["contact_number"] ?? "No Data",
          orderAmount: element["order"] ?? [],
          userType: element["user_type"] ?? "No Data",
        ),
      );
    });

    print(response);
  }
}

// Future getAllUsers() async {
//   final res = await http.get(Uri.parse(mBaseUrl + "getallusers"));
//   final response = jsonDecode(res.body);
//
//   if (res.statusCode == 200) {
//     response.forEach((element) {
//       usersList.add(
//         UserModel(
//           name: element["name"] ?? "No Data",
//           createdAtYear:
//               DateTime.parse(element["created_at"]).year.toString() ??
//                   "No Data",
//           createdAtMonth:
//               DateTime.parse(element["created_at"]).month.toString() ??
//                   "No Data",
//           idNo: element["contact_number"] ?? "No Data",
//           orderAmount: element["order"] ?? [],
//           userType: element["user_type"] ?? "No Data",
//         ),
//       );
//     });
//     print(response);
//   }
// }

// Future searchUsersrByName(String username) async {
//   driversList.clear();
//   final res = await http.get(Uri.parse(mBaseUrl + "/searchusers/$username"));
//   final response = jsonDecode(res.body);
//
//   if (res.statusCode == 200) {
//     response.forEach((element) {
//       driversList.add(
//         UserModel(
//           name: element["name"],
//           createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
//           createdAtMonth:
//               DateTime.parse(element["created_at"]).month.toString(),
//           idNo: element["id_no"],
//           orderAmount: element["order"] ?? [],
//           userType: element["user_type"],
//         ),
//       );
//     });
//     print( "response is here $response");
//   }
// }
Future<void> searchUsersrByName(String username) async {
  usersList.clear();
  final response = await http.get(Uri.parse(mBaseUrl + "searchusers/$username")
  );

  if (response.statusCode == 200) {
    try {
      final responseData = jsonDecode(response.body);
      responseData.forEach((element) {
        usersList.add(
          UserModel(
            name: element["name"],
            createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
            createdAtMonth: DateTime.parse(element["created_at"]).month.toString(),
            //idNo: element["id_no"],
            idNo: element["contact_number"],
            orderAmount: element["order"] ?? [],
            userType: element["user_type"],
          ),
        );
      });
      print("Response data: $responseData");
    } catch (e) {
      print("Error parsing JSON response: $e");
    }
  } else {
    print("HTTP request failed with status code: ${response.statusCode}");
  }
}
Future getAllUsersrByDate(var date1, var date2) async {
  usersList.clear();
  final res =
      await http.get(Uri.parse(mBaseUrl + "getuserbydate/$date1/$date2"));
  final response = jsonDecode(res.body);
  if (res.statusCode == 200) {
    response.forEach((element) {
      usersList.add(
        UserModel(
          name: element["name"],
          createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
          createdAtMonth:
              DateTime.parse(element["created_at"]).month.toString(),
          idNo: element["contact_number"],
          orderAmount: element["order"],
          userType: element["user_type"],
        ),
      );
      print("_____________________$response");
    });
  }
}
//-------------------------------------------------------------------------------------------------------------------------

Future getAllDriverByDate(var date1, var date2) async {
  driversList.clear();
  final res =
      await http.get(Uri.parse(mBaseUrl + "getdriverbydate/$date1/$date2"));
  final response = jsonDecode(res.body);
  if (res.statusCode == 200) {
    response.forEach((element) {
      driversList.add(
        UserModel(
          name: element["name"],
          createdAtYear: DateTime.parse(element["created_at"]).year.toString(),
          createdAtMonth:
              DateTime.parse(element["created_at"]).month.toString(),
          idNo: element["id_no"],
          orderAmount: element["order"],
          userType: element["user_type"],
        ),
      );
      print("_________________________________response");
    });
  }else{
    print("HTTP request failed with status code: ${response.statusCode}");
  }
}

/// Profile Update
Future updateProfile(
    {int? id,
    String? userName,
    String? name,
    String? userEmail,
    String? address,
    String? contactNumber,
    Uint8List? image,
    String? fileName}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = '${id ?? getIntAsync(USER_ID)}';
  if (userName != null)
    multiPartRequest.fields['username'] = userName.validate();
  if (userEmail != null)
    multiPartRequest.fields['email'] = userEmail.validate();
  if (name != null) multiPartRequest.fields['name'] = name.validate();
  if (contactNumber != null)
    multiPartRequest.fields['contact_number'] = contactNumber.validate();
  if (address != null) multiPartRequest.fields['address'] = address.validate();

  if (image != null) {
    multiPartRequest.files.add(
        MultipartFile.fromBytes('profile_image', image, filename: fileName));
  }

  print('req: ${multiPartRequest.fields} ${multiPartRequest.files}');
  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      LoginResponse res = LoginResponse.fromJson(data);
      if (id == null) {
        await setValue(NAME, res.data!.name.validate());
        await setValue(USER_NAME, res.data!.username.validate());
        await setValue(USER_ADDRESS, res.data!.address.validate());
        await setValue(USER_CONTACT_NUMBER, res.data!.contactNumber.validate());
        await setValue(USER_EMAIL, res.data!.email.validate());
        appStore.setUserProfile(res.data!.profileImage.validate());
      }
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<LDBaseResponse> forgotPassword(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'forget-password',
      request: req,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> changePassword(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'change-password',
      request: req,
      method: HttpMethod.POST)));
}

// User Api
Future<UserListModel> getAllUserList(
    {String? type, int? perPage, int? page}) async {
  return UserListModel.fromJson(await handleResponse(await buildHttpResponse(
      'user-list?user_type=$type&page=$page&is_deleted=1&per_page=$perPage',
      method: HttpMethod.GET)));
}

Future<UpdateUserStatus> updateUserStatus(Map req) async {
  return UpdateUserStatus.fromJson(await handleResponse(await buildHttpResponse(
      'update-user-status',
      request: req,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteUser(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'delete-user',
      request: req,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> userAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'user-action',
      request: request,
      method: HttpMethod.POST)));
}

Future<UserModel> getUserDetail(int id) async {
  return UserModel.fromJson(await handleResponse(
          await buildHttpResponse('user-detail?id=$id', method: HttpMethod.GET))
      .then((value) => value['data']));
}

// Country Api
Future<CountryListModel> getCountryList(
    {int? page, bool isDeleted = false, int perPage = 10, int? vehicleID}) async {
  return CountryListModel.fromJson(await handleResponse(await buildHttpResponse(
      page != null
          ? 'country-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage'
          : 'country-list?per_page=-1&is_deleted=${isDeleted ? 1 : 0}',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> addCountry(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'country-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteCountry(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('country-delete/$id', method: HttpMethod.POST)));
}

Future<CountryData> getCountryDetail(int id) async {
  return CountryData.fromJson(await handleResponse(await buildHttpResponse(
          'country-detail?id=$id',
          method: HttpMethod.GET))
      .then((value) => value['data']));
}

Future<LDBaseResponse> countryAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'country-action',
      request: request,
      method: HttpMethod.POST)));
}

// City Api
Future<CityListModel> getCityList(
    {int? page,
    bool isDeleted = false,
    int? countryId,
    String? vehicle_type,
    String? order_type,
    int? perPage = 10}) async {
  if (countryId == null) {
    return CityListModel.fromJson(await handleResponse(await buildHttpResponse(
        page != null
            ? 'city-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage'
            : 'city-list?per_page=-1&is_deleted=${isDeleted ? 1 : 0}',
        method: HttpMethod.GET)));
  } else {
    return CityListModel.fromJson(await handleResponse(await buildHttpResponse(
        'city-list?per_page=-1&country_id=$countryId&vehicle_type=$vehicle_type&order_type=$order_type',
        method: HttpMethod.GET)));
  }
}

Future<LDBaseResponse> addCity(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'city-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteCity(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('city-delete/$id', method: HttpMethod.POST)));
}

Future<LDBaseResponse> cityAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'city-action',
      request: request,
      method: HttpMethod.POST)));
}

Future<CityData> getCityDetail(int id) async {
  return CityData.fromJson(await handleResponse(
          await buildHttpResponse('city-detail?id=$id', method: HttpMethod.GET))
      .then((value) => value['data']));
}

addVehicle({
  int? id,
  String? title,
  String? type,
  String? size,
  String? capacity,
  String? cityId,
  String? description,
  String? vehicleImage,
  Uint8List? image,
  int? status,
}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('vehicle-save');
  if (id != null) multiPartRequest.fields['id'] = id.toString();
  if (title != null) multiPartRequest.fields['title'] = title.validate();
  if (type != null) multiPartRequest.fields['type'] = type.validate();
  if (size != null) multiPartRequest.fields['size'] = size.validate();
  if (capacity != null)
    multiPartRequest.fields['capacity'] = capacity.validate();
  if (cityId != null && cityId.isNotEmpty)
    multiPartRequest.fields['city_ids'] = cityId.toString();
  if (description != null)
    multiPartRequest.fields['description'] = description.validate();
  multiPartRequest.fields['status'] = status.toString();
  if (image != null) {
    multiPartRequest.files.add(MultipartFile.fromBytes('vehicle_image', image,
        filename: vehicleImage));
  }
  print('req: ${multiPartRequest.fields} ${multiPartRequest.files}');
  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    log('$error');
  });
}

Future<VehicleListModel> getVehicleList(
    {String? type,
    int? perPage,
    int? page,
    int? cityID,
    bool isDeleted = false,
    int? totalItem,
    int? totalPage = 10}) async {
  if (cityID != null) {
    return VehicleListModel.fromJson(await handleResponse(
        await buildHttpResponse(
            'vehicle-list?city_id=$cityID&status=1&per_page=-1',
            method: HttpMethod.GET)));
  } else {
    return VehicleListModel.fromJson(await handleResponse(
        await buildHttpResponse('vehicle-list?per_page=-1',
            method: HttpMethod.GET)));
  }
}

Future<LDBaseResponse> addVehicleData(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'vehicle-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteVehicle(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('vehicle-delete/$id', method: HttpMethod.POST)));
}

Future<LDBaseResponse> vehicleAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'vehicle-action',
      request: request,
      method: HttpMethod.POST)));
}

// ExtraCharge Api
Future<ExtraChargesListModel> getExtraChargeList(
    {int? page, bool isDeleted = false, int perPage = 10}) async {
  return ExtraChargesListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'extracharge-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> addExtraCharge(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'extracharge-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteExtraCharge(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'extracharge-delete/$id',
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> extraChargeAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'extracharge-action',
      request: request,
      method: HttpMethod.POST)));
}

// Document Api
Future<DocumentListModel> getDocumentList(
    {int? page, bool isDeleted = false, int perPage = 10}) async {
  return DocumentListModel.fromJson(await handleResponse(await buildHttpResponse(
      'document-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> addDocument(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'document-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteDocument(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('document-delete/$id', method: HttpMethod.POST)));
}

Future<LDBaseResponse> documentAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'document-action',
      request: request,
      method: HttpMethod.POST)));
}

// Delivery Man Documents
Future<DeliveryDocumentListModel> getDeliveryDocumentList(
    {int? page,
    bool isDeleted = false,
    int? deliveryManId,
    int? perPage = 10}) async {
  return DeliveryDocumentListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          deliveryManId != null
              ? 'delivery-man-document-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&delivery_man_id=$deliveryManId&per_page=$perPage'
              : 'delivery-man-document-list?page=$page&is_deleted=${isDeleted ? 1 : 0}&per_page=$perPage',
          method: HttpMethod.GET)));
}

/// Create Order Api
Future<LDBaseResponse> createOrder(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'order-save',
      request: request,
      method: HttpMethod.POST)));
}

/// get OrderList
Future<OrderListModel> getAllOrder(
    {int? page,
    int perPage = 10,
    String? orderStatus,
    String? fromDate,
    String? toDate}) async {
  String endPoint = 'order-list?page=$page&status=trashed&per_page=$perPage';

  if (orderStatus.validate().isNotEmpty) {
    endPoint += '&status=$orderStatus';
  }

  if (fromDate.validate().isNotEmpty && toDate.validate().isNotEmpty) {
    endPoint +=
        '&from_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate.validate()))}&to_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(toDate.validate()))}';
  }

  return OrderListModel.fromJson(await handleResponse(
      await buildHttpResponse(endPoint, method: HttpMethod.GET)));
}

// ParcelType Api
Future<ParcelTypeListModel> getParcelTypeList(
    {int? page, int perPage = 10}) async {
  return ParcelTypeListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          page != null
              ? 'staticdata-list?type=parcel_type&page=$page&per_page=$perPage'
              : 'staticdata-list?type=parcel_type&per_page=-1',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> addParcelType(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'staticdata-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteParcelType(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'staticdata-delete/$id',
      method: HttpMethod.POST)));
}

// Payment Gateway Api
Future<PaymentGatewayListModel> getPaymentGatewayList() async {
  return PaymentGatewayListModel.fromJson(await handleResponse(
      await buildHttpResponse('paymentgateway-list?perPage=-1',
          method: HttpMethod.GET)));
}

// Future paymentgatewaydelete() async {
//   return PaymentGatewayListModel.fromJson(await handleResponse(
//       await buildHttpResponse('paymentgateway-delete',
//           method: HttpMethod.GET)));
// }

Future deleteCreditCard(
  int cardId,
) async {
  final res = await http
      .delete(Uri.parse(mBaseUrl + "paymentgateway-delete/$cardId"), headers: {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
    "Authorization": 'Bearer ${sharedPref.getString('TOKEN')}'
  });

  if (res.statusCode == 200) {
    print(res.body);
  } else {
    print(res.body);
  }
  // notifyListeners();
}

Future<MultipartRequest> getMultiPartRequest(String endPoint,
    {String? baseUrl}) async {
//Future<MultipartRequest> getMultiPartRequest(String endPoint, {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  return MultipartRequest('POST', Uri.parse(url));
}

Future<void> sendMultiPartRequest(MultipartRequest multiPartRequest,
    {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  multiPartRequest.headers.addAll(buildHeaderTokens());
  http.Response response =
      await http.Response.fromStream(await multiPartRequest.send());

  if (response.statusCode >= 200 && response.statusCode <= 206) {
    onSuccess?.call(jsonDecode(response.body));
  } else {
    onError?.call(language.somethingWentWrong);
  }
}

// Dashboard Api
Future<DashboardModel> getDashBoardData() async {
  return DashboardModel.fromJson(await handleResponse(
      await buildHttpResponse('dashboard-detail', method: HttpMethod.GET)));
}

Future<MonthlyChartModel> getDashBoardChartData(
    String? type, String? startDate, String? endDate) async {
  return MonthlyChartModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'dashboard-chartdata?type=$type&start_at=$startDate&end_at=$endDate',
          method: HttpMethod.GET)));
}

Future<MonthlyCancelPaymentChartModel> getCancelPaymentChartData(
    String? type, String? startDate, String? endDate) async {
  return MonthlyCancelPaymentChartModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'dashboard-chartdata?type=$type&start_at=$startDate&end_at=$endDate',
          method: HttpMethod.GET)));
}

Future<MonthlyCompletePaymentChartModel> getCompletePaymentChartData(
    String? type, String? startDate, String? endDate) async {
  return MonthlyCompletePaymentChartModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'dashboard-chartdata?type=$type&start_at=$startDate&end_at=$endDate',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> getRestoreOrderApi(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'order-action',
      request: req,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteOrderApi(int OrderId) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'order-delete/$OrderId',
      method: HttpMethod.POST)));
}

Future<UserListModel> getAllDeliveryBoyList(
    {String? type,
    int? page,
    int? cityID,
    int? countryId,
    int? perPage = 10}) async {
  return UserListModel.fromJson(await handleResponse(await buildHttpResponse(
      'user-list?user_type=$type&page=$page&country_id=$countryId&city_id=$cityID&status=1&per_page=$perPage',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> orderAssign(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'order-action',
      request: req,
      method: HttpMethod.POST)));
}

Future<OrderDetailModel> orderDetail({required int orderId}) async {
  return OrderDetailModel.fromJson(await handleResponse(await buildHttpResponse(
      'order-detail?id=$orderId',
      method: HttpMethod.GET)));
}

Future<NotificationModel> getNotification({required int page, Map? req}) async {
  if (req != null) {
    return NotificationModel.fromJson(await handleResponse(
        await buildHttpResponse('notification-list',
            request: req, method: HttpMethod.POST)));
  } else {
    return NotificationModel.fromJson(await handleResponse(
        await buildHttpResponse('notification-list?limit=20&page=$page',
            method: HttpMethod.POST)));
  }
}

Future<AppSettingModel> getAppSetting() async {
  return AppSettingModel.fromJson(await handleResponse(
      await buildHttpResponse('get-appsetting', method: HttpMethod.GET)));
}

Future<LDBaseResponse> setNotification(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'update-appsetting',
      request: req,
      method: HttpMethod.POST)));
}

Future<AutoCompletePlacesListModel> placeAutoCompleteApi(
    {String searchText = '',
    String countryCode = "in",
    String language = 'en'}) async {
  return AutoCompletePlacesListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'place-autocomplete-api?country_code=$countryCode&language=$language&search_text=$searchText',
          method: HttpMethod.GET)));
}

Future<PlaceIdDetailModel> getPlaceDetail({String placeId = ''}) async {
  return PlaceIdDetailModel.fromJson(await handleResponse(
      await buildHttpResponse('place-detail-api?placeid=$placeId',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> logoutApi() async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'logout?clear=fcm_token',
      method: HttpMethod.GET)));
}

// Wallet Api
Future<WithDrawListModel> getWithdrawList({int? page, int perPage = 10}) async {
  return WithDrawListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'withdrawrequest-list?page=$page&per_page=$perPage',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> deleteWithdraw(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'decline-withdrawrequest',
      request: req,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> approveWithdraw(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'approved-withdrawrequest',
      request: req,
      method: HttpMethod.POST)));
}

Future<UserDetailModel> userDetailApi(int id) async {
  return UserDetailModel.fromJson(await handleResponse(await buildHttpResponse(
      'user-profile-detail?id=$id',
      method: HttpMethod.GET)));
}

Future<WalletHistory> walletUserByUser(int page, int userId) async {
  return WalletHistory.fromJson(await handleResponse(await buildHttpResponse(
      'wallet-list?page=$page&user_id=$userId',
      method: HttpMethod.GET)));
}

Future<EarningList> earningUserByUser(int page, int userId) async {
  return EarningList.fromJson(await handleResponse(await buildHttpResponse(
      'payment-list?page=$page&delivery_man_id=$userId&type=earning',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWallet(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-wallet',
      method: HttpMethod.POST,
      request: request)));
}
