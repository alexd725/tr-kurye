import 'dart:core';
import 'package:contacts_service/contacts_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/CityListModel.dart';
import 'package:mightydelivery_admin_app/models/CountryListModel.dart';
import 'package:mightydelivery_admin_app/models/OrderModel.dart';
import 'package:mightydelivery_admin_app/models/ParcelTypeListModel.dart';
import '../models/VehicleModel.dart';
import 'package:mightydelivery_admin_app/screens/DashboardScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../components/OrderSummeryWidget.dart';
import '../components/PickAddressBottomSheet.dart';
import '../models/AutoCompletePlaceListModel.dart';
import '../models/ExtraChargeRequestModel.dart';
import '../models/PlaceIdDetailModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

class CreateOrderScreen extends StatefulWidget {
  static String tag = '/AppCreateOrderScreen';

  final OrderModel? orderData;

  CreateOrderScreen({this.orderData});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isDeliverNow = true;
  String paymentCollectFrom = PAYMENT_ON_PICKUP;
  var showohiddenoption = 0;
  List<ParcelTypeData> parcelTypeList = [];

  TextEditingController parcelTypeCont = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController totalParcelController =
      TextEditingController(text: '1');

  TextEditingController pickAddressCont = TextEditingController();
  TextEditingController pickPhoneCont = TextEditingController();
  TextEditingController pickDesCont = TextEditingController();
  TextEditingController pickDateController = TextEditingController();
  TextEditingController pickFromTimeController = TextEditingController();
  TextEditingController pickToTimeController = TextEditingController();

  TextEditingController deliverAddressCont = TextEditingController();
  TextEditingController anotherDeliverAddress2Cont = TextEditingController();
  TextEditingController anotherDeliverAddress3Cont = TextEditingController();
  TextEditingController anotherDeliverAddress4Cont = TextEditingController();
  TextEditingController anotherDeliverAddress5Cont = TextEditingController();
  TextEditingController deliverPhoneCont = TextEditingController();
  TextEditingController anotherDeliver2PhoneCont = TextEditingController();
  TextEditingController anotherDeliver3PhoneCont = TextEditingController();
  TextEditingController anotherDeliver4PhoneCont = TextEditingController();
  TextEditingController anotherDeliver5PhoneCont = TextEditingController();
  TextEditingController deliverDesCont = TextEditingController();
  TextEditingController anotherDeliver2DesCont = TextEditingController();
  TextEditingController anotherDeliver3DesCont = TextEditingController();
  TextEditingController anotherDeliver4DesCont = TextEditingController();
  TextEditingController anotherDeliver5DesCont = TextEditingController();
  TextEditingController deliverDateController = TextEditingController();
  TextEditingController deliverFromTimeController = TextEditingController();
  TextEditingController deliverToTimeController = TextEditingController();

  FocusNode pickPhoneFocus = FocusNode();
  FocusNode pickDesFocus = FocusNode();
  FocusNode deliverPhoneFocus = FocusNode();
  FocusNode anotherDeliver2PhoneFocus = FocusNode();
  FocusNode anotherDeliver3PhoneFocus = FocusNode();
  FocusNode anotherDeliver4PhoneFocus = FocusNode();
  FocusNode anotherDeliver5PhoneFocus = FocusNode();
  FocusNode deliverDesFocus = FocusNode();
  FocusNode anotherDeliver2DesFocus = FocusNode();
  FocusNode anotherDeliver3DesFocus = FocusNode();
  FocusNode anotherDeliver4DesFocus = FocusNode();
  FocusNode anotherDeliver5DesFocus = FocusNode();

  /*String deliverCountryCode = '+90';
  String anotherDeliver2CountryCode = '+90';
  String anotherDeliver3CountryCode = '+90';
  String anotherDeliver4CountryCode = '+90';
  String anotherDeliver5CountryCode = '+90';
  String pickupCountryCode = '+90';*/

  String deliverCountryCode = defaultPhoneCode;
  String anotherDeliver2CountryCode = defaultPhoneCode;
  String anotherDeliver3CountryCode = defaultPhoneCode;
  String anotherDeliver4CountryCode = defaultPhoneCode;
  String anotherDeliver5CountryCode = defaultPhoneCode;
  String pickupCountryCode = defaultPhoneCode;

  int selectedTabIndex = 0;

  int? selectedVehicle;

  DateTime? pickFromDateTime,
      pickToDateTime,
      deliverFromDateTime,
      deliverToDateTime;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String? pickLat,
      deliverLat,
      anotherDeliver2Lat,
      anotherDeliver3Lat,
      anotherDeliver4Lat,
      anotherDeliver5Lat;
  String? pickLong,
      deliverLong,
      anotherDeliver2Long,
      anotherDeliver3Long,
      anotherDeliver4Long,
      anotherDeliver5Long;

  num totalDistance = 0;
  num totalAmount = 0;

  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;
  bool isBike = true;
  String vehicle = 'Bike';
  String delivery = 'In-Day Delivery';
  String delivery1 = 'Express Delivery';
  List<ExtraChargeRequestModel> extraChargeList = [];

  int? selectedCountry;
  int? selectedCity;

  CityData? cityData;
  CountryData? countryData;

  List<CountryData> countryList = [];
  List<CityData> cityList = [];
  num? maxWeight;
  num? minWeight;

  List<Predictions> pickPredictionList = [];
  List<Predictions> deliverPredictionList = [];

  String? pickMsg,
      deliverMsg,
      anotherDeliver2Msg,
      anotherDeliver3Msg,
      anotherDeliver4Msg,
      anotherDeliver5Msg;

  VehicleData? vehicleData;

