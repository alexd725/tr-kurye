import 'dart:convert';
import 'dart:core';

import 'package:contacts_service/contacts_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/CreditCardProvider.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/ParcelTypeListModel.dart';
import '../../main/models/PaymentModel.dart';
import '../../main/models/VehicleModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../main/components/OrderSummeryWidget.dart';
import '../../main/components/PickAddressBottomSheet.dart';
import '../../main/models/AutoCompletePlacesListModel.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/models/PlaceIdDetailModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/screens/CreditCard.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../../other_widgets/fialogs/fialogs.dart';
import '../components/CreateOrderConfirmationDialog.dart';
import '../components/PaymentScreen.dart';
import 'DashboardScreen.dart';
import 'WalletScreen.dart';

class CreateOrderScreen extends StatefulWidget {
  static String tag = '/CreateOrderScreen';

  final OrderData? orderData;

  CreateOrderScreen({this.orderData});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CityModel? cityData;
  List<ParcelTypeData> parcelTypeList = [];
  bool isBike = true;
  String? vehicle;
  String? delivery;
  String? delivery2;
  String? delivery3;
  String? delivery4;
  String? delivery5;

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

  String deliverCountryCode = defaultPhoneCode;
  String pickupCountryCode = defaultPhoneCode;

  //String deliverCountryCode = '+90';
  String anotherDeliver2CountryCode = defaultPhoneCode;
  String anotherDeliver3CountryCode = defaultPhoneCode;
  String anotherDeliver4CountryCode = defaultPhoneCode;
  String anotherDeliver5CountryCode = defaultPhoneCode;
  //String pickupCountryCode = '+90';

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
  int selectedTabIndex = 0;

  bool isCashPayment = true;
  bool isDeliverNow = true;
  int isSelected = 1;

  bool? isCash = false;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;

  DateTime? currentBackPressTime;

  num totalDistance = 0;
  num totalAmount = 0;

  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;
  List<PaymentModel> mPaymentList = getPaymentItems();

  List<ExtraChargeRequestModel> extraChargeList = [];

  //Kontrol et
  List<Predictions> pickPredictionList = [];
  List<Predictions> deliverPredictionList = [];

  int? selectedVehicle;
  List<VehicleData> vehicleList = [];
  VehicleData? vehicleData;

  String? pickMsg,
      deliverMsg,
      anotherDeliver2Msg,
      anotherDeliver3Msg,
      anotherDeliver4Msg,
      anotherDeliver5Msg;
  List vehicles_list = [];
  List delivery_list = [];
  List delivery_list_car = [];
  num? maxWeight;
  num? minWeight;
  List<CityModel> cityData_list = [];
  bool isCarry = true;
  num? carryPackagesCharge;
  num? chargePerAddress;
  num? totalChargePerAddress;
  Contact? _contact;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
      weightController.text = '1';
      appStore.isVehicleOrder = 0;
    });
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

  getCityApiCall({String? name}) async {
    appStore.setLoading(true);
    await getCityList(countryId: 0, name: name, order_type: delivery)
        .then((value) async {
      appStore.setLoading(false);
      cityData_list.clear();
      cityData_list.addAll(value.data!);
      if (name == null) {
        vehicles_list.clear();
        delivery_list.clear();
        delivery_list_car.clear();

        cityData_list.forEach((element) {
          // print(element.name);
          // print(cityData!.name);

          if (element.name == cityData!.name) {
            vehicles_list.add(element.vehicle_type);
            if (vehicles_list.isNotEmpty) {
              print("vehicles_list ${vehicles_list[0]}");
              vehicle = vehicles_list[0].toString();
              setState(() {});
            }
          }
          if (element.vehicle_type == "Bike" &&
              element.name == cityData!.name) {
            delivery_list.add(element.order_type);
          }
          if (element.vehicle_type != "Bike" &&
              element.name == cityData!.name) {
            delivery_list_car.add(element.order_type);
            if (vehicle == "Bike") {
              isBike = true;
              delivery = delivery_list[0];
            } else {
              isBike = false;
              delivery = delivery_list_car[0];
            }
            setState(() {});
          }
        });
        chargePerAddress = value.data![0].chargePerAddress != null
            ? value.data![0].chargePerAddress
            : 0;
      }
      await getVehicleApiCall2(name ?? cityData!.vehicle_type);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }
  //*************************88

  //************************8

  Future<void> init() async {
    minWeight = 1;
    maxWeight = 1;
    await getAppSettingApiCall();
    log('CITY_ID =====> ${getIntAsync(CITY_ID)}');
    await getCityDetailApiCall(getIntAsync(CITY_ID));
    await getParcelTypeListApiCall();
    extraChargesList();
    //getVehicleList(cityID: cityData!.id);
    await getCityApiCall();
    if (widget.orderData != null) {
      List<dynamic> deliveryPointsList =
          widget.orderData!.deliveryPointsList ?? [];
      if (widget.orderData!.totalWeight != 0)
        weightController.text = widget.orderData!.totalWeight!.toString();
      if (widget.orderData!.totalParcel != null)
        totalParcelController.text = widget.orderData!.totalParcel!.toString();
      parcelTypeCont.text = widget.orderData!.parcelType.validate();

      pickAddressCont.text = widget.orderData!.pickupPoint!.address.validate();
      pickLat = widget.orderData!.pickupPoint!.latitude.validate();
      pickLong = widget.orderData!.pickupPoint!.longitude.validate();
      if (widget.orderData!.pickupPoint!.contactNumber
              .validate()
              .split(" ")
              .length ==
          1) {
        pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      } else {
        pickupCountryCode = widget.orderData!.pickupPoint!.contactNumber
            .validate()
            .split(" ")
            .first;
        pickPhoneCont.text = widget.orderData!.pickupPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      }
      pickDesCont.text = widget.orderData!.pickupPoint!.description.validate();

      deliverAddressCont.text =
          widget.orderData!.deliveryPoint!.address.validate();
      deliverDesCont.text =
          widget.orderData!.deliveryPoint!.description.validate();
      deliverLat = widget.orderData!.deliveryPoint!.latitude.validate();
      deliverLong = widget.orderData!.deliveryPoint!.longitude.validate();

      isCarry = widget.orderData!.courierWillCarry == "1" ? true : false;

      if (deliveryPointsList.isNotEmpty) {
        // on another delivery 2
        if (deliveryPointsList.length >= 2) {
          anotherDeliverAddress2Cont.text = deliveryPointsList[1]['address'];
          anotherDeliver2DesCont.text = deliveryPointsList[1]['description'];
          anotherDeliver2Lat = deliveryPointsList[1]['latitude'];
          anotherDeliver2Long = deliveryPointsList[1]['longitude'];

          if (deliveryPointsList[1]['contact_number']
                  .toString()
                  .validate()
                  .split(" ")
                  .length ==
              1) {
            anotherDeliver2PhoneCont.text = deliveryPointsList[1]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          } else {
            anotherDeliver2CountryCode = deliveryPointsList[1]['contact_number']
                .toString()
                .validate()
                .split(" ")
                .first;
            anotherDeliver2PhoneCont.text = deliveryPointsList[1]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          }
        }
        // on another delivery 3
        if (deliveryPointsList.length >= 3) {
          anotherDeliverAddress3Cont.text = deliveryPointsList[2]['address'];
          anotherDeliver3DesCont.text = deliveryPointsList[2]['description'];
          anotherDeliver3Lat = deliveryPointsList[2]['latitude'];
          anotherDeliver3Long = deliveryPointsList[2]['longitude'];

          if (deliveryPointsList[2]['contact_number']
                  .toString()
                  .validate()
                  .split(" ")
                  .length ==
              1) {
            anotherDeliver3PhoneCont.text = deliveryPointsList[2]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          } else {
            anotherDeliver3CountryCode = deliveryPointsList[2]['contact_number']
                .toString()
                .validate()
                .split(" ")
                .first;
            anotherDeliver3PhoneCont.text = deliveryPointsList[2]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          }
        }
        // on another delivery 4
        if (deliveryPointsList.length >= 4) {
          anotherDeliverAddress4Cont.text = deliveryPointsList[3]['address'];
          anotherDeliver4DesCont.text = deliveryPointsList[3]['description'];
          anotherDeliver4Lat = deliveryPointsList[3]['latitude'];
          anotherDeliver4Long = deliveryPointsList[3]['longitude'];

          if (deliveryPointsList[3]['contact_number']
                  .toString()
                  .validate()
                  .split(" ")
                  .length ==
              1) {
            anotherDeliver4PhoneCont.text = deliveryPointsList[3]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          } else {
            anotherDeliver4CountryCode = deliveryPointsList[3]['contact_number']
                .toString()
                .validate()
                .split(" ")
                .first;
            anotherDeliver4PhoneCont.text = deliveryPointsList[3]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          }
        }
        // on another delivery 5
        if (deliveryPointsList.length >= 5) {
          anotherDeliverAddress5Cont.text = deliveryPointsList[4]['address'];
          anotherDeliver5DesCont.text = deliveryPointsList[4]['description'];
          anotherDeliver5Lat = deliveryPointsList[4]['latitude'];
          anotherDeliver5Long = deliveryPointsList[4]['longitude'];

          if (deliveryPointsList[4]['contact_number']
                  .toString()
                  .validate()
                  .split(" ")
                  .length ==
              1) {
            anotherDeliver5PhoneCont.text = deliveryPointsList[4]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          } else {
            anotherDeliver5CountryCode = deliveryPointsList[4]['contact_number']
                .toString()
                .validate()
                .split(" ")
                .first;
            anotherDeliver5PhoneCont.text = deliveryPointsList[4]
                    ['contact_number']
                .toString()
                .validate()
                .split(" ")
                .last;
          }
        }
      }

      if (widget.orderData!.deliveryPoint!.contactNumber
              .validate()
              .split(" ")
              .length ==
          1) {
        deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      } else {
        deliverCountryCode = widget.orderData!.deliveryPoint!.contactNumber
            .validate()
            .split(" ")
            .first;
        deliverPhoneCont.text = widget.orderData!.deliveryPoint!.contactNumber
            .validate()
            .split(" ")
            .last;
      }

      paymentCollectFrom = widget.orderData!.paymentCollectFrom
          .validate(value: PAYMENT_ON_PICKUP);
    }
  }

  extraChargesList() {
    extraChargeList.clear();
    extraChargeList.add(ExtraChargeRequestModel(
        key: FIXED_CHARGES, value: cityData!.fixedCharges, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(
        key: MIN_DISTANCE, value: cityData!.minDistance, valueType: ""));
    extraChargeList.add(ExtraChargeRequestModel(
        key: MIN_WEIGHT, value: cityData!.minWeight, valueType: ""));
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

  getCityDetailApiCall(int cityId) async {
    await getCityDetail(cityId).then((value) async {
      await setValue(CITY_DATA, value.data!.toJson());
      cityData = value.data!;
      await getVehicleApiCall();
      setState(() {});
    }).catchError((error) {});
  }

  getAppSettingApiCall() async {
    await getAppSetting().then((value) {
      carryPackagesCharge = value.carryPackagesCharges!;
      print("------------>carryPackagesCharge $carryPackagesCharge");
      // appStore.setCurrencyCode(value.currencyCode ?? currencyCodeDefault);
      print(value);
    }).catchError((error) {
      log(error.toString());
    });
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

//*************************************
  getVehicleApiCall({String? name}) async {
    appStore.setLoading(true);
    await getVehicleList(cityID: cityData!.id).then((value) {
      appStore.setLoading(false);
      vehicleList.clear();
      vehicles_list.clear();
      vehicleList = value.data!;
      if (value.data!.isNotEmpty) selectedVehicle = value.data![0].id;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error);
    });
  }
//*********************************

  getVehicleApiCall2(String? vehicleType) async {
    cityData_list.forEach((element) {
      print('cityData.name => ${element.name}');
      print('cityData.vehicle_type => ${element.vehicle_type}');
      print('cityData.vehicle_type => ${element.order_type}');
      print('cityData.minWeight => ${element.minWeight}');
      print('cityData.name => ${cityData!.name}');
      print('cityData.vehicle_type => ${vehicleType}');
      print('cityData.vehicle_type => ${delivery}');
      print(
          'result => ${element.name == cityData!.name && element.vehicle_type == vehicleType}');
      if (element.name == cityData!.name &&
          element.vehicle_type == vehicleType &&
          element.order_type == delivery) {
        cityData = element;
        minWeight = cityData!.minWeight;
        maxWeight = cityData!.maxWeight;
        weightController.text = minWeight.toString();
      }
    });
    //appStore.setLoading(true);
    //await getVehicleList(cityID: cityData!.id).then((value) {
    //  appStore.setLoading(false);
    //  // vehicleList.clear();
    //  //vehicles_list.clear();
    //  vehicleList = value.data!;
    //  if (value.data!.isNotEmpty) selectedVehicle = value.data![0].id;
    //  setState(() {});
    //}).catchError((error) {
    //  appStore.setLoading(false);
    //  toast(error);
    //});
  }

//   Future<void> getVehicleApiCall({String? name}) async {
//     appStore.setLoading(true);
//
//     await getVehicleList(cityID: cityData!.id).then((value) {
//       appStore.setLoading(false);
//       vehicleList.clear();
//
//       // Filter the vehicle list based on the selected city and vehicle type
//       vehicleList = value.data!.where((vehicle) =>
//       vehicle.cityText == cityData!.name && vehicle.type == selectedVehicle
//       ).toList();
// print("vehicleList is here $vehicleList" );
//       setState(() {});
//     }).catchError((error) {
//       appStore.setLoading(false);
//       toast(error);
//     });
//   }

  //++++++++++++++++++++++++++++++++++++++
  getTotalAmount() async {
    //if (paymentCollectFrom == PAYMENT_ON_ANOTHER_DELIVERY2) {
    //  totalDistance = await calculateDistance(
    //      pickLat.toDouble(),
    //      pickLong.toDouble(),
    //      anotherDeliver2Lat.toDouble(),
    //      anotherDeliver2Long.toDouble());
    //} else if (paymentCollectFrom == PAYMENT_ON_ANOTHER_DELIVERY3) {
    //  totalDistance = await calculateDistance(
    //      pickLat.toDouble(),
    //      pickLong.toDouble(),
    //      anotherDeliver2Lat.toDouble(),
    //      anotherDeliver2Long.toDouble());
    //  totalDistance += await calculateDistance(
    //      anotherDeliver2Lat.toDouble(),
    //      anotherDeliver2Long.toDouble(),
    //      anotherDeliver3Lat.toDouble(),
    //      anotherDeliver3Long.toDouble());
    //} else if (paymentCollectFrom == PAYMENT_ON_ANOTHER_DELIVERY4) {
    //  totalDistance = await calculateDistance(
    //      pickLat.toDouble(),
    //      pickLong.toDouble(),
    //      anotherDeliver2Lat.toDouble(),
    //      anotherDeliver2Long.toDouble());
    //  totalDistance += await calculateDistance(
    //      anotherDeliver2Lat.toDouble(),
    //      anotherDeliver2Long.toDouble(),
    //      anotherDeliver3Lat.toDouble(),
    //      anotherDeliver3Long.toDouble());
    //  totalDistance += await calculateDistance(
    //      anotherDeliver3Lat.toDouble(),
    //      anotherDeliver3Long.toDouble(),
    //      anotherDeliver4Lat.toDouble(),
    //      anotherDeliver4Long.toDouble());
    //} else if (paymentCollectFrom == PAYMENT_ON_ANOTHER_DELIVERY5) {
    totalDistance = await calculateDistance(pickLat.toDouble(),
        pickLong.toDouble(), deliverLat.toDouble(), deliverLong.toDouble());
    totalDistance += await calculateDistance(
        pickLat.toDouble(),
        pickLong.toDouble(),
        anotherDeliver2Lat.toDouble(),
        anotherDeliver2Long.toDouble());
    totalDistance += await calculateDistance(
        anotherDeliver2Lat.toDouble(),
        anotherDeliver2Long.toDouble(),
        anotherDeliver3Lat.toDouble(),
        anotherDeliver3Long.toDouble());
    totalDistance += await calculateDistance(
        anotherDeliver3Lat.toDouble(),
        anotherDeliver3Long.toDouble(),
        anotherDeliver4Lat.toDouble(),
        anotherDeliver4Long.toDouble());
    totalDistance += await calculateDistance(
        anotherDeliver4Lat.toDouble(),
        anotherDeliver4Long.toDouble(),
        anotherDeliver5Lat.toDouble(),
        anotherDeliver5Long.toDouble());
    //} else {

    //}

    print('totalDistanc => $totalDistance');

    totalAmount = 0;
    weightCharge = 0;
    distanceCharge = 0;
    totalExtraCharge = 0;
    totalChargePerAddress = 0;

    /// calculate weight Charge
    if (weightController.text.toDouble() >= minWeight!) {
      weightCharge =
          ((weightController.text.toDouble()) * cityData!.perWeightCharges!)
              .toStringAsFixed(digitAfterDecimal)
              .toDouble();
    }

    /// calculate distance Charge
    if (totalDistance > cityData!.minDistance!) {
      distanceCharge = ((totalDistance - cityData!.minDistance!) *
              cityData!.perDistanceCharges!)
          .toStringAsFixed(digitAfterDecimal)
          .toDouble();
    }

    print(
        'totalDistance > cityData!.minDistance! => ${totalDistance > cityData!.minDistance!}');
    print('distanceCharge => ${distanceCharge}');

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
    totalAmount = (totalAmount +
            totalExtraCharge +
            totalChargePerAddress! +
            totalCarryPackagesCharge!)
        .toStringAsFixed(digitAfterDecimal)
        .toDouble();
  }

  createOrderApiCall(String orderStatus) async {
    appStore.setLoading(true);
    Map req = {
      "id": widget.orderData != null ? widget.orderData!.id : "",
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": getIntAsync(COUNTRY_ID).toString(),
      "city_id": getIntAsync(CITY_ID).toString(),
      if (appStore.isVehicleOrder != 0)
        "vehicle_id": selectedVehicle.toString(),
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
      "total_weight": weightController.text.toDouble(),
      "total_distance":
          totalDistance.toStringAsFixed(digitAfterDecimal).validate(),
      "payment_collect_from": paymentCollectFrom,
      "status": orderStatus,
      "payment_type": "",
      "payment_status": "",
      "fixed_charges": cityData!.fixedCharges.toString(),
      "parent_order_id": "",
      "total_amount": totalAmount,
      "weight_charge": weightCharge,
      "distance_charge": distanceCharge,
      "total_parcel": totalParcelController.text.toInt(),
      "vehicle_type": vehicle,
      "order_type": isBike ? delivery : delivery,
    };
    print(req);

    log("req----" + req.toString());
    await createOrder(req).then((value) async {
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
      if (isSelected == 2) {
        PaymentScreen(
                orderId: value.orderId.validate(), totalAmount: totalAmount)
            .launch(context);
      } else if (isSelected == 3) {
        log("-----" + appStore.availableBal.toString());

        if (appStore.availableBal > totalAmount) {
          savePaymentApiCall(
              paymentType: PAYMENT_TYPE_WALLET,
              paymentStatus: PAYMENT_PAID,
              totalAmount: totalAmount.toString(),
              orderID: value.orderId.toString());
        } else {
          toast(language.balanceInsufficient);
          bool? res = await WalletScreen().launch(context);
          if (res == true) {
            if (appStore.availableBal > totalAmount) {
              savePaymentApiCall(
                  paymentType: PAYMENT_TYPE_WALLET,
                  paymentStatus: PAYMENT_PAID,
                  totalAmount: totalAmount.toString(),
                  orderID: value.orderId.toString());
            } else {
              cashConfirmDialog();
            }
          } else {
            cashConfirmDialog();
          }
        }
      } else {
        DashboardScreen().launch(context, isNewTask: true);
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  /// Save Payment
  Future<void> savePaymentApiCall(
      {String? paymentType,
      String? totalAmount,
      String? orderID,
      String? txnId,
      String? paymentStatus = PAYMENT_PENDING,
      Map? transactionDetail}) async {
    Map req = {
      "id": "",
      "order_id": orderID,
      "client_id": getIntAsync(USER_ID).toString(),
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
      "total_amount": totalAmount,
      "payment_type": paymentType,
      "txn_id": txnId,
      "payment_status": paymentStatus,
      "transaction_detail": transactionDetail ?? {}
    };

    appStore.setLoading(true);

    savePayment(req).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString());
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      appStore.setLoading(false);
      print(error.toString());
    });
  }

  /*await createOrder(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context);
      if (!isCashPayment) {
        PaymentScreen(orderId: value.orderId.validate(), totalAmount: totalAmount).launch(context);
      } else {
        DashboardScreen().launch(context, isNewTask: true);
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }*/

  Future<List<Predictions>> getPlaceAutoCompleteApiCall(String text) async {
    List<Predictions> list = [];
    await placeAutoCompleteApi(
            searchText: text,
            language: appStore.selectedLanguage,
            countryCode: CountryModel.fromJson(getJSONAsync(COUNTRY_DATA))
                .code
                .validate(value: 'IN'))
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget createOrderWidget1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            scheduleOptionWidget(context, isDeliverNow,
                    'assets/icons/ic_clock.png', language.deliveryNow)
                .onTap(() {
              isDeliverNow = true;
              setState(() {});
            }).expand(),
            16.width,
            scheduleOptionWidget(context, !isDeliverNow,
                    'assets/icons/ic_schedule.png', language.schedule)
                .onTap(() {
              isDeliverNow = false;
              setState(() {});
            }).expand(),
          ],
        ),
        16.height,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.pickTime, style: boldTextStyle()),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
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
                  16.height,
                  Row(
                    children: [
                      DateTimePicker(
                        controller: pickFromTimeController,
                        type: DateTimePickerType.time,
                        onChanged: (value) {
                          pickFromTime = TimeOfDay.fromDateTime(
                              DateFormat('hh:mm').parse(value));
                          setState(() {});
                        },
                        validator: (value) {
                          if (value.validate().isEmpty)
                            return errorThisFieldRequired;
                          return null;
                        },
                        decoration: commonInputDecoration(
                            suffixIcon: Icons.access_time,
                            hintText: language.from),
                      ).expand(),
                      16.width,
                      DateTimePicker(
                        controller: pickToTimeController,
                        type: DateTimePickerType.time,
                        onChanged: (value) {
                          pickToTime = TimeOfDay.fromDateTime(
                              DateFormat('hh:mm').parse(value));
                          setState(() {});
                        },
                        validator: (value) {
                          if (value.validate().isEmpty)
                            return errorThisFieldRequired;
                          double fromTimeInHour =
                              pickFromTime!.hour + pickFromTime!.minute / 60;
                          double toTimeInHour =
                              pickToTime!.hour + pickToTime!.minute / 60;
                          double difference = toTimeInHour - fromTimeInHour;
                          if (difference <= 0) {
                            return language.endTimeValidationMsg;
                          }
                          return null;
                        },
                        decoration: commonInputDecoration(
                            suffixIcon: Icons.access_time,
                            hintText: language.to),
                      ).expand()
                    ],
                  ),
                ],
              ),
            ),
            16.height,
            Text(language.deliverTime, style: boldTextStyle()),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
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
                  16.height,
                  Row(
                    children: [
                      DateTimePicker(
                        controller: deliverFromTimeController,
                        type: DateTimePickerType.time,
                        onChanged: (value) {
                          deliverFromTime = TimeOfDay.fromDateTime(
                              DateFormat('hh:mm').parse(value));
                          setState(() {});
                        },
                        validator: (value) {
                          if (value.validate().isEmpty)
                            return errorThisFieldRequired;
                          return null;
                        },
                        decoration: commonInputDecoration(
                            suffixIcon: Icons.access_time,
                            hintText: language.from),
                      ).expand(),
                      16.width,
                      DateTimePicker(
                        controller: deliverToTimeController,
                        type: DateTimePickerType.time,
                        onChanged: (value) {
                          deliverToTime = TimeOfDay.fromDateTime(
                              DateFormat('hh:mm').parse(value));
                          setState(() {});
                        },
                        validator: (value) {
                          if (value!.isEmpty) return errorThisFieldRequired;
                          double fromTimeInHour = deliverFromTime!.hour +
                              deliverFromTime!.minute / 60;
                          double toTimeInHour =
                              deliverToTime!.hour + deliverToTime!.minute / 60;
                          double difference = toTimeInHour - fromTimeInHour;
                          if (difference < 0) {
                            return language.endTimeValidationMsg;
                          }
                          return null;
                        },
                        decoration: commonInputDecoration(
                            suffixIcon: Icons.access_time,
                            hintText: language.to),
                      ).expand()
                    ],
                  ),
                ],
              ),
            ),
          ],
        ).visible(!isDeliverNow),
        16.height,
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
                /////////// SHEIKH HERE

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: DropdownButtonFormField<String>(
                    value: vehicle,
                    decoration: commonInputDecoration(),
                    items: vehicles_list
                        .toSet()
                        .map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // getVehicleApiCall();

                      print("++++++++++++++++++++++++++++++++++$vehicle");

                      setState(() {
                        vehicle = value!;
                        if (vehicle == "Bike") {
                          isBike = true;
                          delivery = delivery_list[0];
                          appStore.isVehicleOrder = 0;
                          //  weightController= cityData!.minWeight as TextEditingController;
                        } else {
                          isBike = false;
                          delivery = delivery_list_car[0];
                          appStore.isVehicleOrder = 1;
                          //  weightController= cityData!.minWeight as TextEditingController;
                        }
                        getCityApiCall(name: vehicle);
                      });
                    },
                    validator: (value) {
                      if (vehicle == null) return errorThisFieldRequired;
                      return null;
                    },
                  ),
                ),

                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.4,
                //   child: DropdownButtonFormField<String>(
                //     isExpanded: true,
                //     value: vehicle,
                //     dropdownColor: Theme.of(context).cardColor,
                //     style: primaryTextStyle(),
                //     decoration: commonInputDecoration(),
                //     items: [
                //       DropdownMenuItem(value: "Bike", child: Text("Bike", style: primaryTextStyle(), maxLines: 1)),
                //       DropdownMenuItem(value: "Car", child: Text("Car", style: primaryTextStyle(), maxLines: 1)),
                //
                //     ],
                //     onChanged: (value) {
                //       vehicle = value!;
                //       print(vehicle);
                //       setState(() {
                //         if(vehicle == "Bike"){
                //           isBike = true;
                //         }
                //         else{
                //           isBike  = false;
                //         }
                //       });
                //     },
                //   ),
                // ),

                //////// SHEIKH HERE
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
                // isBike ?
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.46,
                  child: DropdownButtonFormField<String>(
                    value: delivery,
                    decoration: commonInputDecoration(),
                    items: isBike
                        ? (delivery_list
                            .toSet()
                            .map<DropdownMenuItem<String>>((itemD) {
                            return DropdownMenuItem(
                              value: itemD,
                              child: Text(itemD ?? ''),
                            );
                          }).toList())
                        : (delivery_list_car
                            .toSet()
                            .map<DropdownMenuItem<String>>((itemD) {
                            return DropdownMenuItem(
                              value: itemD,
                              child: Text(itemD ?? ''),
                            );
                          }).toList()),
                    onChanged: (valueD) async {
                      delivery = valueD!;

                      await getCityApiCall(name: vehicle);
                      setState(() {
                        if (double.tryParse(weightController.text)! <
                                minWeight!.toDouble() ||
                            double.tryParse(weightController.text)! >
                                maxWeight!.toDouble()) {
                          print(true);
                          setState(() {
                            weightController.text = minWeight.toString();
                          });
                        }
                      });
                    },
                    // validator: (value) {
                    //   if (selectedCountry == null)
                    //     return errorThisFieldRequired;
                    //   return null;
                    // },
                  ),
                )
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.45,
                //   child: DropdownButtonFormField<String>(
                //     value: delivery1,
                //     decoration: commonInputDecoration(),
                //     items: delivery_list_car.toSet()
                //         .map<DropdownMenuItem<String>>((itemT) {
                //       return DropdownMenuItem(
                //         value: itemT,
                //         child: Text(itemT ?? ''),
                //       );
                //     }).toList(),
                //     onChanged: (valueT) {
                //       vehicle = valueT!;
                //       setState(() {
                //         delivery1= valueT!;
                //         setState(() {});
                //       });
                //     },
                //     // validator: (value) {
                //     //   if (selectedCountry == null)
                //     //     return errorThisFieldRequired;
                //     //   return null;
                //     // },
                //   ),
                // ),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.4,
                //   child: DropdownButtonFormField<String>(
                //     isExpanded: true,
                //     value: delivery,
                //     dropdownColor: Theme.of(context).cardColor,
                //     style: primaryTextStyle(),
                //     decoration: commonInputDecoration(),
                //     items: [
                //       DropdownMenuItem(value: "In-Day Delivery", child: Text("In-Day Delivery", style: primaryTextStyle(), maxLines: 1)),
                //       DropdownMenuItem(value: "Express Delivery", child: Text("Express Delivery", style: primaryTextStyle(), maxLines: 1)),
                //       DropdownMenuItem(value: "Vip Delivery", child: Text("Vip Delivery", style: primaryTextStyle(), maxLines: 1)),
                //     ],
                //     onChanged: (value) {
                //       delivery = value!;
                //       setState(() {});
                //     },
                //   ),
                // ) :
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.4,
                //   child: DropdownButtonFormField<String>(
                //     isExpanded: true,
                //     value: delivery1,
                //     dropdownColor: Theme.of(context).cardColor,
                //     style: primaryTextStyle(),
                //     decoration: commonInputDecoration(),
                //     items: [
                //       DropdownMenuItem(value: "Express Delivery", child: Text("Express Delivery", style: primaryTextStyle(), maxLines: 1)),
                //       DropdownMenuItem(value: "Vip Delivery", child: Text("Vip Delivery", style: primaryTextStyle(), maxLines: 1)),
                //     ],
                //     onChanged: (value) {
                //       delivery1 = value!;
                //       setState(() {});
                //     },
                //   ),
                // ),
              ],
            )
          ],
        ),
        16.height,
        ////////////////////////// SHEIKH
        Text(language.weight, style: boldTextStyle()),
        8.height,
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              borderRadius: BorderRadius.circular(defaultRadius)),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.weight, style: primaryTextStyle())
                    .paddingAll(12)
                    .expand(),
                VerticalDivider(thickness: 1),
                Icon(Icons.remove,
                        color: appStore.isDarkMode ? Colors.white : Colors.grey)
                    .paddingAll(12)
                    .onTap(() {
                  if (weightController.text.toDouble() > 1) {
                    weightController.text =
                        (weightController.text.toDouble() - 1).toString();
                  }
                  if (double.tryParse(weightController.text)! < minWeight!) {
                    weightController.text = minWeight!.toString();
                    showAlertDialog2(context);
                  }
                }),
                VerticalDivider(thickness: 1),
                Container(
                  width: 50,
                  child: AppTextField(
                    controller: weightController,
                    textAlign: TextAlign.center,
                    maxLength: 5,
                    textFieldType: TextFieldType.PHONE,
                    validator: (value) {
                      print("${value} Pal");
                      print('minWeight =======> $minWeight');
                      print('maxWeight =======> $maxWeight');
                      // iamrafehdev
                      if (double.tryParse(value!)! < minWeight!.toDouble() ||
                          double.tryParse(value)! > maxWeight!.toDouble())
                        return language.fieldRequiredMsg;
                      return null;
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colorPrimary)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                VerticalDivider(thickness: 1),
                Icon(Icons.add,
                        color: appStore.isDarkMode ? Colors.white : Colors.grey)
                    .paddingAll(12)
                    .onTap(() {
                  weightController.text =
                      (weightController.text.toDouble() + 1).toString();
                  if (double.tryParse(weightController.text)! > maxWeight!) {
                    weightController.text = maxWeight!.toString();
                    showAlertDialog(context);
                  }
                  if (double.tryParse(weightController.text)! < minWeight!) {
                    weightController.text = minWeight!.toString();
                    // showAlertDialog2(context);
                  }
                }),
              ],
            ),
          ),
        ),
        16.height,
        Text(language.numberOfParcels, style: boldTextStyle()),
        8.height,
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              borderRadius: BorderRadius.circular(defaultRadius)),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.numberOfParcels, style: primaryTextStyle())
                    .paddingAll(12)
                    .expand(),
                VerticalDivider(thickness: 1),
                Icon(Icons.remove,
                        color: appStore.isDarkMode ? Colors.white : Colors.grey)
                    .paddingAll(12)
                    .onTap(() {
                  if (totalParcelController.text.toInt() > 1) {
                    totalParcelController.text =
                        (totalParcelController.text.toInt() - 1).toString();
                  }
                }),
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
                          borderSide: BorderSide(color: colorPrimary)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                VerticalDivider(thickness: 1),
                Icon(Icons.add,
                        color: appStore.isDarkMode ? Colors.white : Colors.grey)
                    .paddingAll(12)
                    .onTap(() {
                  totalParcelController.text =
                      (totalParcelController.text.toInt() + 1).toString();
                }),
              ],
            ),
          ),
        ),
        16.height,
        Text(language.parcelType, style: boldTextStyle()),
        8.height,
        AppTextField(
          controller: parcelTypeCont,
          textFieldType: TextFieldType.OTHER,
          decoration: commonInputDecoration(),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            return null;
          },
        ),
        8.height,

        Wrap(
          spacing: 8,
          runSpacing: 0,
          children: parcelTypeList.map((item) {
            return Chip(
              backgroundColor: context.scaffoldBackgroundColor,
              label: Text(item.label!),
              elevation: 0,
              labelStyle: primaryTextStyle(color: Colors.grey),
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
                side: BorderSide(
                    color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              ),
            ).onTap(() {
              parcelTypeCont.text = item.label!;
              setState(() {});
            });
          }).toList(),
        ),
        16.height,
        SwitchListTile(
          value: isCarry,
          onChanged: (value) {
            isCarry = value;
            print(isCarry);
            setState(() {});
          },
          title: Text("Courier will carry packages", style: primaryTextStyle()),
          controlAffinity: ListTileControlAffinity.trailing,
          inactiveTrackColor:
              appStore.isDarkMode ? Colors.white12 : Colors.black12,
          activeColor: Colors.deepPurple,
        ),
        16.height,

        Visibility(
          visible: appStore.isVehicleOrder != 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.select_vehicle, style: boldTextStyle()),
              8.height,
              DropdownButtonFormField<int>(
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
                  //getVehicleApiCall2();
                  print(selectedVehicle);
                  print("dddddddddd");

                  setState(() {
                    weightController.text = minWeight.toString();
                  });
                },
                validator: (value) {
                  if (selectedVehicle == null) return errorThisFieldRequired;
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createOrderWidget2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.pickupInformation, style: boldTextStyle()),
        16.height,
        Text(language.pickupLocation, style: primaryTextStyle()),
        8.height,
        //***************************************
        AppTextField(
          controller: pickAddressCont,
          textInputAction: TextInputAction.next,
          nextFocus: pickPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (!mTestMode) if (pickLat == null || pickLong == null)
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
        //****************************************
        // AppTextField(
        //   controller: pickAddressCont,
        //  // readOnly: true,
        //   textInputAction: TextInputAction.next,
        //   nextFocus: pickPhoneFocus,
        //   textFieldType: TextFieldType.MULTILINE,
        //   decoration:
        //       commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //   validator: (value) {
        //     if (value!.isEmpty) return language.fieldRequiredMsg;
        //     if (pickLat == null || pickLong == null)
        //       return language.pleaseSelectValidAddress;
        //     return null;
        //   },
        //   onChanged: (val) async {
        //     pickMsg = '';
        //     pickLat = null;
        //     pickLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         pickMsg = language
        //             .selectedAddressValidation;
        //         pickPredictionList.clear();
        //         setState(() {});
        //       } else {
        //         pickPredictionList =
        //         await getPlaceAutoCompleteApiCall(
        //             val);
        //         setState(() {});
        //       }
        //     } else {
        //       pickPredictionList.clear();
        //       setState(() {});
        //     }
        //   },
        //   onTap: () {
        //     showModalBottomSheet(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.vertical(
        //               top: Radius.circular(defaultRadius))),
        //       context: context,
        //       builder: (context) {
        //         return PickAddressBottomSheet(
        //           onPick: (address) {
        //             pickAddressCont.text = address.placeAddress ?? "";
        //             pickLat = address.latitude.toString();
        //             pickLong = address.longitude.toString();
        //             /*onChanged: (val) async {
        //     pickMsg = '';
        //     pickLat = null;
        //     pickLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         pickMsg = language.selectedAddressValidation;
        //         pickPredictionList.clear();*/
        //             setState(() {});
        //             /*} else {
        //         pickPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       pickPredictionList.clear();
        //       setState(() {});
        //     }*/
        //           },
        //         );
        //         /*if (!pickMsg.isEmptyOrNull)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         pickMsg.validate(),
        //         style: secondaryTextStyle(color: Colors.red),
        //       )),
        // if (pickPredictionList.isNotEmpty)
        //   ListView.builder(
        //       physics: NeverScrollableScrollPhysics(),
        //       controller: ScrollController(),
        //       shrinkWrap: true,
        //       padding: EdgeInsets.only(top: 16, bottom: 16),
        //       itemCount: pickPredictionList.length,
        //       itemBuilder: (context, index) {
        //         Predictions mData = pickPredictionList[index];
        //         return ListTile(
        //           leading: Icon(Icons.location_pin, color: colorPrimary),
        //           title: Text(mData.description ?? ""),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               pickAddressCont.text = mData.description ?? "";
        //               pickLat = response.result!.geometry!.location!.lat.toString();
        //               pickLong = response.result!.geometry!.location!.lng.toString();
        //               pickPredictionList.clear();
        //               setState(() {});
        //             }*/
        //       },
        //     );
        //   },
        // ),
        //     AppTextField(
        //       controller: pickAddressCont,
        //       textInputAction: TextInputAction.next,
        //       readOnly: true,
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
        //               leading: Icon(Icons.location_pin),
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
        // AppTextField(
        //   controller: pickAddressCont,
        //   textInputAction: TextInputAction.next,
        //   textFieldType: TextFieldType.ADDRESS,
        //   decoration: commonInputDecoration(
        //       suffixIcon: Icons.location_on_outlined),
        //   validator: (value) {
        //     if (value!.isEmpty)
        //       return errorThisFieldRequired;
        //     if (pickLat == null || pickLong == null)
        //       return language
        //           .pleaseSelectValidAddress;
        //     return null;
        //   },
        //
        //   onChanged: (val) async {
        //     pickMsg = '';
        //     pickLat = null;
        //     pickLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         pickMsg = language
        //             .selectedAddressValidation;
        //         pickPredictionList.clear();
        //         setState(() {});
        //       } else {
        //         pickPredictionList =
        //         await getPlaceAutoCompleteApiCall(
        //             val);
        //         setState(() {});
        //       }
        //     } else {
        //       pickPredictionList.clear();
        //       setState(() {});
        //     }
        //   },
        //
        // ),
        if (!pickMsg.isEmptyOrNull)
          Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Text(
                pickMsg.validate(),
                style: secondaryTextStyle(color: Colors.red),
              )),
        if (pickPredictionList.isNotEmpty)
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              controller: ScrollController(),
              padding: EdgeInsets.only(top: 16, bottom: 16),
              shrinkWrap: true,
              itemCount: pickPredictionList.length,
              itemBuilder: (context, index) {
                Predictions mData = pickPredictionList[index];
                return ListTile(
                  leading: Icon(
                    Icons.location_pin,
                  ),
                  title: Text(mData.description ?? ""),
                  onTap: () async {
                    PlaceIdDetailModel? response =
                        await getPlaceIdDetailApiCall(placeId: mData.placeId!);
                    if (response != null) {
                      pickAddressCont.text = mData.description ?? "";
                      pickLat =
                          response.result!.geometry!.location!.lat.toString();
                      pickLong =
                          response.result!.geometry!.location!.lng.toString();
                      pickPredictionList.clear();
                      setState(() {});
                    }
                  },
                );
              }),
        16.height,
        Text(language.pickupContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: pickPhoneCont,
          focus: pickPhoneFocus,
          nextFocus: pickDesFocus,
          textFieldType: TextFieldType.PHONE,
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
                    dialogSize:
                        Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
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
                          borderSide: BorderSide(color: colorPrimary)),
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
            ),
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLength;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        16.height,
        Text(language.pickupDescription, style: primaryTextStyle()),
        8.height,
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
        16.height,
        Text(language.deliveryLocation, style: primaryTextStyle()),
        8.height,
        //********************************88
        AppTextField(
          controller: deliverAddressCont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (!mTestMode) if (deliverLat == null || deliverLong == null)
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
                  leading: Icon(Icons.location_pin),
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
        //**************************************
        // AppTextField(
        //   controller: deliverAddressCont,
        //  // readOnly: true,
        //   textInputAction: TextInputAction.next,
        //   nextFocus: deliverPhoneFocus,
        //   textFieldType: TextFieldType.MULTILINE,
        //   decoration:
        //       commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //   validator: (value) {
        //     if (value!.isEmpty) return language.fieldRequiredMsg;
        //     if (deliverLat == null || deliverLong == null)
        //       return language.pleaseSelectValidAddress;
        //     return null;
        //   },
        //   onTap: () {
        //     showModalBottomSheet(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.vertical(
        //               top: Radius.circular(defaultRadius))),
        //       context: context,
        //       builder: (context) {
        //         return PickAddressBottomSheet(
        //           onPick: (address) {
        //             deliverAddressCont.text = address.placeAddress ?? "";
        //             deliverLat = address.latitude.toString();
        //             deliverLong = address.longitude.toString();
        //             /*onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();*/
        //             setState(() {});
        //             /*} else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }*/
        //           },
        //           isPickup: false,
        //         );
        //         /*),
        // if (!deliverMsg.isEmptyOrNull)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg.validate(),
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
        //           leading: Icon(Icons.location_pin, color: colorPrimary),
        //           title: Text(mData.description ?? ""),
        //           onTap: () async {
        //             PlaceIdDetailModel? response = await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               deliverAddressCont.text = mData.description ?? "";
        //               deliverLat = response.result!.geometry!.location!.lat.toString();
        //               deliverLong = response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }*/
        //       },
        //     );
        //   },
        // ),
        // AppTextField(
        //   controller: deliverAddressCont,
        //   textInputAction: TextInputAction.next,
        //   textFieldType: TextFieldType.ADDRESS,
        //   decoration: commonInputDecoration(
        //       suffixIcon: Icons.location_on_outlined),
        //   validator: (value) {
        //     if (value!.isEmpty)
        //       return errorThisFieldRequired;
        //     if (deliverLat == null ||
        //         deliverLong == null)
        //       return language
        //           .pleaseSelectValidAddress;
        //     return null;
        //   },
        //   onChanged: (val) async {
        //     deliverMsg = '';
        //     deliverLat = null;
        //     deliverLong = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         deliverMsg = language
        //             .selectedAddressValidation;
        //         deliverPredictionList.clear();
        //         setState(() {});
        //       } else {
        //         deliverPredictionList =
        //         await getPlaceAutoCompleteApiCall(
        //             val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }
        //   },
        // ),
        // if (!deliverMsg.isEmptyOrNull)
        //   Padding(
        //       padding:
        //       EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         deliverMsg.validate(),
        //         style: secondaryTextStyle(
        //             color: Colors.red),
        //       )),
        // if (deliverPredictionList.isNotEmpty)
        //   ListView.builder(
        //     physics: NeverScrollableScrollPhysics(),
        //     controller: ScrollController(),
        //     padding:
        //     EdgeInsets.only(top: 16, bottom: 16),
        //     shrinkWrap: true,
        //     itemCount: deliverPredictionList.length,
        //     itemBuilder: (context, index) {
        //       Predictions mData =
        //       deliverPredictionList[index];
        //       return ListTile(
        //         leading: Icon(Icons.location_pin,
        //             ),
        //         title: Text(mData.description ?? ""),
        //         onTap: () async {
        //           PlaceIdDetailModel? response =
        //           await getPlaceIdDetailApiCall(
        //               placeId: mData.placeId!);
        //           if (response != null) {
        //             deliverAddressCont.text =
        //                 mData.description ?? "";
        //             deliverLat = response.result!
        //                 .geometry!.location!.lat
        //                 .toString();
        //             deliverLong = response.result!
        //                 .geometry!.location!.lng
        //                 .toString();
        //             deliverPredictionList.clear();
        //             setState(() {});
        //           }
        //         },
        //       );
        //     },
        //   ),
        16.height,
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: deliverPhoneCont,
          textInputAction: TextInputAction.next,
          focus: deliverPhoneFocus,
          nextFocus: deliverDesFocus,
          textFieldType: TextFieldType.PHONE,
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
                    dialogSize:
                        Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
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
                          borderSide: BorderSide(color: colorPrimary)),
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
          validator: (value) {
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLength;
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: deliverDesCont,
          focusNode: deliverDesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        commonButton('Add Another Address', () async {
          if (_formKey.currentState!.validate()) {
            var distance = await calculateDistance(
                pickLat.toDouble(),
                pickLong.toDouble(),
                deliverLat.toDouble(),
                deliverLong.toDouble());
            if (distance < cityData!.minDistance!) {
              errorDialog(context, "Warning",
                  "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                  neutralButtonText: "OK");
            } else {
              selectedTabIndex = 3;
            }
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
        16.height,
        Text(language.deliveryLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliverAddress2Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (!mTestMode) if (anotherDeliver2Lat == null ||
                anotherDeliver2Long == null)
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
                    anotherDeliver2Lat = address.latitude.toString();
                    anotherDeliver2Long = address.longitude.toString();
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
                  leading: Icon(Icons.location_pin),
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
        //********************

        // AppTextField(
        //   controller: anotherDeliverAddress2Cont,
        //   textInputAction: TextInputAction.next,
        //   nextFocus: anotherDeliver2PhoneFocus,
        //   textFieldType: TextFieldType.MULTILINE,
        //   decoration:
        //       commonInputDecoration(suffixIcon: Icons.location_on_outlined),
        //   validator: (value) {
        //     if (value!.isEmpty) return language.fieldRequiredMsg;
        //     if (deliverLat == null || deliverLong == null)
        //       return language.pleaseSelectValidAddress;
        //     return null;
        //   },
        //   onChanged: (val) async {
        //     anotherDeliver2Msg = '';
        //     anotherDeliver2Lat = null;
        //     anotherDeliver2Long = null;
        //     if (val.isNotEmpty) {
        //       if (val.length < 3) {
        //         anotherDeliver2Msg = language.selectedAddressValidation;
        //         deliverPredictionList.clear();
        //         setState(() {});
        //       } else {
        //         deliverPredictionList = await getPlaceAutoCompleteApiCall(val);
        //         setState(() {});
        //       }
        //     } else {
        //       deliverPredictionList.clear();
        //       setState(() {});
        //     }
        //   },
        // ),
        // if (!anotherDeliver2Msg.isEmptyOrNull)
        //   Padding(
        //       padding: EdgeInsets.only(top: 8, left: 8),
        //       child: Text(
        //         anotherDeliver2Msg.validate(),
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
        //           leading: Icon(Icons.location_pin, color: colorPrimary),
        //           title: Text(mData.description ?? ""),
        //           onTap: () async {
        //             PlaceIdDetailModel? response =
        //                 await getPlaceIdDetailApiCall(placeId: mData.placeId!);
        //             if (response != null) {
        //               anotherDeliverAddress2Cont.text = mData.description ?? "";
        //               anotherDeliver2Lat =
        //                   response.result!.geometry!.location!.lat.toString();
        //               anotherDeliver2Long =
        //                   response.result!.geometry!.location!.lng.toString();
        //               deliverPredictionList.clear();
        //               setState(() {});
        //             }
        //           },
        //         );
        //       }),
        //^^^^^^^^^^^^^^^^^^^6
        16.height,
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliver2PhoneCont,
          textInputAction: TextInputAction.next,
          focus: anotherDeliver2PhoneFocus,
          nextFocus: anotherDeliver2DesFocus,
          textFieldType: TextFieldType.PHONE,
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
                    dialogSize:
                        Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
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
                          borderSide: BorderSide(color: colorPrimary)),
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
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLength;
            return null;
          },
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: anotherDeliver2DesCont,
          focusNode: anotherDeliver2DesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        commonButton('Add Another Address', () async {
          if (_formKey.currentState!.validate()) {
            var distance = await calculateDistance(
                pickLat.toDouble(),
                pickLong.toDouble(),
                anotherDeliver2Lat.toDouble(),
                anotherDeliver2Long.toDouble());
            if (distance < cityData!.minDistance!) {
              errorDialog(context, "Warning",
                  "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                  neutralButtonText: "OK");
            } else {
              selectedTabIndex = 4;
            }

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
        16.height,
        Text(language.deliveryLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliverAddress3Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (!mTestMode) if (anotherDeliver3Lat == null ||
                anotherDeliver3Long == null)
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
                    anotherDeliver3Lat = address.latitude.toString();
                    anotherDeliver3Long = address.longitude.toString();
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
                  leading: Icon(Icons.location_pin),
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
        16.height,
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliver3PhoneCont,
          textInputAction: TextInputAction.next,
          focus: anotherDeliver3PhoneFocus,
          nextFocus: anotherDeliver3DesFocus,
          textFieldType: TextFieldType.PHONE,
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
                    dialogSize:
                        Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
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
                          borderSide: BorderSide(color: colorPrimary)),
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
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLength;
            return null;
          },
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: anotherDeliver3DesCont,
          focusNode: anotherDeliver3DesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        commonButton('Add Another Address', () async {
          if (_formKey.currentState!.validate()) {
            var distance = await calculateDistance(
                pickLat.toDouble(),
                pickLong.toDouble(),
                anotherDeliver3Lat.toDouble(),
                anotherDeliver3Long.toDouble());
            if (distance < cityData!.minDistance!) {
              errorDialog(context, "Warning",
                  "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                  neutralButtonText: "OK");
            } else {
              selectedTabIndex = 5;
            }

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
        16.height,
        Text(language.deliveryLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliverAddress4Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (!mTestMode) if (anotherDeliver4Lat == null ||
                anotherDeliver4Long == null)
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
                    anotherDeliver4Lat = address.latitude.toString();
                    anotherDeliver4Long = address.longitude.toString();
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
                  leading: Icon(Icons.location_pin),
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
        16.height,
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliver4PhoneCont,
          textInputAction: TextInputAction.next,
          focus: anotherDeliver4PhoneFocus,
          nextFocus: anotherDeliver4DesFocus,
          textFieldType: TextFieldType.PHONE,
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
                    dialogSize:
                        Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
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
                          borderSide: BorderSide(color: colorPrimary)),
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
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLength;
            return null;
          },
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
        TextField(
          controller: anotherDeliver4DesCont,
          focusNode: anotherDeliver4DesFocus,
          decoration: commonInputDecoration(suffixIcon: Icons.notes),
          textInputAction: TextInputAction.done,
          maxLines: 3,
          minLines: 3,
        ),
        SizedBox(height: 50.0),
        commonButton('Add Another Address', () async {
          if (_formKey.currentState!.validate()) {
            var distance = await calculateDistance(
                pickLat.toDouble(),
                pickLong.toDouble(),
                anotherDeliver4Lat.toDouble(),
                anotherDeliver4Long.toDouble());
            if (distance < cityData!.minDistance!) {
              errorDialog(context, "Warning",
                  "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                  neutralButtonText: "OK");
            } else {
              selectedTabIndex = 6;
            }

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
        16.height,
        Text(language.deliveryLocation, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliverAddress5Cont,
          textInputAction: TextInputAction.next,
          nextFocus: deliverPhoneFocus,
          textFieldType: TextFieldType.ADDRESS,
          decoration:
              commonInputDecoration(suffixIcon: Icons.location_on_outlined),
          validator: (value) {
            if (value!.isEmpty) return language.fieldRequiredMsg;
            if (!mTestMode) if (anotherDeliver5Lat == null ||
                anotherDeliver5Long == null)
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
                    anotherDeliver5Lat = address.latitude.toString();
                    anotherDeliver5Long = address.longitude.toString();
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
                  leading: Icon(Icons.location_pin),
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
        16.height,
        Text(language.deliveryContactNumber, style: primaryTextStyle()),
        8.height,
        AppTextField(
          controller: anotherDeliver5PhoneCont,
          textInputAction: TextInputAction.next,
          focus: anotherDeliver5PhoneFocus,
          nextFocus: anotherDeliver5DesFocus,
          textFieldType: TextFieldType.PHONE,
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
                    dialogSize:
                        Size(context.width() - 60, context.height() * 0.6),
                    showFlag: true,
                    showFlagDialog: true,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
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
                          borderSide: BorderSide(color: colorPrimary)),
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
            if (value!.trim().isEmpty) return language.fieldRequiredMsg;
            if (value.trim().length < minContactLength ||
                value.trim().length > maxContactLength)
              return language.contactLength;
            return null;
          },
        ),
        16.height,
        Text(language.deliveryDescription, style: primaryTextStyle()),
        8.height,
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
        8.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
                color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.parcelType, style: primaryTextStyle()),
                  16.width,
                  Text(parcelTypeCont.text,
                          style: primaryTextStyle(),
                          maxLines: 3,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis)
                      .expand(),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.weight, style: primaryTextStyle()),
                  16.width,
                  Text(
                      '${weightController.text} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}',
                      style: primaryTextStyle()),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number of parcels', style: primaryTextStyle()),
                  16.width,
                  Text('${totalParcelController.text}',
                      style: primaryTextStyle()),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vehicle Type', style: primaryTextStyle()),
                  16.width,
                  Text('${vehicle}', style: primaryTextStyle()),
                ],
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Type', style: primaryTextStyle()),
                  16.width,
                  Text('${isBike ? delivery : delivery}',
                      style: primaryTextStyle()),
                ],
              ),
            ],
          ),
        ),
        16.height,
        Text(language.pickupLocation, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
                color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pickAddressCont.text, style: primaryTextStyle()),
              8.height.visible(pickPhoneCont.text.isNotEmpty),
              Text(pickPhoneCont.text, style: secondaryTextStyle())
                  .visible(pickPhoneCont.text.isNotEmpty),
            ],
          ),
        ),
        16.height,
        Text(language.deliveryLocation, style: boldTextStyle()),
        8.height,
        Container(
          width: context.width(),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            border: Border.all(
                color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
            backgroundColor: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deliverAddressCont.text, style: primaryTextStyle()),
              8.height.visible(deliverPhoneCont.text.isNotEmpty),
              Text(deliverPhoneCont.text, style: secondaryTextStyle())
                  .visible(deliverPhoneCont.text.isNotEmpty),
            ],
          ),
        ),
        if (anotherDeliverAddress2Cont.text.isNotEmpty) ...[
          16.height,
          Text("Delivery Location 2", style: boldTextStyle()),
          8.height,
          Container(
            width: context.width(),
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              backgroundColor: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress2Cont.text,
                    style: primaryTextStyle()),
                8.height.visible(anotherDeliver2PhoneCont.text.isNotEmpty),
                Text(anotherDeliver2PhoneCont.text, style: secondaryTextStyle())
                    .visible(anotherDeliver2PhoneCont.text.isNotEmpty),
              ],
            ),
          ),
        ],
        if (anotherDeliverAddress3Cont.text.isNotEmpty) ...[
          16.height,
          Text("Delivery Location 3", style: boldTextStyle()),
          8.height,
          Container(
            width: context.width(),
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              backgroundColor: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress3Cont.text,
                    style: primaryTextStyle()),
                8.height.visible(anotherDeliver3PhoneCont.text.isNotEmpty),
                Text(anotherDeliver3PhoneCont.text, style: secondaryTextStyle())
                    .visible(anotherDeliver3PhoneCont.text.isNotEmpty),
              ],
            ),
          ),
        ],
        if (anotherDeliverAddress4Cont.text.isNotEmpty) ...[
          16.height,
          Text("Delivery Location 4", style: boldTextStyle()),
          8.height,
          Container(
            width: context.width(),
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              backgroundColor: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress4Cont.text,
                    style: primaryTextStyle()),
                8.height.visible(anotherDeliver4PhoneCont.text.isNotEmpty),
                Text(anotherDeliver4PhoneCont.text, style: secondaryTextStyle())
                    .visible(anotherDeliver4PhoneCont.text.isNotEmpty),
              ],
            ),
          ),
        ],
        if (anotherDeliverAddress5Cont.text.isNotEmpty) ...[
          16.height,
          Text("Delivery Location 5", style: boldTextStyle()),
          8.height,
          Container(
            width: context.width(),
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(defaultRadius),
              border: Border.all(
                  color: borderColor, width: appStore.isDarkMode ? 0.2 : 1),
              backgroundColor: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anotherDeliverAddress5Cont.text,
                    style: primaryTextStyle()),
                8.height.visible(anotherDeliver5PhoneCont.text.isNotEmpty),
                Text(anotherDeliver5PhoneCont.text, style: secondaryTextStyle())
                    .visible(anotherDeliver5PhoneCont.text.isNotEmpty),
              ],
            ),
          ),
        ],
        Divider(height: 30),
        OrderSummeryWidget(
          extraChargesList: extraChargeList,
          totalDistance: totalDistance,
          totalWeight: weightController.text.toDouble(),
          distanceCharge: distanceCharge,
          weightCharge: weightCharge,
          totalAmount: totalAmount,
          carryPackagesCharge: isCarry == true ? carryPackagesCharge : 0,
          // onAnotherCharges: paymentCollectFrom != "on_delivery" ? 50 : 0,
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
        16.height,
        Text(language.payment, style: boldTextStyle()),
        16.height,
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: mPaymentList.map((mData) {
            return Container(
              width: 130,
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                  border: Border.all(
                      color: isSelected == mData.index
                          ? colorPrimary
                          : appStore.isDarkMode
                              ? Colors.transparent
                              : borderColor),
                  backgroundColor: context.cardColor),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ImageIcon(AssetImage(mData.image.validate()),
                      size: 20,
                      color: isSelected == mData.index
                          ? colorPrimary
                          : Colors.grey),
                  /*scheduleOptionWidget(context, isCashPayment, 'assets/icons/ic_cash.png', language.cash).onTap(() {
              isCashPayment = true;
              print(isCashPayment);
              setState(() {});
            }).expand(),*/
                  16.width,
                  Text(mData.title!, style: boldTextStyle()).expand(),
                ],
              ),
            ).onTap(() {
              isSelected = mData.index!;
              /*scheduleOptionWidget(context, !isCashPayment, 'assets/icons/ic_credit_card.png', language.online).onTap(() {
              isCashPayment = false;
              print(isCashPayment);*/
              setState(() {});
            });
          }).toList(),
          /*}).expand(),
          ],*/
        ),
        16.height,
        Row(
          children: [
            Text(language.paymentCollectFrom, style: boldTextStyle()),
            16.width,
            DropdownButtonFormField<String>(
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
              onChanged: (value) async {
                paymentCollectFrom = value!;
                print(paymentCollectFrom);
                await getTotalAmount();
                setState(() {});
              },
            ).expand(),
          ],
        ).visible(isSelected == 1),
        //).visible(isCashPayment),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final getProvider = Provider.of<CreditCardProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        if (selectedTabIndex == 0) {
          await showInDialog(
            context,
            contentPadding: EdgeInsets.all(16),
            builder: (p0) {
              return CreateOrderConfirmationDialog(
                onCancel: () {
                  finish(context);
                  pop();
                },
                onSuccess: () {
                  if (delivery == null && vehicle == null) {
                    warningDialog(context, "Invalid",
                        "Please select Vehicle type & Delivery type to save!",
                        neutralButtonText: "OK");
                  } else {
                    finish(context);
                    createOrderApiCall(ORDER_DRAFT);
                  }
                },
                message: language.saveDraftConfirmationMsg,
                primaryText: language.saveDraft,
              );
            },
          );
          return false;
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
      child: Scaffold(
        appBar: AppBar(title: Text(language.createOrder)),
        body: BodyCornerWidget(
          child: Stack(
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
                                  ? colorPrimary
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
                            /*color: selectedTabIndex >= index ? colorPrimary : borderColor,
                            height: 5,
                            width: context.width() * 0.1,*/
                          );
                        }).toList(),
                      ),
                      30.height,
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
                builder: (context) =>
                    loaderWidget().visible(appStore.isLoading),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          color: context.scaffoldBackgroundColor,
          child: Row(
            children: [
              if (selectedTabIndex != 0)
                outlineButton(language.previous, () {
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
                }).paddingRight(16).expand(),
              commonButton(
                  selectedTabIndex != 7 ? language.next : language.createOrder,
                  () async {
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
                      difference =
                          pickFromDateTime!.difference(deliverFromDateTime!);
                      differenceCurrentTime =
                          DateTime.now().difference(pickFromDateTime!);
                    }
                    // iamrafeh
                    if (differenceCurrentTime.inMinutes > 0)
                      return toast(language.pickupCurrentValidationMsg);
                    if (difference.inMinutes > 0)
                      return toast(language.pickupDeliverValidationMsg);
                    if (selectedTabIndex == 2) {
                      var distance = await calculateDistance(
                          pickLat.toDouble(),
                          pickLong.toDouble(),
                          deliverLat.toDouble(),
                          deliverLong.toDouble());
                      if (distance < cityData!.minDistance!) {
                        errorDialog(context, "Warning",
                            "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                            neutralButtonText: "OK");
                      } else {
                        selectedTabIndex = 7;
                      }
                    } else if (selectedTabIndex == 3) {
                      var distance = await calculateDistance(
                          pickLat.toDouble(),
                          pickLong.toDouble(),
                          anotherDeliver2Lat.toDouble(),
                          anotherDeliver2Long.toDouble());
                      if (distance < cityData!.minDistance!) {
                        errorDialog(context, "Warning",
                            "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                            neutralButtonText: "OK");
                      } else {
                        selectedTabIndex = 7;
                      }
                    } else if (selectedTabIndex == 4) {
                      var distance = await calculateDistance(
                          pickLat.toDouble(),
                          pickLong.toDouble(),
                          anotherDeliver3Lat.toDouble(),
                          anotherDeliver3Long.toDouble());
                      if (distance < cityData!.minDistance!) {
                        errorDialog(context, "Warning",
                            "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                            neutralButtonText: "OK");
                        ;
                      } else {
                        selectedTabIndex = 7;
                      }
                    } else if (selectedTabIndex == 5) {
                      var distance = await calculateDistance(
                          pickLat.toDouble(),
                          pickLong.toDouble(),
                          anotherDeliver4Lat.toDouble(),
                          anotherDeliver4Long.toDouble());
                      if (distance < cityData!.minDistance!) {
                        errorDialog(context, "Warning",
                            "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                            neutralButtonText: "OK");
                      } else {
                        selectedTabIndex = 7;
                      }
                    } else if (selectedTabIndex == 6) {
                      var distance = await calculateDistance(
                          pickLat.toDouble(),
                          pickLong.toDouble(),
                          anotherDeliver5Lat.toDouble(),
                          anotherDeliver5Long.toDouble());
                      if (distance < cityData!.minDistance!) {
                        errorDialog(context, "Warning",
                            "Delivery Address should be greater than ${cityData!.minDistance!}, for delivery criteria!",
                            neutralButtonText: "OK");
                      } else {
                        selectedTabIndex = 7;
                      }
                    } else {
                      selectedTabIndex++;
                    }
                    //if (selectedTabIndex == 7) {
                    await getTotalAmount();
                    //}
                    setState(() {});
                  }
                } else {
                  print("isCashPayment $isCashPayment");
                  if (isCashPayment == true) {
                    showConfirmDialog(
                      context,
                      language.createOrderConfirmationMsg,
                      positiveText: language.yes,
                      negativeText: language.no,
                      onAccept: () {
                        createOrderApiCall(ORDER_CREATED);
                      },
                    );
                  } else {
                    print("--");
                    appStore.setLoading(true);
                    Provider.of<CreditCardProvider>(context, listen: false)
                        .getCreditCard(
                      getIntAsync(USER_ID),
                    )
                        .then((value) {
                      if (getProvider.creditCard.length > 0) {
                        appStore.setLoading(false);
                        showConfirmDialog(
                          context,
                          language.createOrderConfirmationMsg,
                          positiveText: language.yes,
                          negativeText: language.no,
                          onAccept: () {
                            createOrderApiCall(ORDER_CREATED);
                          },
                        );
                      } else {
                        appStore.setLoading(false);
                        warningDialog(context, 'Alert',
                            'For online order you\'ve to add credit card!',
                            hideNeutralButton: true,
                            positiveButtonText: "OK", positiveButtonAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => AddCreditCardScreen(
                                  id: ''.toInt(),
                                  cardNumber: "",
                                  expiryDate: "",
                                  ccvCode: "",
                                  cardHolderName: "",
                                  isEdit: false,
                                  isFromCreateOrder: 1),
                            ),
                          ).then((value) {
                            isCashPayment = false;
                            setState(() {});
                          });
                        }, closeOnBackPress: false);
                      }
                    });
                  }
                }
              }).expand(),
              if (selectedTabIndex == 7)
                outlineButton("Edit Address", () {
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
                }).paddingLeft(16).expand(),
            ],
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