  List<VehicleData> vehicleList = [];
  DateTime? currentBackPressTime;
  Contact? _contact;
  bool isCarry = true;
  num? chargePerAddress = 200;
  num? totalChargePerAddress;
  num? carryPackagesCharge;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
      weightController.text = '1';
    });
  }

  void init() async {
    minWeight = 1;
    maxWeight = 1;
    appStore.isShowVehicle = 0;
    await getAppSettingApiCall();
    await getParcelTypeListApiCall();
    await getVehicleApiCall();
    await getCountryApiCall();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> _askPermissions(int key) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _pickContact(key);
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _pickContact(int key) async {
    try {
      final Contact? contact = await ContactsService.openDeviceContactPicker(
          iOSLocalizedLabels: iOSLocalizedLabels);
      setState(() {
        _contact = contact;
      });
      if (key == 0) {
        pickPhoneCont.text = "";
        pickPhoneCont.text = _contact!.phones![0].value!.toString();
      } else if (key == 1) {
        deliverPhoneCont.text = "";
        deliverPhoneCont.text = _contact!.phones![0].value!.toString();
      } else if (key == 2) {
        anotherDeliver2PhoneCont.text = "";
        anotherDeliver2PhoneCont.text = _contact!.phones![0].value!.toString();
      } else if (key == 3) {
        anotherDeliver3PhoneCont.text = "";
        anotherDeliver3PhoneCont.text = _contact!.phones![0].value!.toString();
      } else if (key == 4) {
        anotherDeliver4PhoneCont.text = "";
        anotherDeliver4PhoneCont.text = _contact!.phones![0].value!.toString();
      } else if (key == 5) {
        anotherDeliver5PhoneCont.text = "";
        anotherDeliver5PhoneCont.text = _contact!.phones![0].value!.toString();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getParcelTypeListApiCall() async {
    appStore.setLoading(true);
    await getParcelTypeList().then((value) {
      appStore.setLoading(false);
      parcelTypeList.clear();
      parcelTypeList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  // getCountryApiCall() async {
  //   appStore.setLoading(true);
  //   await getCountryList().then((value) {
  //     appStore.setLoading(false);
  //     countryList = value.data!;
  //     selectedCountry = countryList[0].id!;
  //     countryData = countryList[0];
  //     getCityApiCall();
  //     setState(() {});
  //   }).catchError((error) {
  //     appStore.setLoading(false);
  //     log(error);
  //   });
  // }
//************
  getCountryApiCall() async {
    appStore.setLoading(true);
    await getCountryList().then((value) {
      appStore.setLoading(false);
      countryList = value.data!;
      //selectedCountry = countryList[0].id!;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  //****************
  // getCityApiCall({String? name}) async {
  //   appStore.setLoading(true);
  //   await getCityList(countryId: selectedCountry!, vehicle_type: vehicle, order_type: isBike ? delivery : delivery1).then((value) {
  //     appStore.setLoading(false);
  //     cityList.clear();
  //     cityList.addAll(value.data!);
  //     print("====================================>${value.data![0].chargePerAddress}");
  //     chargePerAddress = value.data![0].chargePerAddress != null ? value.data![0].chargePerAddress : 0;
  //     selectedCity = cityList[0].id!;
  //
  //     setState(() {});
  //   }).catchError((error) {
  //     appStore.setLoading(false);
  //     log(error);
  //   });
  // }
//***********
  getCityApiCall() async {
    appStore.setLoading(true);
    try {
      await getCityList(
        countryId: selectedCountry!,
        vehicle_type: vehicle,
        order_type: isBike ? delivery : delivery1,
      ).then((value) {
        appStore.setLoading(false);
        cityList.clear();
        cityList.addAll(value.data!);
        if (cityList.isNotEmpty) {
          selectedCity = cityList[0].id!;
          cityData = cityList[0];
          maxWeight = cityData!.maxWeight;
          minWeight = cityData!.minWeight;
          setState(() {
            showohiddenoption = 1;
            getVehicleApiCall();
            weightController.text = minWeight.toString();
          });
        } else {
          setState(() {
            showohiddenoption = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No Data available Select another Options'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } catch (error) {
      appStore.setLoading(false);
      print(error);
      // Handle error case
    }
  }

  //****************
  getCityDetailApiCall() async {
    await getCityDetail(selectedCity ?? 0).then((value) async {
      cityData = value;
      setState(() {});
    }).catchError((error) {});
  }

  // getVehicleApiCall({String? name}) async {
  //   appStore.setLoading(true);
  //   await getVehicleList(cityID: selectedCity).then((value) {
  //     appStore.setLoading(false);
  //     vehicleList.clear();
  //     vehicleList = value.data!;
  //     selectedVehicle = null;
  //     setState(() {});
  //   }).catchError((error) {
  //     appStore.setLoading(false);
  //     log(error);
  //   });
  // }
//********

  getVehicleApiCall({String? name}) async {
    appStore.setLoading(true);
    await getVehicleList(cityID: selectedCity).then((value) {
      appStore.setLoading(false);
      vehicleList.clear();
      vehicleList = value.data!;
      print('vehicleList => ${vehicleList}');
      if (vehicleList.isNotEmpty) selectedVehicle = vehicleList[0].id!;
      setState(() {});
      if (vehicleList.isEmpty)
        showohiddenoption = 0;
      else
        showohiddenoption = 1;
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  //*********
  getAppSettingApiCall() async {
    await getAppSetting().then((value) {
      carryPackagesCharge = value.carryPackagesCharges;
      print("------------>carryPackagesCharge $carryPackagesCharge");
      // appStore.setCurrencyCode(value.currencyCode ?? currencyCodeDefault);
      print(value);
    }).catchError((error) {
      log(error.toString());
    });
  }

  getTotalAmount() async {  
    totalDistance = await calculateDistance(
        double.tryParse(pickLat!),
        double.tryParse(pickLong!),
        double.tryParse(deliverLat!),
        double.tryParse(deliverLong!));
    totalAmount = 0;
    weightCharge = 0;
    distanceCharge = 0;
    totalExtraCharge = 0;
    totalChargePerAddress = 0;

    /// calculate weight Charge
    if (double.tryParse(weightController.text)! >= minWeight!) {
      weightCharge = double.parse(((double.tryParse(weightController.text)!) *
              cityData!.perWeightCharges!)
          .toStringAsFixed(digitAfterDecimal));
    }

    /// calculate distance Charge
    if (totalDistance > cityData!.minDistance!) {
      distanceCharge = double.parse(((totalDistance - cityData!.minDistance!) *
              cityData!.perDistanceCharges!)
          .toStringAsFixed(digitAfterDecimal));
    }

    /// total amount
    totalAmount = cityData!.fixedCharges! + weightCharge + distanceCharge;

    /// calculate extra charges
    cityData!.extraCharges!.forEach((element) {
      totalExtraCharge += countExtraCharge(
          totalAmount: totalAmount,
          charges: element.charges!,
          chargesType: element.chargesType!);
    });

    if (anotherDeliverAddress5Cont.text.isNotEmpty) {
      totalChargePerAddress = chargePerAddress! * 4;
    } else if (anotherDeliverAddress4Cont.text.isNotEmpty) {
      totalChargePerAddress = chargePerAddress! * 3;
    } else if (anotherDeliverAddress3Cont.text.isNotEmpty) {
      totalChargePerAddress = chargePerAddress! * 2;
    } else if (anotherDeliverAddress2Cont.text.isNotEmpty) {
      totalChargePerAddress = chargePerAddress! * 1;
    } else {
      totalChargePerAddress = 0;
    }

    num? totalCarryPackagesCharge = isCarry == true ? carryPackagesCharge : 0;
    print("totalCarryPackagesCharge $totalCarryPackagesCharge");

    /// All Charges
    totalAmount = double.parse((totalAmount +
            totalExtraCharge +
            totalChargePerAddress! +
            totalCarryPackagesCharge!)
        .toStringAsFixed(digitAfterDecimal));
    print("12345 $totalAmount");
  }

  extraChargesList() {
    extraChargeList.clear();
    extraChargeList.add(ExtraChargeRequestModel(
        key: FIXED_CHARGES, value: cityData!.fixedCharges, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(
        key: MIN_DISTANCE, value: cityData!.minDistance, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(
        key: MIN_WEIGHT, value: minWeight, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(
        key: PER_DISTANCE_CHARGE,
        value: cityData!.perDistanceCharges,
        valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(
        key: PER_WEIGHT_CHARGE,
        value: cityData!.perWeightCharges,
        valueType: ""));
    cityData!.extraCharges!.forEach((element) {
      extraChargeList.add(ExtraChargeRequestModel(
          key: element.title!.toLowerCase().replaceAll(' ', "_"),
          value: element.charges,
          valueType: element.chargesType));
    });
  }

  createOrderApiCall(String orderStatus) async {
    Map req = {
      "id": "",
      "client_id": sharedPref.getInt(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": selectedCountry.toString(),
      "city_id": selectedCity.toString(),
      if (appStore.isShowVehicle == 1) "vehicle_id": selectedVehicle.toString(),
      "courier_will_carry": isCarry == true ? 1 : 0,
      "charge_per_address": totalChargePerAddress,
      "carry_packages_charge": isCarry == true ? carryPackagesCharge : 0,
      "pickup_point": {
        "start_time": (!isDeliverNow && pickFromDateTime != null)
            ? pickFromDateTime.toString()
            : DateTime.now().toString(),
        "end_time": (!isDeliverNow && pickToDateTime != null)
            ? pickToDateTime.toString()
            : null,
        "address": pickAddressCont.text,
        "latitude": pickLat,
        "longitude": pickLong,
        "description": pickDesCont.text,
        "contact_number": '$pickupCountryCode ${pickPhoneCont.text.trim()}'
      },
      "delivery_point": [
        {
          "start_time": (!isDeliverNow && deliverFromDateTime != null)
              ? deliverFromDateTime.toString()
              : null,
          "end_time": (!isDeliverNow && deliverToDateTime != null)
              ? deliverToDateTime.toString()
              : null,
          "address": deliverAddressCont.text,
          "latitude": deliverLat,
          "longitude": deliverLong,
          "description": deliverDesCont.text,
          "contact_number":
              '$deliverCountryCode ${deliverPhoneCont.text.trim()}',
        },
        if (anotherDeliverAddress2Cont.text.isNotEmpty)
          {
            "start_time": (!isDeliverNow && deliverFromDateTime != null)
                ? deliverFromDateTime.toString()
                : null,
            "end_time": (!isDeliverNow && deliverToDateTime != null)
                ? deliverToDateTime.toString()
                : null,
            "address": anotherDeliverAddress2Cont.text,
            "latitude": anotherDeliver2Lat,
            "longitude": anotherDeliver2Long,
            "description": anotherDeliver2DesCont.text,
            "contact_number":
                '$anotherDeliver2CountryCode ${anotherDeliver2PhoneCont.text.trim()}',
          },
        if (anotherDeliverAddress3Cont.text.isNotEmpty)
          {
            "start_time": (!isDeliverNow && deliverFromDateTime != null)
                ? deliverFromDateTime.toString()
                : null,
            "end_time": (!isDeliverNow && deliverToDateTime != null)
                ? deliverToDateTime.toString()
                : null,
            "address": anotherDeliverAddress3Cont.text,
            "latitude": anotherDeliver3Lat,
            "longitude": anotherDeliver3Long,
            "description": anotherDeliver3DesCont.text,
            "contact_number":
                '$anotherDeliver3CountryCode ${anotherDeliver3PhoneCont.text.trim()}',
          },
        if (anotherDeliverAddress4Cont.text.isNotEmpty)
          {
            "start_time": (!isDeliverNow && deliverFromDateTime != null)
                ? deliverFromDateTime.toString()
                : null,
            "end_time": (!isDeliverNow && deliverToDateTime != null)
                ? deliverToDateTime.toString()
                : null,
            "address": anotherDeliverAddress4Cont.text,
            "latitude": anotherDeliver4Lat,
            "longitude": anotherDeliver4Long,
            "description": anotherDeliver4DesCont.text,
            "contact_number":
                '$anotherDeliver4CountryCode ${anotherDeliver4PhoneCont.text.trim()}',
          },
        if (anotherDeliverAddress5Cont.text.isNotEmpty)
          {
            "start_time": (!isDeliverNow && deliverFromDateTime != null)
                ? deliverFromDateTime.toString()
                : null,
            "end_time": (!isDeliverNow && deliverToDateTime != null)
                ? deliverToDateTime.toString()
                : null,
            "address": anotherDeliverAddress5Cont.text,
            "latitude": anotherDeliver5Lat,
            "longitude": anotherDeliver5Long,
            "description": anotherDeliver5DesCont.text,
            "contact_number":
                '$anotherDeliver5CountryCode ${anotherDeliver5PhoneCont.text.trim()}',
          },
      ],
      "selected_delivery_point": paymentCollectFrom == "on_another_delivery2"
          ? {
              "start_time": (!isDeliverNow && deliverFromDateTime != null)
                  ? deliverFromDateTime.toString()
                  : null,
              "end_time": (!isDeliverNow && deliverToDateTime != null)
                  ? deliverToDateTime.toString()
                  : null,
              "address": anotherDeliverAddress2Cont.text,
              "latitude": anotherDeliver2Lat,
              "longitude": anotherDeliver2Long,
              "description": anotherDeliver2DesCont.text,
              "contact_number":
                  '$anotherDeliver2CountryCode ${anotherDeliver2PhoneCont.text.trim()}',
            }
          : paymentCollectFrom == "on_another_delivery3"
              ? {
                  "start_time": (!isDeliverNow && deliverFromDateTime != null)
                      ? deliverFromDateTime.toString()
                      : null,
                  "end_time": (!isDeliverNow && deliverToDateTime != null)
                      ? deliverToDateTime.toString()
                      : null,
                  "address": anotherDeliverAddress3Cont.text,
                  "latitude": anotherDeliver3Lat,
                  "longitude": anotherDeliver3Long,
                  "description": anotherDeliver3DesCont.text,
                  "contact_number":
                      '$anotherDeliver3CountryCode ${anotherDeliver3PhoneCont.text.trim()}',
                }
              : paymentCollectFrom == "on_another_delivery4"
                  ? {
                      "start_time":
                          (!isDeliverNow && deliverFromDateTime != null)
                              ? deliverFromDateTime.toString()
                              : null,
                      "end_time": (!isDeliverNow && deliverToDateTime != null)
                          ? deliverToDateTime.toString()
                          : null,
                      "address": anotherDeliverAddress4Cont.text,
                      "latitude": anotherDeliver4Lat,
                      "longitude": anotherDeliver4Long,
                      "description": anotherDeliver4DesCont.text,
                      "contact_number":
                          '$anotherDeliver4CountryCode ${anotherDeliver4PhoneCont.text.trim()}',
                    }
                  : paymentCollectFrom == "on_another_delivery5"
                      ? {
                          "start_time":
                              (!isDeliverNow && deliverFromDateTime != null)
                                  ? deliverFromDateTime.toString()
                                  : null,
                          "end_time":
                              (!isDeliverNow && deliverToDateTime != null)
                                  ? deliverToDateTime.toString()
                                  : null,
                          "address": anotherDeliverAddress5Cont.text,
                          "latitude": anotherDeliver5Lat,
                          "longitude": anotherDeliver5Long,
                          "description": anotherDeliver5DesCont.text,
                          "contact_number":
                              '$anotherDeliver5CountryCode ${anotherDeliver5PhoneCont.text.trim()}',
                        }
                      : {
                          "start_time":
                              (!isDeliverNow && deliverFromDateTime != null)
                                  ? deliverFromDateTime.toString()
                                  : null,
                          "end_time":
                              (!isDeliverNow && deliverToDateTime != null)
                                  ? deliverToDateTime.toString()
                                  : null,
                          "address": deliverAddressCont.text,
                          "latitude": deliverLat,
                          "longitude": deliverLong,
                          "description": deliverDesCont.text,
                          "contact_number":
                              '$deliverCountryCode ${deliverPhoneCont.text.trim()}',
                        },
      "extra_charges": extraChargeList,
      "parcel_type": parcelTypeCont.text,
      "total_weight": double.tryParse(weightController.text),
      "total_distance": totalDistance.toStringAsFixed(digitAfterDecimal),
      "payment_collect_from": paymentCollectFrom,
      "status": orderStatus,
      "payment_type": PAYMENT_TYPE_CASH,
      "payment_status": "",
      "fixed_charges": cityData?.fixedCharges.toString(),
      "parent_order_id": "",
      "total_amount": totalAmount,
      "weight_charge": weightCharge,
      "distance_charge": distanceCharge,
      "total_parcel": int.tryParse(totalParcelController.text),
      "vehicle_type": vehicle,
      "order_type": isBike ? delivery : delivery1,
    };
    appStore.setLoading(true);
    await createOrder(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      Navigator.pop(context);
      launchScreen(context, DashboardScreen(), isNewTask: true);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  Future<List<Predictions>> getPlaceAutoCompleteApiCall(String text) async {
    List<Predictions> list = [];
    await placeAutoCompleteApi(
            searchText: text,
            language: appStore.selectedLanguage,
            countryCode: countryData!.code ?? 'IN')
        .then((value) {
      list = value.predictions ?? [];
    }).catchError((e) {
      throw e.toString();
    });
    return list;
  }

  Future<PlaceIdDetailModel?> getPlaceIdDetailApiCall(
      {required String placeId}) async {
    PlaceIdDetailModel? detailModel;
    await getPlaceDetail(placeId: placeId).then((value) {
      detailModel = value;
    }).catchError((e) {
      throw e.toString();
    });
    return detailModel;
  }

  Widget createOrderWidget1() {
    return Observer(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              scheduleOptionWidget(
                  context: context,
                  isSelected: isDeliverNow,
                  imagePath: 'assets/icons/ic_clock.png',
                  title: language.deliverNow,
                  onTap: () {
                    isDeliverNow = true;
                    setState(() {});
                  }),
              SizedBox(width: 16),
              scheduleOptionWidget(
                  context: context,
                  isSelected: !isDeliverNow,
                  imagePath: 'assets/icons/ic_schedule.png',
                  title: language.schedule,
                  onTap: () {
                    isDeliverNow = false;
                    setState(() {});
                  }),
            ],
          ),
          SizedBox(height: 16),
          Visibility(
            visible: !isDeliverNow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.pickTime, style: boldTextStyle()),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: borderColor,
                        width: appStore.isDarkMode ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  child: Column(
                    children: [
                      DateTimePicker(
                        controller: pickDateController,
                        type: DateTimePickerType.date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2050),
                        onChanged: (value) {
                          pickDate = DateTime.parse(value);
                          deliverDate = null;
                          deliverDateController.clear();
                          setState(() {});
                        },
                        validator: (value) {
                          if (value!.isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                        decoration: commonInputDecoration(
                            suffixIcon: Icons.calendar_today,
                            hintText: language.date),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DateTimePicker(
                              controller: pickFromTimeController,
                              type: DateTimePickerType.time,
                              onChanged: (value) {
                                pickFromTime = TimeOfDay.fromDateTime(
                                    DateFormat('hh:mm').parse(value));
                                setState(() {});
                              },
                              validator: (value) {
                                if (value!.isEmpty)
                                  return errorThisFieldRequired;
                                return null;
                              },
                              decoration: commonInputDecoration(
                                  suffixIcon: Icons.access_time,
                                  hintText: language.from),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DateTimePicker(
                              controller: pickToTimeController,
                              type: DateTimePickerType.time,
                              onChanged: (value) {
                                pickToTime = TimeOfDay.fromDateTime(
                                    DateFormat('hh:mm').parse(value));
                                setState(() {});
                              },
                              validator: (value) {
                                if (value!.isEmpty)
                                  return errorThisFieldRequired;
                                double fromTimeInHour = pickFromTime!.hour +
                                    pickFromTime!.minute / 60;
                                double toTimeInHour =
                                    pickToTime!.hour + pickToTime!.minute / 60;
                                double difference =
                                    toTimeInHour - fromTimeInHour;
                                if (difference <= 0) {
                                  return language.endStartTimeValidationMsg;
                                }
                                return null;
                              },
                              decoration: commonInputDecoration(
                                  suffixIcon: Icons.access_time,
                                  hintText: language.to),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(language.deliverTime, style: boldTextStyle()),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: borderColor,
                        width: appStore.isDarkMode ? 0.2 : 1),
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  child: Column(
                    children: [
                      DateTimePicker(
                        controller: deliverDateController,
                        type: DateTimePickerType.date,
                        initialDate: pickDate ?? DateTime.now(),
                        firstDate: pickDate ?? DateTime.now(),
                        lastDate: DateTime(2050),
                        onChanged: (value) {
                          deliverDate = DateTime.parse(value);
                          setState(() {});
                        },
                        validator: (value) {
                          if (value!.isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                        decoration: commonInputDecoration(
                            suffixIcon: Icons.calendar_today,
                            hintText: language.date),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DateTimePicker(
                              controller: deliverFromTimeController,
                              type: DateTimePickerType.time,
                              onChanged: (value) {
                                deliverFromTime = TimeOfDay.fromDateTime(
                                    DateFormat('hh:mm').parse(value));
                                setState(() {});
                              },
                              validator: (value) {
                                if (value!.isEmpty)
                                  return errorThisFieldRequired;
                                return null;
                              },
                              decoration: commonInputDecoration(
                                  suffixIcon: Icons.access_time,
                                  hintText: language.from),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DateTimePicker(
                              controller: deliverToTimeController,
                              type: DateTimePickerType.time,
                              onChanged: (value) {
                                deliverToTime = TimeOfDay.fromDateTime(
                                    DateFormat('hh:mm').parse(value));
                                setState(() {});
                              },
                              validator: (value) {
                                if (value!.isEmpty)
                                  return errorThisFieldRequired;
                                double fromTimeInHour = deliverFromTime!.hour +
                                    deliverFromTime!.minute / 60;
                                double toTimeInHour = deliverToTime!.hour +
                                    deliverToTime!.minute / 60;
                                double difference =
                                    toTimeInHour - fromTimeInHour;
                                if (difference < 0) {
                                  return language.endStartTimeValidationMsg;
                                }
                                return null;
                              },
                              decoration: commonInputDecoration(
                                  suffixIcon: Icons.access_time,
                                  hintText: language.to),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          ///////////////SHEIKH////////////////

          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle Type', style: boldTextStyle()),
                  SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: vehicle,
                      dropdownColor: Theme.of(context).cardColor,
                      style: primaryTextStyle(),
                      decoration: commonInputDecoration(),
                      items: [
                        DropdownMenuItem(
                            value: "Bike",
                            child: Text("Bike",
                                style: primaryTextStyle(), maxLines: 1)),
                        DropdownMenuItem(
                            value: "Car",
                            child: Text("Car",
                                style: primaryTextStyle(), maxLines: 1)),
                      ],
                      onChanged: (value) {
                        vehicle = value!;
                        print(vehicle);
                        setState(() {
                          if (vehicle == "Bike") {
                            isBike = true;
                            appStore.isShowVehicle = 0;
                            // delivery = "In-Day Delivery";
                          } else {
                            isBike = false;
                            appStore.isShowVehicle = 1;
                            // delivery1 = "Express Delivery";
                          }
                        });
                        getCityApiCall();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Delivery Type', style: boldTextStyle()),
                  SizedBox(
                    height: 8,
                  ),
                  isBike
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: delivery,
                            dropdownColor: Theme.of(context).cardColor,
                            style: primaryTextStyle(),
                            decoration: commonInputDecoration(),
                            items: [
                              DropdownMenuItem(
                                  value: "In-Day Delivery",
                                  child: Text("In-Day Delivery",
                                      style: primaryTextStyle(), maxLines: 1)),
                              DropdownMenuItem(
                                  value: "Express Delivery",
                                  child: Text("Express Delivery",
                                      style: primaryTextStyle(), maxLines: 1)),
                              DropdownMenuItem(
                                  value: "Vip Delivery",
                                  child: Text("Vip Delivery",
                                      style: primaryTextStyle(), maxLines: 1)),
                            ],
                            onChanged: (value) {
                              delivery = value!;
                              selectedCity = null;
                              getCityApiCall();
                              setState(() {});
                            },
                          ),
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: delivery1,
                            dropdownColor: Theme.of(context).cardColor,
                            style: primaryTextStyle(),
                            decoration: commonInputDecoration(),
                            items: [
                              DropdownMenuItem(
                                  value: "Express Delivery",
                                  child: Text("Express Delivery",
                                      style: primaryTextStyle(), maxLines: 1)),
                              DropdownMenuItem(
                                  value: "Vip Delivery",
                                  child: Text("Vip Delivery",
                                      style: primaryTextStyle(), maxLines: 1)),
                            ],
                            onChanged: (value) {
                              delivery1 = value!;
                              selectedCity = null;
                              getCityApiCall();
                              setState(() {});
                            },
                          ),
                        ),
                ],
              )
            ],
          ),
          SizedBox(height: 16),
          ////////////////////////// SHEIKH
          Row(
            children: [
              Expanded(child: Text(language.country, style: boldTextStyle())),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: selectedCountry,
                  decoration: commonInputDecoration(),
                  dropdownColor: Theme.of(context).cardColor,
                  style: primaryTextStyle(),
                  items: countryList.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = null;
                      cityList.clear();
                      selectedCountry = value!;
                    });

                    getCityApiCall();
                  },
                  // onChanged: (value) {
                  //   selectedCountry = value!;
                  //   countryData = countryList.firstWhere((element) => element.id == selectedCountry);
                  //   selectedCity = null;
                  //   cityData = null;
                  //   pickAddressCont.clear();
                  //   pickLat = null;
                  //   pickLong = null;
                  //   deliverAddressCont.clear();
                  //   deliverLat = null;
                  //   deliverLong = null;
                  //   vehicleList.clear();
                  //   getVehicleApiCall();
                  //   //pickPredictionList = [];
                  //   //deliverPredictionList = [];
                  //   // getCityApiCall();
                  //   cityList = [];
                  //   setState(() {});
                  // },
                  validator: (value) {
                    if (selectedCountry == null) return errorThisFieldRequired;
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(language.city, style: boldTextStyle())),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: selectedCity,
                  decoration: commonInputDecoration(),
                  dropdownColor: Theme.of(context).cardColor,
                  style: primaryTextStyle(),
                  items: cityList.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem(
                      value: item.id,
                      child: Text(item.name ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    selectedCity = value!;
                    cityData = cityList
                        .firstWhere((element) => element.id == selectedCity);

                    print(
                        'cityData => ${cityData!.id.toString()} ${cityData!.name}');
                    await getCityDetailApiCall();
                    await getVehicleApiCall();
                    setState(() {
                      minWeight = cityData!.minWeight;
                      weightController.text = minWeight.toString();
                    });
                  },
                  validator: (value) {
                    if (selectedCity == null) return errorThisFieldRequired;
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (appStore.isShowVehicle == 1 && showohiddenoption == 1)
            Row(
              children: [
                Expanded(
                  child: Text(language.select_vehicle, style: boldTextStyle()),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: selectedVehicle,
                    decoration: commonInputDecoration(),
                    dropdownColor: Theme.of(context).cardColor,
                    style: primaryTextStyle(),
                    items: vehicleList.map<DropdownMenuItem<int>>((item) {
                      return DropdownMenuItem(
                        value: item.id,
                        child: Text(item.title ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedVehicle = value;
                      print(selectedVehicle);
                      setState(() {});
                    },
                    validator: (value) {
                      if (selectedVehicle == null) {
                        return errorThisFieldRequired;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ],
            ),
          SizedBox(height: 16),
          Text(language.weight, style: boldTextStyle()),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(defaultRadius)),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(language.weight, style: primaryTextStyle()),
                    ),
                  ),
                  VerticalDivider(thickness: 1),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.remove,
                          color:
                              appStore.isDarkMode ? Colors.white : Colors.grey),
                    ),
                    onTap: () {
                      if (double.parse(weightController.text) > 1) {
                        weightController.text =
                            (double.parse(weightController.text) - 1)
                                .toString();
                      }
                      if (double.tryParse(weightController.text)! <
                          minWeight!) {
                        weightController.text = minWeight.toString();
                        showAlertDialog2(context);
                      }
                    },
                  ),
                  VerticalDivider(thickness: 1),
                  Container(
                    width: 50,
                    child: AppTextField(
                      controller: weightController,
                      textAlign: TextAlign.center,
                      maxLength: 10,
                      textFieldType: TextFieldType.PHONE,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9 .]')),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  VerticalDivider(thickness: 1),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.add,
                          color:
                              appStore.isDarkMode ? Colors.white : Colors.grey),
                    ),
                    onTap: () {
                      weightController.text =
                          (double.parse(weightController.text) + 1).toString();
                      if (double.tryParse(weightController.text)! >
                          maxWeight!) {
                        weightController.text = maxWeight.toString();
                        showAlertDialog(context);
                      }
                      if (double.tryParse(weightController.text)! <
                          minWeight!) {
                        weightController.text = minWeight.toString();
                        // showAlertDialog2(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(language.numberOfParcels, style: boldTextStyle()),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(defaultRadius)),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(language.numberOfParcels,
                          style: primaryTextStyle()),
                    ),
                  ),
                  VerticalDivider(thickness: 1),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.remove,
                          color:
                              appStore.isDarkMode ? Colors.white : Colors.grey),
                    ),
                    onTap: () {
                      if (int.parse(totalParcelController.text) > 1) {
                        totalParcelController.text =
                            (int.parse(totalParcelController.text) - 1)
                                .toString();
                      }
                    },
                  ),
                  VerticalDivider(thickness: 1),
                  Container(
                    width: 50,
                    child: AppTextField(
                      controller: totalParcelController,
                      textAlign: TextAlign.center,
                      maxLength: 2,
                      textFieldType: TextFieldType.PHONE,
                      decoration: InputDecoration(
                        counterText: '',
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor)),
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  VerticalDivider(thickness: 1),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(Icons.add,
                          color:
                              appStore.isDarkMode ? Colors.white : Colors.grey),
                    ),
                    onTap: () {
                      totalParcelController.text =
                          (int.parse(totalParcelController.text) + 1)
                              .toString();
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(language.parcelType, style: boldTextStyle()),
          SizedBox(height: 8),
          AppTextField(
            controller: parcelTypeCont,
            textFieldType: TextFieldType.OTHER,
            decoration: commonInputDecoration(),
            validator: (value) {
              if (value!.isEmpty) return language.fieldRequiredMsg;
              return null;
            },
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children: parcelTypeList.map((item) {
              return GestureDetector(
                child: Chip(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  label: Text(item.label!),
                  elevation: 0,
                  labelStyle: primaryTextStyle(color: Colors.grey),
                  padding: EdgeInsets.zero,
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    side: BorderSide(
                        color: borderColor,
                        width: appStore.isDarkMode ? 0.2 : 1),
                  ),
                ),
                onTap: () {
                  parcelTypeCont.text = item.label!;
                  setState(() {});
                },
              );
            }).toList(),
          ),
          SwitchListTile(
            value: isCarry,
            onChanged: (value) {
              isCarry = value;
              print(isCarry);
              setState(() {});
            },
            title:
                Text("Courier will carry packages", style: primaryTextStyle()),
            controlAffinity: ListTileControlAffinity.trailing,
            inactiveTrackColor:
                appStore.isDarkMode ? Colors.white12 : Colors.black12,
          ),
        ],
      );
    });
  }

  Widget createOrderWidget2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.pickupInfo, style: boldTextStyle()),
        SizedBox(height: 16),
        Text(language.pickupLocation, style: primaryTextStyle()),
        SizedBox(height: 8),
        //     AppTextField(
        //       controller: pickAddressCont,
        //       textInputAction: TextInputAction.next,
        //       nextFocus: pickPhoneFocus,
        //       textFieldType: TextFieldType.ADDRESS,
        //       decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //       validator: (value) {
        //         if (value!.isEmpty) return language.fieldRequiredMsg;
        //         if (pickLat == null || pickLong == null) return language.pleaseSelectValidAddress;
        //         return null;
        //       },
        //       onTap: () {
        //         showModalBottomSheet(
        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
        //           context: context,
        //           builder: (context) {
        //             return PickAddressBottomSheet(
        //               onPick: (address) {
        //                 deliverAddressCont.text = address.placeAddress ?? "";
        //                 deliverLat = address.latitude.toString();
        //                 deliverLong = address.longitude.toString();
        //                 /*onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();*/
        //                 setState(() {});
        //                 /*} else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }*/
        //               },
        //               isPickup: false,
        //             );
        //             /*),
        // if (deliverMsg != null && deliverMsg!.isNotEmpty)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg ?? "",
        //         style: secondaryTextStyle(color: Colors.red),
        //       )),
        // if (deliverPredictionList.isNotEmpty)
        //   ListView.builder(
        //       physics: NeverScrollableScrollPhysics(),
        //       controller: ScrollController(),
        //       shrinkWrap: true,
        //       padding: EdgeInsets.only(top: 16, bottom: 16),
        //       itemCount: deliverPredictionList.length,
        //       itemBuilder: (context, index) {
        //         Predictions mData = deliverPredictionList[index];
        //         return ListTile(
        //           leading: Icon(Icons.location_pin, color: primaryColor),
        //           title: Text(mData.description ?? "", style: primaryTextStyle()),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               deliverAddressCont.text = mData.description ?? "";
        //               deliverLat = response.result!.geometry!.location!.lat.toString();
        //               deliverLong = response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }*/
        //           },
        //         );
        //       },
        //       onChanged: (val) async {
        //         pickMsg = '';
        //         pickLat = null;
        //         pickLong = null;
        //         if (val.isNotEmpty) {
        //           if (val.length < 3) {
        //             pickMsg = language.selectedAddressValidation;
        //             pickPredictionList.clear();
        //             setState(() {});
        //           } else {
        //             pickPredictionList = await getPlaceAutoCompleteApiCall(val);
        //             setState(() {});
        //           }
        //         } else {
        //           pickPredictionList.clear();
        //           setState(() {});
        //         }
        //       },
        //     ),
        //     if (pickMsg != null && pickMsg!.isNotEmpty)
        //       Padding(
        //           padding: EdgeInsets.only(top: 8, left: 8),
        //           child: Text(
        //             pickMsg ?? "",
        //             style: secondaryTextStyle(color: Colors.red),
        //           )),
        //     if (pickPredictionList.isNotEmpty)
        //       ListView.builder(
        //           physics: NeverScrollableScrollPhysics(),
        //           controller: ScrollController(),
        //           shrinkWrap: true,
        //           padding: EdgeInsets.only(top: 16, bottom: 16),
        //           itemCount: pickPredictionList.length,
        //           itemBuilder: (context, index) {
        //             Predictions mData = pickPredictionList[index];
        //             return ListTile(
        //               leading: Icon(Icons.location_pin, color: primaryColor),
        //               title: Text(mData.description ?? "", style: primaryTextStyle()),
        //               onTap: () async {
        //                 PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //                 if (response != null) {
        //                   pickAddressCont.text = mData.description ?? "";
        //                   pickLat = response.result!.geometry!.location!.lat.toString();
        //                   pickLong = response.result!.geometry!.location!.lng.toString();
        //                   pickPredictionList.clear();
        //                   setState(() {});
        //                 }
        //               },
        //             );
        //           }),
        //  ********************************************
        AppTextField(
          controller: pickAddressCont,
          textInputAction: TextInputAction.next,
          nextFocus: pickPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (pickLat == null || pickLong == null)
              return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    pickAddressCont.text = address.placeAddress ?? "";
                    pickLat = address.latitude.toString();
                    pickLong = address.longitude.toString();
                    setState(() {});
                    /*} else {
                pickPredictionList = await getPlaceAutoCompleteApiCall(val);
                setState(() {});
              }
            } else {
              pickPredictionList.clear();
              setState(() {});
            }*/
                  },
                );
                /*),
        if (pickMsg != null && pickMsg!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                pickMsg ?? "",
                style: secondaryTextStyle(color: Colors.red),
              )),
        if (pickPredictionList.isNotEmpty)
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: ScrollController(),
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16, bottom: 16),
              itemCount: pickPredictionList.length,
              itemBuilder: (context, index) {
                Predictions mData = pickPredictionList[index];
                return ListTile(
                  leading: Icon(Icons.location_pin, color: primaryColor),
                  title: Text(mData.description ?? "", style: primaryTextStyle()),
                  onTap: () async {
                    PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                    if (response != null) {
                      pickAddressCont.text = mData.description ?? "";
                      pickLat = response.result!.geometry!.location!.lat.toString();
                      pickLong = response.result!.geometry!.location!.lng.toString();
                      pickPredictionList.clear();
                      setState(() {});
                    }*/
              },
            );
          },
        ),
        //*********************************************8
        //       AppTextField(
        //       controller: pickAddressCont,
        //   textInputAction: TextInputAction.next,
        //   nextFocus: pickPhoneFocus,
        //   textFieldType: TextFieldType.ADDRESS,
        //   decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //   validator: (value) {
        //   if (value!.isEmpty) return language.fieldRequiredMsg;
        //   if (pickLat == null || pickLong == null) return language.pleaseSelectValidAddress;
        //   return null;
        //   },
        //   onTap: () {
        //   showModalBottomSheet(
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
        //   context: context,
        //   builder: (context) {
        //   return PickAddressBottomSheet(
        //   onPick: (address) {
        //   pickAddressCont.text = address.placeAddress ?? "";
        //   pickLat = address.latitude.toString();
        //   pickLong = address.longitude.toString();
        //   setState(() {});
        //   }, // Add the missing closing parenthesis here
        //
        //           );
        //   },
        //   );
        //   },
        // ),

        SizedBox(height: 16),
        Text(language.pickupContactNumber, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: pickPhoneCont,
          textFieldType: TextFieldType.PHONE,
          focus: pickPhoneFocus,
          nextFocus: pickDesFocus,
          textInputAction: TextInputAction.next,
          decoration: commonInputDecoration(
              suffixIcon: Icons.phone,
              suffixOnTap: () {
                _askPermissions(0);
              },
              prefixIcon: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountryCodePicker(
                      initialSelection: pickupCountryCode,
                      showCountryOnly: false,
                      showFlag: true,
                      showFlagDialog: true,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      dialogSize: Size(MediaQuery.of(context).size.width - 60,
                          MediaQuery.of(context).size.height * 0.6),
                      textStyle: primaryTextStyle(),
                      dialogBackgroundColor: Theme.of(context).cardColor,
                      barrierColor: Colors.black12,
                      dialogTextStyle: primaryTextStyle(),
                      searchDecoration: InputDecoration(
                        iconColor: Theme.of(context).dividerColor,
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).dividerColor)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor)),
                      ),
                      searchStyle: primaryTextStyle(),
                      onInit: (c) {
                        pickupCountryCode = c!.dialCode!;
                      },
                      onChanged: (c) {
                        pickupCountryCode = c.dialCode!;
                      },
                    ),
                    VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                  ],
                ),
              )),
          validator: (s) {
            if (s!.trim().isEmpty) return language.fieldRequiredMsg;
            if (s.trim().length < minContactLength ||
                s.trim().length > maxContactLength)
              return language.contactLengthValidation;
            /*validator: (value) {
            if (value!.trim().isEmpty) return errorThisFieldRequired;
            if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLengthValidation;*/
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 16),
        Text(language.pickupDescription, style: primaryTextStyle()),
        SizedBox(height: 8),
        TextField(
          controller: pickDesCont,
          focusNode: pickDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget createOrderWidget3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.deliveryInformation, style: boldTextStyle()),
        SizedBox(height: 16),
        Text(language.deliveryLocation, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: deliverAddressCont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (deliverLat == null || deliverLong == null)
              return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    deliverAddressCont.text = address.placeAddress ?? "";
                    deliverLat = address.latitude.toString();
                    deliverLong = address.longitude.toString();
                    /*onChanged: (val) async {
        deliverMsg = '';
        deliverLat = null;
        deliverLong = null;
        if (val.isNotEmpty) {
          if (val.length < 3) {
            deliverMsg = language.selectedAddressValidation;
            deliverPredictionList.clear();*/
                    setState(() {});
                    /*} else {
            deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
            setState(() {});
          }
        } else {
          deliverPredictionList.clear();
          setState(() {});
        }*/
                  },
                  isPickup: false,
                );
                /*),
    if (deliverMsg != null && deliverMsg!.isNotEmpty)
      Padding(
          padding: EdgeInsets.only(top: 8, left: 8),
          child: Text(
            deliverMsg ?? "",
            style: secondaryTextStyle(color: Colors.red),
          )),
    if (deliverPredictionList.isNotEmpty)
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: ScrollController(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 16, bottom: 16),
          itemCount: deliverPredictionList.length,
          itemBuilder: (context, index) {
            Predictions mData = deliverPredictionList[index];
            return ListTile(
              leading: Icon(Icons.location_pin, color: primaryColor),
              title: Text(mData.description ?? "", style: primaryTextStyle()),
              onTap: () async {
                PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                if (response != null) {
                  deliverAddressCont.text = mData.description ?? "";
                  deliverLat = response.result!.geometry!.location!.lat.toString();
                  deliverLong = response.result!.geometry!.location!.lng.toString();
                  deliverPredictionList.clear();
                  setState(() {});
                }*/
              },
            );
          },
          onChanged: (val) async {
            deliverMsg = '';
            deliverLat = null;
            deliverLong = null;
            if (val.isNotEmpty) {
              if (val.length < 3) {
                deliverMsg = language.selectedAddressValidation;
                deliverPredictionList.clear();
                setState(() {});
              } else {
                deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
                setState(() {});
              }
            } else {
              deliverPredictionList.clear();
              setState(() {});
            }
          },
        ),
        if (deliverMsg != null && deliverMsg!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                deliverMsg ?? "",
                style: secondaryTextStyle(color: Colors.red),
              )),
        if (deliverPredictionList.isNotEmpty)
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: ScrollController(),
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16, bottom: 16),
              itemCount: deliverPredictionList.length,
              itemBuilder: (context, index) {
                Predictions mData = deliverPredictionList[index];
                return ListTile(
                  leading: Icon(Icons.location_pin, color: primaryColor),
                  title:
                      Text(mData.description ?? "", style: primaryTextStyle()),
                  onTap: () async {
                    PlaceIdDetailModel? response =
                        await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                    if (response != null) {
                      deliverAddressCont.text = mData.description ?? "";
                      deliverLat =
                          response.result!.geometry!.location!.lat.toString();
                      deliverLong =
                          response.result!.geometry!.location!.lng.toString();
                      deliverPredictionList.clear();
                      setState(() {});
                    }
                  },
                );
              }),
        // AppTextField(
        //   controller: deliverAddressCont,
        //   textInputAction: TextInputAction.next,
        //   nextFocus: deliverPhoneFocus,
        //   textFieldType: TextFieldType.ADDRESS,
        //   decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //   validator: (value) {
        //     if (value!.isEmpty) return language.fieldRequiredMsg;
        //     if (deliverLat == null || deliverLong == null) return language.pleaseSelectValidAddress;
        //     return null;
        //   },
        //   onTap: () {
        //     showModalBottomSheet(
        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
        //       context: context,
        //       builder: (context) {
        //         return PickAddressBottomSheet(
        //           onPick: (address) {
        //             deliverAddressCont.text = address.placeAddress ?? "";
        //             deliverLat = address.latitude.toString();
        //             deliverLong = address.longitude.toString();
        //   /*onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();*/
        //         setState(() {});
        //       /*} else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }*/
        //   },
        //   isPickup: false,
        //         );
        // /*),
        // if (deliverMsg != null && deliverMsg!.isNotEmpty)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg ?? "",
        //         style: secondaryTextStyle(color: Colors.red),
        //       )),
        // if (deliverPredictionList.isNotEmpty)
        //   ListView.builder(
        //       physics: NeverScrollableScrollPhysics(),
        //       controller: ScrollController(),
        //       shrinkWrap: true,
        //       padding: EdgeInsets.only(top: 16, bottom: 16),
        //       itemCount: deliverPredictionList.length,
        //       itemBuilder: (context, index) {
        //         Predictions mData = deliverPredictionList[index];
        //         return ListTile(
        //           leading: Icon(Icons.location_pin, color: primaryColor),
        //           title: Text(mData.description ?? "", style: primaryTextStyle()),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               deliverAddressCont.text = mData.description ?? "";
        //               deliverLat = response.result!.geometry!.location!.lat.toString();
        //               deliverLong = response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }*/
        //           },
        //         );
        //       },
        //       ),
        SizedBox(height: 16),
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: deliverPhoneCont,
          textInputAction: TextInputAction.next,
          textFieldType: TextFieldType.PHONE,
          focus: deliverPhoneFocus,
          nextFocus: deliverDesFocus,
          decoration: commonInputDecoration(
            suffixIcon: Icons.phone,
            suffixOnTap: () {
              _askPermissions(1);
            },
            prefixIcon: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    initialSelection: deliverCountryCode,
                    showCountryOnly: false,
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    dialogSize: Size(MediaQuery.of(context).size.width - 60,
                        MediaQuery.of(context).size.height * 0.6),
                    textStyle: primaryTextStyle(),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    barrierColor: Colors.black12,
                    dialogTextStyle: primaryTextStyle(),
                    searchDecoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                    ),
                    searchStyle: primaryTextStyle(),
                    onInit: (c) {
                      deliverCountryCode = c!.dialCode!;
                    },
                    onChanged: (c) {
                      deliverCountryCode = c.dialCode!;
                    },
                  ),
                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          validator: (s) {
            if (s!.trim().isEmpty) return language.fieldRequiredMsg;
            if (s.trim().length < minContactLength ||
                s.trim().length > maxContactLength)
              return language.contactLengthValidation;
            /*validator: (value) {
            if (value!.trim().isEmpty) return errorThisFieldRequired;
            if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contactLengthValidation;*/
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 16),
        Text(language.deliveryDescription, style: primaryTextStyle()),
        SizedBox(height: 8),
        TextField(
          controller: deliverDesCont,
          focusNode: deliverDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        appCommonButton('Add Another Address', () {
          if (_formKey.currentState!.validate()) {
            selectedTabIndex = 3;
            setState(() {});
          }
        }, width: MediaQuery.of(context).size.width),
      ],
    );
  }

  Widget createOrderWidget4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Information 2", style: boldTextStyle()),
        SizedBox(height: 16),
        Text(language.deliveryLocation, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliverAddress2Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (deliverLat == null || deliverLong == null)
              return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    anotherDeliverAddress2Cont.text =
                        address.placeAddress ?? "";
                    deliverLat = address.latitude.toString();
                    deliverLong = address.longitude.toString();
                    /*onChanged: (val) async {
        deliverMsg = '';
        deliverLat = null;
        deliverLong = null;
        if (val.isNotEmpty) {
          if (val.length < 3) {
            deliverMsg = language.selectedAddressValidation;
            deliverPredictionList.clear();*/
                    setState(() {});
                    /*} else {
            deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
            setState(() {});
          }
        } else {
          deliverPredictionList.clear();
          setState(() {});
        }*/
                  },
                  isPickup: false,
                );
                /*),
    if (deliverMsg != null && deliverMsg!.isNotEmpty)
      Padding(
          padding: EdgeInsets.only(top: 8, left: 8),
          child: Text(
            deliverMsg ?? "",
            style: secondaryTextStyle(color: Colors.red),
          )),
    if (deliverPredictionList.isNotEmpty)
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: ScrollController(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 16, bottom: 16),
          itemCount: deliverPredictionList.length,
          itemBuilder: (context, index) {
            Predictions mData = deliverPredictionList[index];
            return ListTile(
              leading: Icon(Icons.location_pin, color: primaryColor),
              title: Text(mData.description ?? "", style: primaryTextStyle()),
              onTap: () async {
                PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                if (response != null) {
                  deliverAddressCont.text = mData.description ?? "";
                  deliverLat = response.result!.geometry!.location!.lat.toString();
                  deliverLong = response.result!.geometry!.location!.lng.toString();
                  deliverPredictionList.clear();
                  setState(() {});
                }*/
              },
            );
          },
          onChanged: (val) async {
            deliverMsg = '';
            deliverLat = null;
            deliverLong = null;
            if (val.isNotEmpty) {
              if (val.length < 3) {
                deliverMsg = language.selectedAddressValidation;
                deliverPredictionList.clear();
                setState(() {});
              } else {
                deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
                setState(() {});
              }
            } else {
              deliverPredictionList.clear();
              setState(() {});
            }
          },
        ),
        if (deliverMsg != null && deliverMsg!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                deliverMsg ?? "",
                style: secondaryTextStyle(color: Colors.red),
              )),
        if (deliverPredictionList.isNotEmpty)
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: ScrollController(),
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16, bottom: 16),
              itemCount: deliverPredictionList.length,
              itemBuilder: (context, index) {
                Predictions mData = deliverPredictionList[index];
                return ListTile(
                  leading: Icon(Icons.location_pin, color: primaryColor),
                  title:
                      Text(mData.description ?? "", style: primaryTextStyle()),
                  onTap: () async {
                    PlaceIdDetailModel? response =
                        await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                    if (response != null) {
                      anotherDeliverAddress2Cont.text = mData.description ?? "";
                      deliverLat =
                          response.result!.geometry!.location!.lat.toString();
                      deliverLong =
                          response.result!.geometry!.location!.lng.toString();
                      deliverPredictionList.clear();
                      setState(() {});
                    }
                  },
                );
              }),
        //#######################################
        //     AppTextField(
        //       controller: anotherDeliverAddress2Cont,
        //       textInputAction: TextInputAction.next,
        //       nextFocus: anotherDeliver2PhoneFocus,
        //       textFieldType: TextFieldType.ADDRESS,
        //       decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //       validator: (value) {
        //         if (value!.isEmpty) return language.fieldRequiredMsg;
        //         if (deliverLat == null || deliverLong == null) return language.pleaseSelectValidAddress;
        //         return null;
        //       },
        //       onTap: () {
        //         showModalBottomSheet(
        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
        //           context: context,
        //           builder: (context) {
        //             return PickAddressBottomSheet(
        //               onPick: (address) {
        //                 deliverAddressCont.text = address.placeAddress ?? "";
        //                 deliverLat = address.latitude.toString();
        //                 deliverLong = address.longitude.toString();
        //                 /*onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();*/
        //                 setState(() {});
        //                 /*} else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }*/
        //               },
        //               isPickup: false,
        //             );
        //             /*),
        // if (deliverMsg != null && deliverMsg!.isNotEmpty)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg ?? "",
        //         style: secondaryTextStyle(color: Colors.red),
        //       )),
        // if (deliverPredictionList.isNotEmpty)
        //   ListView.builder(
        //       physics: NeverScrollableScrollPhysics(),
        //       controller: ScrollController(),
        //       shrinkWrap: true,
        //       padding: EdgeInsets.only(top: 16, bottom: 16),
        //       itemCount: deliverPredictionList.length,
        //       itemBuilder: (context, index) {
        //         Predictions mData = deliverPredictionList[index];
        //         return ListTile(
        //           leading: Icon(Icons.location_pin, color: primaryColor),
        //           title: Text(mData.description ?? "", style: primaryTextStyle()),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               deliverAddressCont.text = mData.description ?? "";
        //               deliverLat = response.result!.geometry!.location!.lat.toString();
        //               deliverLong = response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }*/
        //           },
        //         );
        //       },
        //       onChanged: (val) async {
        //         anotherDeliver2Msg = '';
        //         anotherDeliver2Lat = null;
        //         anotherDeliver2Long = null;
        //         if (val.isNotEmpty) {
        //           if (val.length < 3) {
        //             anotherDeliver2Msg = language.selectedAddressValidation;
        //             deliverPredictionList.clear();
        //             setState(() {});
        //           } else {
        //             deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //             setState(() {});
        //           }
        //         } else {
        //           deliverPredictionList.clear();
        //           setState(() {});
        //         }
        //       },
        //     ),
        //     if (anotherDeliver2Msg != null && anotherDeliver2Msg!.isNotEmpty)
        //       Padding(
        //           padding: EdgeInsets.only(top: 8, left: 8),
        //           child: Text(
        //             anotherDeliver2Msg ?? "",
        //             style: secondaryTextStyle(color: Colors.red),
        //           )),
        //     if (deliverPredictionList.isNotEmpty)
        //       ListView.builder(
        //           physics: NeverScrollableScrollPhysics(),
        //           controller: ScrollController(),
        //           shrinkWrap: true,
        //           padding: EdgeInsets.only(top: 16, bottom: 16),
        //           itemCount: deliverPredictionList.length,
        //           itemBuilder: (context, index) {
        //             Predictions mData = deliverPredictionList[index];
        //             return ListTile(
        //               leading: Icon(Icons.location_pin, color: primaryColor),
        //               title: Text(mData.description ?? "", style: primaryTextStyle()),
        //               onTap: () async {
        //                 PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //                 if (response != null) {
        //                   anotherDeliverAddress2Cont.text = mData.description ?? "";
        //                   anotherDeliver2Lat = response.result!.geometry!.location!.lat.toString();
        //                   anotherDeliver2Long = response.result!.geometry!.location!.lng.toString();
        //                   deliverPredictionList.clear();
        //                   setState(() {});
        //                 }
        //               },
        //             );
        //           }),
        //#################################
        SizedBox(height: 16),
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliver2PhoneCont,
          textInputAction: TextInputAction.next,
          textFieldType: TextFieldType.PHONE,
          focus: anotherDeliver2PhoneFocus,
          nextFocus: anotherDeliver2DesFocus,
          decoration: commonInputDecoration(
            suffixIcon: Icons.phone,
            suffixOnTap: () {
              _askPermissions(2);
            },
            prefixIcon: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    initialSelection: anotherDeliver2CountryCode,
                    showCountryOnly: false,
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    dialogSize: Size(MediaQuery.of(context).size.width - 60,
                        MediaQuery.of(context).size.height * 0.6),
                    textStyle: primaryTextStyle(),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    barrierColor: Colors.black12,
                    dialogTextStyle: primaryTextStyle(),
                    searchDecoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                    ),
                    searchStyle: primaryTextStyle(),
                    onInit: (c) {
                      anotherDeliver2CountryCode = c!.dialCode!;
                    },
                    onChanged: (c) {
                      anotherDeliver2CountryCode = c.dialCode!;
                    },
                  ),
                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          validator: (value) {
            if (value!.trim().isEmpty) return errorThisFieldRequired;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLengthValidation;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 16),
        Text(language.deliveryDescription, style: primaryTextStyle()),
        SizedBox(height: 8),
        TextField(
          controller: anotherDeliver2DesCont,
          focusNode: anotherDeliver2DesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        appCommonButton('Add Another Address', () {
          if (_formKey.currentState!.validate()) {
            selectedTabIndex = 4;
            setState(() {});
          }
        }, width: MediaQuery.of(context).size.width),
      ],
    );
  }

  Widget createOrderWidget5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Information 3", style: boldTextStyle()),
        SizedBox(height: 16),
        Text(language.deliveryLocation, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliverAddress3Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (deliverLat == null || deliverLong == null)
              return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    anotherDeliverAddress3Cont.text =
                        address.placeAddress ?? "";
                    deliverLat = address.latitude.toString();
                    deliverLong = address.longitude.toString();
                    /*onChanged: (val) async {
        deliverMsg = '';
        deliverLat = null;
        deliverLong = null;
        if (val.isNotEmpty) {
          if (val.length < 3) {
            deliverMsg = language.selectedAddressValidation;
            deliverPredictionList.clear();*/
                    setState(() {});
                    /*} else {
            deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
            setState(() {});
          }
        } else {
          deliverPredictionList.clear();
          setState(() {});
        }*/
                  },
                  isPickup: false,
                );
                /*),
    if (deliverMsg != null && deliverMsg!.isNotEmpty)
      Padding(
          padding: EdgeInsets.only(top: 8, left: 8),
          child: Text(
            deliverMsg ?? "",
            style: secondaryTextStyle(color: Colors.red),
          )),
    if (deliverPredictionList.isNotEmpty)
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: ScrollController(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 16, bottom: 16),
          itemCount: deliverPredictionList.length,
          itemBuilder: (context, index) {
            Predictions mData = deliverPredictionList[index];
            return ListTile(
              leading: Icon(Icons.location_pin, color: primaryColor),
              title: Text(mData.description ?? "", style: primaryTextStyle()),
              onTap: () async {
                PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                if (response != null) {
                  deliverAddressCont.text = mData.description ?? "";
                  deliverLat = response.result!.geometry!.location!.lat.toString();
                  deliverLong = response.result!.geometry!.location!.lng.toString();
                  deliverPredictionList.clear();
                  setState(() {});
                }*/
              },
            );
          },
          onChanged: (val) async {
            deliverMsg = '';
            deliverLat = null;
            deliverLong = null;
            if (val.isNotEmpty) {
              if (val.length < 3) {
                deliverMsg = language.selectedAddressValidation;
                deliverPredictionList.clear();
                setState(() {});
              } else {
                deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
                setState(() {});
              }
            } else {
              deliverPredictionList.clear();
              setState(() {});
            }
          },
        ),
        if (deliverMsg != null && deliverMsg!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                deliverMsg ?? "",
                style: secondaryTextStyle(color: Colors.red),
              )),
        if (deliverPredictionList.isNotEmpty)
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: ScrollController(),
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16, bottom: 16),
              itemCount: deliverPredictionList.length,
              itemBuilder: (context, index) {
                Predictions mData = deliverPredictionList[index];
                return ListTile(
                  leading: Icon(Icons.location_pin, color: primaryColor),
                  title:
                      Text(mData.description ?? "", style: primaryTextStyle()),
                  onTap: () async {
                    PlaceIdDetailModel? response =
                        await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                    if (response != null) {
                      anotherDeliverAddress3Cont.text = mData.description ?? "";
                      deliverLat =
                          response.result!.geometry!.location!.lat.toString();
                      deliverLong =
                          response.result!.geometry!.location!.lng.toString();
                      deliverPredictionList.clear();
                      setState(() {});
                    }
                  },
                );
              }),
        //##############################

        //     AppTextField(
        //       controller: anotherDeliverAddress3Cont,
        //       textInputAction: TextInputAction.next,
        //       nextFocus: anotherDeliver3PhoneFocus,
        //       textFieldType: TextFieldType.ADDRESS,
        //       decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //       validator: (value) {
        //         if (value!.isEmpty) return language.fieldRequiredMsg;
        //         if (deliverLat == null || deliverLong == null) return language.pleaseSelectValidAddress;
        //         return null;
        //       },
        //       onTap: () {
        //         showModalBottomSheet(
        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
        //           context: context,
        //           builder: (context) {
        //             return PickAddressBottomSheet(
        //               onPick: (address) {
        //                 deliverAddressCont.text = address.placeAddress ?? "";
        //                 deliverLat = address.latitude.toString();
        //                 deliverLong = address.longitude.toString();
        //                 /*onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();*/
        //                 setState(() {});
        //                 /*} else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }*/
        //               },
        //               isPickup: false,
        //             );
        //             /*),
        // if (deliverMsg != null && deliverMsg!.isNotEmpty)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg ?? "",
        //         style: secondaryTextStyle(color: Colors.red),
        //       )),
        // if (deliverPredictionList.isNotEmpty)
        //   ListView.builder(
        //       physics: NeverScrollableScrollPhysics(),
        //       controller: ScrollController(),
        //       shrinkWrap: true,
        //       padding: EdgeInsets.only(top: 16, bottom: 16),
        //       itemCount: deliverPredictionList.length,
        //       itemBuilder: (context, index) {
        //         Predictions mData = deliverPredictionList[index];
        //         return ListTile(
        //           leading: Icon(Icons.location_pin, color: primaryColor),
        //           title: Text(mData.description ?? "", style: primaryTextStyle()),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               deliverAddressCont.text = mData.description ?? "";
        //               deliverLat = response.result!.geometry!.location!.lat.toString();
        //               deliverLong = response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }*/
        //           },
        //         );
        //       },
        //       onChanged: (val) async {
        //         anotherDeliver3Msg = '';
        //         anotherDeliver3Lat = null;
        //         anotherDeliver3Long = null;
        //         if (val.isNotEmpty) {
        //           if (val.length < 3) {
        //             anotherDeliver3Msg = language.selectedAddressValidation;
        //             deliverPredictionList.clear();
        //             setState(() {});
        //           } else {
        //             deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //             setState(() {});
        //           }
        //         } else {
        //           deliverPredictionList.clear();
        //           setState(() {});
        //         }
        //       },
        //     ),
        //     if (anotherDeliver3Msg != null && anotherDeliver3Msg!.isNotEmpty)
        //       Padding(
        //           padding: EdgeInsets.only(top: 8, left: 8),
        //           child: Text(
        //             anotherDeliver3Msg ?? "",
        //             style: secondaryTextStyle(color: Colors.red),
        //           )),
        //     if (deliverPredictionList.isNotEmpty)
        //       ListView.builder(
        //           physics: NeverScrollableScrollPhysics(),
        //           controller: ScrollController(),
        //           shrinkWrap: true,
        //           padding: EdgeInsets.only(top: 16, bottom: 16),
        //           itemCount: deliverPredictionList.length,
        //           itemBuilder: (context, index) {
        //             Predictions mData = deliverPredictionList[index];
        //             return ListTile(
        //               leading: Icon(Icons.location_pin, color: primaryColor),
        //               title: Text(mData.description ?? "", style: primaryTextStyle()),
        //               onTap: () async {
        //                 PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //                 if (response != null) {
        //                   anotherDeliverAddress3Cont.text = mData.description ?? "";
        //                   anotherDeliver3Lat = response.result!.geometry!.location!.lat.toString();
        //                   anotherDeliver3Long = response.result!.geometry!.location!.lng.toString();
        //                   deliverPredictionList.clear();
        //                   setState(() {});
        //                 }
        //               },
        //             );
        //           }),
        //#####################3
        SizedBox(height: 16),
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliver3PhoneCont,
          textInputAction: TextInputAction.next,
          textFieldType: TextFieldType.PHONE,
          focus: anotherDeliver3PhoneFocus,
          nextFocus: anotherDeliver3DesFocus,
          decoration: commonInputDecoration(
            suffixIcon: Icons.phone,
            suffixOnTap: () {
              _askPermissions(3);
            },
            prefixIcon: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    initialSelection: anotherDeliver3CountryCode,
                    showCountryOnly: false,
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    dialogSize: Size(MediaQuery.of(context).size.width - 60,
                        MediaQuery.of(context).size.height * 0.6),
                    textStyle: primaryTextStyle(),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    barrierColor: Colors.black12,
                    dialogTextStyle: primaryTextStyle(),
                    searchDecoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                    ),
                    searchStyle: primaryTextStyle(),
                    onInit: (c) {
                      anotherDeliver3CountryCode = c!.dialCode!;
                    },
                    onChanged: (c) {
                      anotherDeliver3CountryCode = c.dialCode!;
                    },
                  ),
                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          validator: (value) {
            if (value!.trim().isEmpty) return errorThisFieldRequired;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLengthValidation;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 16),
        Text(language.deliveryDescription, style: primaryTextStyle()),
        SizedBox(height: 8),
        TextField(
          controller: anotherDeliver3DesCont,
          focusNode: anotherDeliver3DesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        appCommonButton('Add Another Address', () {
          if (_formKey.currentState!.validate()) {
            selectedTabIndex = 5;
            setState(() {});
          }
        }, width: MediaQuery.of(context).size.width),
      ],
    );
  }

  Widget createOrderWidget6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Information 4", style: boldTextStyle()),
        SizedBox(height: 16),
        Text(language.deliveryLocation, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliverAddress4Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (deliverLat == null || deliverLong == null)
              return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    anotherDeliverAddress4Cont.text =
                        address.placeAddress ?? "";
                    deliverLat = address.latitude.toString();
                    deliverLong = address.longitude.toString();
                    /*onChanged: (val) async {
        deliverMsg = '';
        deliverLat = null;
        deliverLong = null;
        if (val.isNotEmpty) {
          if (val.length < 3) {
            deliverMsg = language.selectedAddressValidation;
            deliverPredictionList.clear();*/
                    setState(() {});
                    /*} else {
            deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
            setState(() {});
          }
        } else {
          deliverPredictionList.clear();
          setState(() {});
        }*/
                  },
                  isPickup: false,
                );
                /*),
    if (deliverMsg != null && deliverMsg!.isNotEmpty)
      Padding(
          padding: EdgeInsets.only(top: 8, left: 8),
          child: Text(
            deliverMsg ?? "",
            style: secondaryTextStyle(color: Colors.red),
          )),
    if (deliverPredictionList.isNotEmpty)
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: ScrollController(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 16, bottom: 16),
          itemCount: deliverPredictionList.length,
          itemBuilder: (context, index) {
            Predictions mData = deliverPredictionList[index];
            return ListTile(
              leading: Icon(Icons.location_pin, color: primaryColor),
              title: Text(mData.description ?? "", style: primaryTextStyle()),
              onTap: () async {
                PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                if (response != null) {
                  deliverAddressCont.text = mData.description ?? "";
                  deliverLat = response.result!.geometry!.location!.lat.toString();
                  deliverLong = response.result!.geometry!.location!.lng.toString();
                  deliverPredictionList.clear();
                  setState(() {});
                }*/
              },
            );
          },
          onChanged: (val) async {
            deliverMsg = '';
            deliverLat = null;
            deliverLong = null;
            if (val.isNotEmpty) {
              if (val.length < 3) {
                deliverMsg = language.selectedAddressValidation;
                deliverPredictionList.clear();
                setState(() {});
              } else {
                deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
                setState(() {});
              }
            } else {
              deliverPredictionList.clear();
              setState(() {});
            }
          },
        ),
        if (deliverMsg != null && deliverMsg!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                deliverMsg ?? "",
                style: secondaryTextStyle(color: Colors.red),
              )),
        if (deliverPredictionList.isNotEmpty)
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: ScrollController(),
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16, bottom: 16),
              itemCount: deliverPredictionList.length,
              itemBuilder: (context, index) {
                Predictions mData = deliverPredictionList[index];
                return ListTile(
                  leading: Icon(Icons.location_pin, color: primaryColor),
                  title:
                      Text(mData.description ?? "", style: primaryTextStyle()),
                  onTap: () async {
                    PlaceIdDetailModel? response =
                        await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                    if (response != null) {
                      anotherDeliverAddress4Cont.text = mData.description ?? "";
                      deliverLat =
                          response.result!.geometry!.location!.lat.toString();
                      deliverLong =
                          response.result!.geometry!.location!.lng.toString();
                      deliverPredictionList.clear();
                      setState(() {});
                    }
                  },
                );
              }),
        //*********************************
        //     AppTextField(
        //       controller: anotherDeliverAddress4Cont,
        //       textInputAction: TextInputAction.next,
        //       nextFocus: anotherDeliver4PhoneFocus,
        //       textFieldType: TextFieldType.ADDRESS,
        //       decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //       validator: (value) {
        //         if (value!.isEmpty) return language.fieldRequiredMsg;
        //         if (deliverLat == null || deliverLong == null) return language.pleaseSelectValidAddress;
        //         return null;
        //       },
        //       onTap: () {
        //         showModalBottomSheet(
        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
        //           context: context,
        //           builder: (context) {
        //             return PickAddressBottomSheet(
        //               onPick: (address) {
        //                 deliverAddressCont.text = address.placeAddress ?? "";
        //                 deliverLat = address.latitude.toString();
        //                 deliverLong = address.longitude.toString();
        //                 /*onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();*/
        //                 setState(() {});
        //                 /*} else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }*/
        //               },
        //               isPickup: false,
        //             );
        //             /*),
        // if (deliverMsg != null && deliverMsg!.isNotEmpty)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg ?? "",
        //         style: secondaryTextStyle(color: Colors.red),
        //       )),
        // if (deliverPredictionList.isNotEmpty)
        //   ListView.builder(
        //       physics: NeverScrollableScrollPhysics(),
        //       controller: ScrollController(),
        //       shrinkWrap: true,
        //       padding: EdgeInsets.only(top: 16, bottom: 16),
        //       itemCount: deliverPredictionList.length,
        //       itemBuilder: (context, index) {
        //         Predictions mData = deliverPredictionList[index];
        //         return ListTile(
        //           leading: Icon(Icons.location_pin, color: primaryColor),
        //           title: Text(mData.description ?? "", style: primaryTextStyle()),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               deliverAddressCont.text = mData.description ?? "";
        //               deliverLat = response.result!.geometry!.location!.lat.toString();
        //               deliverLong = response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }*/
        //           },
        //         );
        //       },
        //       onChanged: (val) async {
        //         anotherDeliver4Msg = '';
        //         anotherDeliver4Lat = null;
        //         anotherDeliver4Long = null;
        //         if (val.isNotEmpty) {
        //           if (val.length < 4) {
        //             anotherDeliver4Msg = language.selectedAddressValidation;
        //             deliverPredictionList.clear();
        //             setState(() {});
        //           } else {
        //             deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //             setState(() {});
        //           }
        //         } else {
        //           deliverPredictionList.clear();
        //           setState(() {});
        //         }
        //       },
        //     ),
        //     if (anotherDeliver4Msg != null && anotherDeliver4Msg!.isNotEmpty)
        //       Padding(
        //           padding: EdgeInsets.only(top: 8, left: 8),
        //           child: Text(
        //             anotherDeliver4Msg ?? "",
        //             style: secondaryTextStyle(color: Colors.red),
        //           )),
        //     if (deliverPredictionList.isNotEmpty)
        //       ListView.builder(
        //           physics: NeverScrollableScrollPhysics(),
        //           controller: ScrollController(),
        //           shrinkWrap: true,
        //           padding: EdgeInsets.only(top: 16, bottom: 16),
        //           itemCount: deliverPredictionList.length,
        //           itemBuilder: (context, index) {
        //             Predictions mData = deliverPredictionList[index];
        //             return ListTile(
        //               leading: Icon(Icons.location_pin, color: primaryColor),
        //               title: Text(mData.description ?? "", style: primaryTextStyle()),
        //               onTap: () async {
        //                 PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //                 if (response != null) {
        //                   anotherDeliverAddress4Cont.text = mData.description ?? "";
        //                   anotherDeliver4Lat = response.result!.geometry!.location!.lat.toString();
        //                   anotherDeliver4Long = response.result!.geometry!.location!.lng.toString();
        //                   deliverPredictionList.clear();
        //                   setState(() {});
        //                 }
        //               },
        //             );
        //           }),
        //*********************************
        SizedBox(height: 16),
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliver4PhoneCont,
          textInputAction: TextInputAction.next,
          textFieldType: TextFieldType.PHONE,
          focus: anotherDeliver4PhoneFocus,
          nextFocus: anotherDeliver4DesFocus,
          decoration: commonInputDecoration(
            suffixIcon: Icons.phone,
            suffixOnTap: () {
              _askPermissions(4);
            },
            prefixIcon: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    initialSelection: anotherDeliver4CountryCode,
                    showCountryOnly: false,
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    dialogSize: Size(MediaQuery.of(context).size.width - 60,
                        MediaQuery.of(context).size.height * 0.6),
                    textStyle: primaryTextStyle(),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    barrierColor: Colors.black12,
                    dialogTextStyle: primaryTextStyle(),
                    searchDecoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                    ),
                    searchStyle: primaryTextStyle(),
                    onInit: (c) {
                      anotherDeliver4CountryCode = c!.dialCode!;
                    },
                    onChanged: (c) {
                      anotherDeliver4CountryCode = c.dialCode!;
                    },
                  ),
                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          validator: (value) {
            if (value!.trim().isEmpty) return errorThisFieldRequired;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLengthValidation;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 16),
        Text(language.deliveryDescription, style: primaryTextStyle()),
        SizedBox(height: 8),
        TextField(
          controller: anotherDeliver4DesCont,
          focusNode: anotherDeliver4DesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        appCommonButton('Add Another Address', () {
          if (_formKey.currentState!.validate()) {
            selectedTabIndex = 6;
            setState(() {});
          }
        }, width: MediaQuery.of(context).size.width),
      ],
    );
  }

  Widget createOrderWidget7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Delivery Information 5", style: boldTextStyle()),
        SizedBox(height: 16),
        Text(language.deliveryLocation, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliverAddress5Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (deliverLat == null || deliverLong == null)
              return language.pleaseSelectValidAddress;
            return null;
          },
          onTap: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(defaultRadius))),
              context: context,
              builder: (context) {
                return PickAddressBottomSheet(
                  onPick: (address) {
                    anotherDeliverAddress5Cont.text =
                        address.placeAddress ?? "";
                    deliverLat = address.latitude.toString();
                    deliverLong = address.longitude.toString();
                    /*onChanged: (val) async {
        deliverMsg = '';
        deliverLat = null;
        deliverLong = null;
        if (val.isNotEmpty) {
          if (val.length < 3) {
            deliverMsg = language.selectedAddressValidation;
            deliverPredictionList.clear();*/
                    setState(() {});
                    /*} else {
            deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
            setState(() {});
          }
        } else {
          deliverPredictionList.clear();
          setState(() {});
        }*/
                  },
                  isPickup: false,
                );
                /*),
    if (deliverMsg != null && deliverMsg!.isNotEmpty)
      Padding(
          padding: EdgeInsets.only(top: 8, left: 8),
          child: Text(
            deliverMsg ?? "",
            style: secondaryTextStyle(color: Colors.red),
          )),
    if (deliverPredictionList.isNotEmpty)
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: ScrollController(),
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 16, bottom: 16),
          itemCount: deliverPredictionList.length,
          itemBuilder: (context, index) {
            Predictions mData = deliverPredictionList[index];
            return ListTile(
              leading: Icon(Icons.location_pin, color: primaryColor),
              title: Text(mData.description ?? "", style: primaryTextStyle()),
              onTap: () async {
                PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                if (response != null) {
                  deliverAddressCont.text = mData.description ?? "";
                  deliverLat = response.result!.geometry!.location!.lat.toString();
                  deliverLong = response.result!.geometry!.location!.lng.toString();
                  deliverPredictionList.clear();
                  setState(() {});
                }*/
              },
            );
          },
          onChanged: (val) async {
            deliverMsg = '';
            deliverLat = null;
            deliverLong = null;
            if (val.isNotEmpty) {
              if (val.length < 3) {
                deliverMsg = language.selectedAddressValidation;
                deliverPredictionList.clear();
                setState(() {});
              } else {
                deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
                setState(() {});
              }
            } else {
              deliverPredictionList.clear();
              setState(() {});
            }
          },
        ),
        if (deliverMsg != null && deliverMsg!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                deliverMsg ?? "",
                style: secondaryTextStyle(color: Colors.red),
              )),
        if (deliverPredictionList.isNotEmpty)
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: ScrollController(),
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16, bottom: 16),
              itemCount: deliverPredictionList.length,
              itemBuilder: (context, index) {
                Predictions mData = deliverPredictionList[index];
                return ListTile(
                  leading: Icon(Icons.location_pin, color: primaryColor),
                  title:
                      Text(mData.description ?? "", style: primaryTextStyle()),
                  onTap: () async {
                    PlaceIdDetailModel? response =
                        await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                    if (response != null) {
                      anotherDeliverAddress5Cont.text = mData.description ?? "";
                      deliverLat =
                          response.result!.geometry!.location!.lat.toString();
                      deliverLong =
                          response.result!.geometry!.location!.lng.toString();
                      deliverPredictionList.clear();
                      setState(() {});
                    }
                  },
                );
              }),
        //********************************
        //     AppTextField(
        //       controller: anotherDeliverAddress5Cont,
        //       textInputAction: TextInputAction.next,
        //       nextFocus: anotherDeliver5PhoneFocus,
        //       textFieldType: TextFieldType.ADDRESS,
        //       decoration: commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //       validator: (value) {
        //         if (value!.isEmpty) return language.fieldRequiredMsg;
        //         if (deliverLat == null || deliverLong == null) return language.pleaseSelectValidAddress;
        //         return null;
        //       },
        //       onTap: () {
        //         showModalBottomSheet(
        //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(defaultRadius))),
        //           context: context,
        //           builder: (context) {
        //             return PickAddressBottomSheet(
        //               onPick: (address) {
        //                 deliverAddressCont.text = address.placeAddress ?? "";
        //                 deliverLat = address.latitude.toString();
        //                 deliverLong = address.longitude.toString();
        //                 /*onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();*/
        //                 setState(() {});
        //                 /*} else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }*/
        //               },
        //               isPickup: false,
        //             );
        //             /*),
        // if (deliverMsg != null && deliverMsg!.isNotEmpty)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg ?? "",
        //         style: secondaryTextStyle(color: Colors.red),
        //       )),
        // if (deliverPredictionList.isNotEmpty)
        //   ListView.builder(
        //       physics: NeverScrollableScrollPhysics(),
        //       controller: ScrollController(),
        //       shrinkWrap: true,
        //       padding: EdgeInsets.only(top: 16, bottom: 16),
        //       itemCount: deliverPredictionList.length,
        //       itemBuilder: (context, index) {
        //         Predictions mData = deliverPredictionList[index];
        //         return ListTile(
        //           leading: Icon(Icons.location_pin, color: primaryColor),
        //           title: Text(mData.description ?? "", style: primaryTextStyle()),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               deliverAddressCont.text = mData.description ?? "";
        //               deliverLat = response.result!.geometry!.location!.lat.toString();
        //               deliverLong = response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }*/
        //           },
        //         );
        //       },
        //       onChanged: (val) async {
        //         anotherDeliver5Msg = '';
        //         anotherDeliver5Lat = null;
        //         anotherDeliver5Long = null;
        //         if (val.isNotEmpty) {
        //           if (val.length < 5) {
        //             anotherDeliver5Msg = language.selectedAddressValidation;
        //             deliverPredictionList.clear();
        //             setState(() {});
        //           } else {
        //             deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //             setState(() {});
        //           }
        //         } else {
        //           deliverPredictionList.clear();
        //           setState(() {});
        //         }
        //       },
        //     ),
        //     if (anotherDeliver5Msg != null && anotherDeliver5Msg!.isNotEmpty)
        //       Padding(
        //           padding: EdgeInsets.only(top: 8, left: 8),
        //           child: Text(
        //             anotherDeliver5Msg ?? "",
        //             style: secondaryTextStyle(color: Colors.red),
        //           )),
        //     if (deliverPredictionList.isNotEmpty)
        //       ListView.builder(
        //           physics: NeverScrollableScrollPhysics(),
        //           controller: ScrollController(),
        //           shrinkWrap: true,
        //           padding: EdgeInsets.only(top: 16, bottom: 16),
        //           itemCount: deliverPredictionList.length,
        //           itemBuilder: (context, index) {
        //             Predictions mData = deliverPredictionList[index];
        //             return ListTile(
        //               leading: Icon(Icons.location_pin, color: primaryColor),
        //               title: Text(mData.description ?? "", style: primaryTextStyle()),
        //               onTap: () async {
        //                 PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //                 if (response != null) {
        //                   anotherDeliverAddress5Cont.text = mData.description ?? "";
        //                   anotherDeliver5Lat = response.result!.geometry!.location!.lat.toString();
        //                   anotherDeliver5Long = response.result!.geometry!.location!.lng.toString();
        //                   deliverPredictionList.clear();
        //                   setState(() {});
        //                 }
        //               },
        //             );
        //           }),
        //**********************
        SizedBox(height: 16),
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        SizedBox(height: 8),
        AppTextField(
          controller: anotherDeliver5PhoneCont,
          textInputAction: TextInputAction.next,
          textFieldType: TextFieldType.PHONE,
          focus: anotherDeliver5PhoneFocus,
          nextFocus: anotherDeliver5DesFocus,
          decoration: commonInputDecoration(
            suffixIcon: Icons.phone,
            suffixOnTap: () {
              _askPermissions(5);
            },
            prefixIcon: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    initialSelection: anotherDeliver5CountryCode,
                    showCountryOnly: false,
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    dialogSize: Size(MediaQuery.of(context).size.width - 60,
                        MediaQuery.of(context).size.height * 0.6),
                    textStyle: primaryTextStyle(),
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    barrierColor: Colors.black12,
                    dialogTextStyle: primaryTextStyle(),
                    searchDecoration: InputDecoration(
                      iconColor: Theme.of(context).dividerColor,
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).dividerColor)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                    ),
                    searchStyle: primaryTextStyle(),
                    onInit: (c) {
                      anotherDeliver5CountryCode = c!.dialCode!;
                    },
                    onChanged: (c) {
                      anotherDeliver5CountryCode = c.dialCode!;
                    },
                  ),
                  VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          validator: (value) {
            if (value!.trim().isEmpty) return errorThisFieldRequired;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLengthValidation;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 16),
        Text(language.deliveryDescription, style: primaryTextStyle()),
        SizedBox(height: 8),
        TextField(
          controller: anotherDeliver5DesCont,
          focusNode: anotherDeliver5DesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
      ],
    );
  }

  Widget createOrderWidget8() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.packageInformation, style: boldTextStyle()),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
                color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.parcelType, style: primaryTextStyle()),
                  SizedBox(width: 16),
                  Expanded(
                      child: Text(parcelTypeCont.text,
                          style: primaryTextStyle(),
                          maxLines: 3,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.weight, style: primaryTextStyle()),
                  SizedBox(width: 16),
                  Text('${weightController.text} ${countryData?.weightType}',
                      style: primaryTextStyle()),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.numberOfParcels, style: primaryTextStyle()),
                  SizedBox(width: 16),
                  Text('${totalParcelController.text}',
                      style: primaryTextStyle()),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(language.pickupLocation, style: boldTextStyle()),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
                color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickAddressCont.text, style: primaryTextStyle()),
              Visibility(
                  visible: pickPhoneCont.text.isNotEmpty,
                  child: SizedBox(height: 8)),
              Visibility(
                  visible: pickPhoneCont.text.isNotEmpty,
                  child: Text(pickPhoneCont.text, style: secondaryTextStyle())),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(language.deliveryLocation, style: boldTextStyle()),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
                color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deliverAddressCont.text, style: primaryTextStyle()),
              Visibility(
                  visible: deliverPhoneCont.text.isNotEmpty,
                  child: SizedBox(height: 8)),
              Visibility(
                  visible: deliverPhoneCont.text.isNotEmpty,
                  child:
                      Text(deliverPhoneCont.text, style: secondaryTextStyle())),
            ],
          ),
        ),
        if (anotherDeliverAddress2Cont.text.isNotEmpty) ...[
          SizedBox(height: 16),
          Text("Delivery Location 2", style: boldTextStyle()),
          SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress2Cont.text,
                    style: primaryTextStyle()),
                Visibility(
                    visible: anotherDeliver2PhoneCont.text.isNotEmpty,
                    child: SizedBox(height: 8)),
                Visibility(
                    visible: anotherDeliver2PhoneCont.text.isNotEmpty,
                    child: Text(anotherDeliver2PhoneCont.text,
                        style: secondaryTextStyle())),
              ],
            ),
          ),
        ],
        if (anotherDeliverAddress3Cont.text.isNotEmpty) ...[
          SizedBox(height: 16),
          Text("Delivery Location 3", style: boldTextStyle()),
          SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress3Cont.text,
                    style: primaryTextStyle()),
                Visibility(
                    visible: anotherDeliver3PhoneCont.text.isNotEmpty,
                    child: SizedBox(height: 8)),
                Visibility(
                    visible: anotherDeliver3PhoneCont.text.isNotEmpty,
                    child: Text(anotherDeliver3PhoneCont.text,
                        style: secondaryTextStyle())),
              ],
            ),
          ),
        ],
        if (anotherDeliverAddress4Cont.text.isNotEmpty) ...[
          SizedBox(height: 16),
          Text("Delivery Location 4", style: boldTextStyle()),
          SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress4Cont.text,
                    style: primaryTextStyle()),
                Visibility(
                    visible: anotherDeliver4PhoneCont.text.isNotEmpty,
                    child: SizedBox(height: 8)),
                Visibility(
                    visible: anotherDeliver4PhoneCont.text.isNotEmpty,
                    child: Text(anotherDeliver4PhoneCont.text,
                        style: secondaryTextStyle())),
              ],
            ),
          ),
        ],
        if (anotherDeliverAddress5Cont.text.isNotEmpty) ...[
          SizedBox(height: 16),
          Text("Delivery Location 5", style: boldTextStyle()),
          SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress5Cont.text,
                    style: primaryTextStyle()),
                Visibility(
                    visible: anotherDeliver5PhoneCont.text.isNotEmpty,
                    child: SizedBox(height: 8)),
                Visibility(
                    visible: anotherDeliver5PhoneCont.text.isNotEmpty,
                    child: Text(anotherDeliver5PhoneCont.text,
                        style: secondaryTextStyle())),
              ],
            ),
          ),
        ],
        Divider(height: 30),
        OrderSummeryWidget(
          extraChargesList: extraChargeList,
          totalDistance: totalDistance,
          totalWeight: double.parse(weightController.text),
          distanceCharge: distanceCharge,
          weightCharge: weightCharge,
          totalAmount: totalAmount,
          carryPackagesCharge: isCarry == true ? carryPackagesCharge : 0,
          onAnotherCharges: anotherDeliverAddress5Cont.text.isNotEmpty
              ? chargePerAddress! * 4
              : anotherDeliverAddress4Cont.text.isNotEmpty
                  ? chargePerAddress! * 3
                  : anotherDeliverAddress3Cont.text.isNotEmpty
                      ? chargePerAddress! * 2
                      : anotherDeliverAddress2Cont.text.isNotEmpty
                          ? chargePerAddress! * 1
                          : 0,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text(language.paymentCollectFrom, style: boldTextStyle()),
            SizedBox(width: 4),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: paymentCollectFrom,
                decoration: commonInputDecoration(),
                items: [
                  DropdownMenuItem(
                      value: PAYMENT_ON_PICKUP,
                      child: Text(language.pickupLocation,
                          style: primaryTextStyle(), maxLines: 1)),
                  DropdownMenuItem(
                      value: PAYMENT_ON_DELIVERY,
                      child: Text(language.deliveryLocation,
                          style: primaryTextStyle(), maxLines: 1)),
                  if (anotherDeliverAddress2Cont.text.isNotEmpty) ...[
                    DropdownMenuItem(
                        value: PAYMENT_ON_ANOTHER_DELIVERY2,
                        child: Text("Delivery Location 2",
                            style: primaryTextStyle(), maxLines: 1)),
                  ],
                  if (anotherDeliverAddress3Cont.text.isNotEmpty) ...[
                    DropdownMenuItem(
                        value: PAYMENT_ON_ANOTHER_DELIVERY3,
                        child: Text("Delivery Location 3",
                            style: primaryTextStyle(), maxLines: 1)),
                  ],
                  if (anotherDeliverAddress4Cont.text.isNotEmpty) ...[
                    DropdownMenuItem(
                        value: PAYMENT_ON_ANOTHER_DELIVERY4,
                        child: Text("Delivery Location 4",
                            style: primaryTextStyle(), maxLines: 1)),
                  ],
                  if (anotherDeliverAddress5Cont.text.isNotEmpty) ...[
                    DropdownMenuItem(
                        value: PAYMENT_ON_ANOTHER_DELIVERY5,
                        child: Text("Delivery Location 5",
                            style: primaryTextStyle(), maxLines: 1)),
                  ],
                ],
                onChanged: (value) {
                  paymentCollectFrom = value!;
                  print(paymentCollectFrom);

                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedTabIndex == 0) {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            toast(language.pressBackAgainToExit);
            return false;
          }
          return true;
        } else {
          // selectedTabIndex--;
          // setState(() {});
          FocusScope.of(context).requestFocus(new FocusNode());
          if (selectedTabIndex == 7) {
            // selectedTabIndex = 2;
            if (anotherDeliverAddress5Cont.text.isNotEmpty) {
              selectedTabIndex = 6;
            } else if (anotherDeliverAddress4Cont.text.isNotEmpty) {
              selectedTabIndex = 5;
            } else if (anotherDeliverAddress3Cont.text.isNotEmpty) {
              selectedTabIndex = 4;
            } else if (anotherDeliverAddress2Cont.text.isNotEmpty) {
              selectedTabIndex = 3;
            } else if (deliverAddressCont.text.isNotEmpty) {
              selectedTabIndex = 2;
            }
          } else {
            selectedTabIndex--;
          }
          setState(() {});
          return false;
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(title: Text(language.create)),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding:
                    EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                            selectedTabIndex == 3
                                ? 5
                                : selectedTabIndex == 4
                                    ? 6
                                    : selectedTabIndex == 5
                                        ? 7
                                        : selectedTabIndex == 6
                                            ? 8
                                            : 4, (index) {
                          return Container(
                            alignment: Alignment.center,
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: selectedTabIndex >= index
                                  ? primaryColor
                                  : (appStore.isDarkMode
                                      ? scaffoldSecondaryDark
                                      : borderColor),
                              shape: BoxShape.circle,
                            ),
                            child: Text('${index + 1}',
                                style: primaryTextStyle(
                                    color: selectedTabIndex >= index
                                        ? Colors.white
                                        : null)),
                            /*color: selectedTabIndex >= index ? primaryColor : borderColor,
                            height: 5,
                            width: MediaQuery.of(context).size.width * 0.1,*/
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 30),
                      if (selectedTabIndex == 0) createOrderWidget1(),
                      if (selectedTabIndex == 1) createOrderWidget2(),
                      if (selectedTabIndex == 2) createOrderWidget3(),
                      if (selectedTabIndex == 3) createOrderWidget4(),
                      if (selectedTabIndex == 4) createOrderWidget5(),
                      if (selectedTabIndex == 5) createOrderWidget6(),
                      if (selectedTabIndex == 6) createOrderWidget7(),
                      if (selectedTabIndex == 7) createOrderWidget8(),
                    ],
                  ),
                ),
              ),
              Observer(
                builder: (context) => Visibility(
                    visible: appStore.isLoading, child: loaderWidget()),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                if (selectedTabIndex != 0)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: dialogSecondaryButton(language.previous, () {
                        print(selectedTabIndex);
                        print(deliverAddressCont.text);
                        print(anotherDeliverAddress2Cont.text);
                        print(anotherDeliverAddress3Cont.text);
                        print(anotherDeliverAddress4Cont.text);
                        print(anotherDeliverAddress5Cont.text);
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if (selectedTabIndex == 7) {
                          // selectedTabIndex = 2;
                          if (anotherDeliverAddress5Cont.text.isNotEmpty) {
                            selectedTabIndex = 6;
                          } else if (anotherDeliverAddress4Cont
                              .text.isNotEmpty) {
                            selectedTabIndex = 5;
                          } else if (anotherDeliverAddress3Cont
                              .text.isNotEmpty) {
                            selectedTabIndex = 4;
                          } else if (anotherDeliverAddress2Cont
                              .text.isNotEmpty) {
                            selectedTabIndex = 3;
                          } else if (deliverAddressCont.text.isNotEmpty) {
                            selectedTabIndex = 2;
                          }
                        } else {
                          selectedTabIndex--;
                        }
                        setState(() {});
                      }),
                    ),
                  ),
                Expanded(
                  child: dialogPrimaryButton(
                      selectedTabIndex != 7
                          ? language.next
                          : language.createOrder, () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    if (selectedTabIndex != 7) {
                      if (_formKey.currentState!.validate()) {
                        Duration difference = Duration();
                        Duration differenceCurrentTime = Duration();
                        if (!isDeliverNow) {
                          pickFromDateTime = pickDate!.add(Duration(
                              hours: pickFromTime!.hour,
                              minutes: pickFromTime!.minute));
                          pickToDateTime = pickDate!.add(Duration(
                              hours: pickToTime!.hour,
                              minutes: pickToTime!.minute));
                          deliverFromDateTime = deliverDate!.add(Duration(
                              hours: deliverFromTime!.hour,
                              minutes: deliverFromTime!.minute));
                          deliverToDateTime = deliverDate!.add(Duration(
                              hours: deliverToTime!.hour,
                              minutes: deliverToTime!.minute));
                          difference = pickFromDateTime!
                              .difference(deliverFromDateTime!);
                          differenceCurrentTime =
                              DateTime.now().difference(pickFromDateTime!);
                        }
                        if (differenceCurrentTime.inMinutes > 0)
                          return toast(language.pickupCurrentValidationMsg);
                        if (difference.inMinutes > 0)
                          return toast(language.pickupDeliverValidationMsg);
                        if (selectedTabIndex == 2) {
                          selectedTabIndex = 7;
                        } else if (selectedTabIndex == 3) {
                          selectedTabIndex = 7;
                        } else if (selectedTabIndex == 4) {
                          selectedTabIndex = 7;
                        } else if (selectedTabIndex == 5) {
                          selectedTabIndex = 7;
                        } else if (selectedTabIndex == 6) {
                          selectedTabIndex = 7;
                        } else {
                          selectedTabIndex++;
                        }
                        if (selectedTabIndex == 7) {
                          extraChargesList();
                          getTotalAmount();
                        }
                        setState(() {});
                      }
                    } else {
                      commonConfirmationDialog(context, DIALOG_TYPE_ENABLE, () {
                        createOrderApiCall(ORDER_CREATED);
                      },
                          title: language.createOrderQue,
                          subtitle: language.createOrderConfirmation);
                    }
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Exceeding Weight"),
    content: Text("Weight is exceeding than maximum value"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlertDialog2(BuildContext context) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Decreasing Weight"),
    content: Text("Weight is decreasing than minimum value"),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
