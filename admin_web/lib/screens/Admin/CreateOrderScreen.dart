import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/Admin/CreateOrderConfirmationDialog.dart';
import '../../models/AppSettingModel.dart';
import '../../models/VehicleListModel.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../models/AutoCompletePlacesListModel.dart';
import '../../models/CountryListModel.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../main.dart';
import '../../models/CityListModel.dart';
import '../../models/ExtraChargeRequestModel.dart';
import '../../models/ParcelTypeListModel.dart';
import '../../models/PlaceIdDetailModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';
import 'OrderScreen.dart';
import '../../models/CityDetailModel.dart';

class CreateOrderScreen extends StatefulWidget {
  static String route = '/admin/createorder';

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isDeliverNow = true;
  String paymentCollectFrom = PAYMENT_ON_PICKUP;
  bool isBike = true;
  String vehicle = 'Bike';
  String? delivery;
  String? delivery1;
  var showohiddenoption = 0;
// String delivery='';
// String delivery1='';
  List<ParcelTypeData> parcelTypeList = [];
  AppSettingModel? appSettingModel;
  TextEditingController parcelTypeCont = TextEditingController();
  TextEditingController weightController = TextEditingController(text: '1');
  TextEditingController totalParcelController =
      TextEditingController(text: '1');
  TextEditingController pickAddressCont = TextEditingController();
  TextEditingController pickPhoneCont = TextEditingController();
  TextEditingController pickDesCont = TextEditingController();
  TextEditingController pickDateController = TextEditingController();
  TextEditingController pickFromTimeController = TextEditingController();
  TextEditingController pickToTimeController = TextEditingController();
  TextEditingController deliverAddressCont = TextEditingController();
  TextEditingController deliverPhoneCont = TextEditingController();
  TextEditingController deliverDesCont = TextEditingController();
  TextEditingController deliverDateController = TextEditingController();
  TextEditingController deliverFromTimeController = TextEditingController();
  TextEditingController deliverToTimeController = TextEditingController();
  String? selectedOption;
  String deliverCountryCode = defaultPhoneCode;
  String pickupCountryCode = defaultPhoneCode;

  DateTime? pickFromDateTime,
      pickToDateTime,
      deliverFromDateTime,
      deliverToDateTime;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String? pickLat, pickLong, deliverLat, deliverLong;

  num totalDistance = 0;
  num totalAmount = 0;

  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;

  List<ExtraChargeRequestModel> extraChargeList = [];

  int? selectedCountry;
  int? selectedCity;

  int? selectedVehicle;

  CityData? cityData;

  List<CountryData> countryList = [];
  List<CityData> cityList = [];

  VehicleData? vehicleData;

  List<VehicleData> vehicleList = [];

  List<Predictions> pickPredictionList = [];
  List<Predictions> deliverPredictionList = [];

  String? pickMsg, deliverMsg;
  bool isCarry = false;
  num? carryPackagesCharge;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.isShowVehicle = 0;
    appStore.setSelectedMenuIndex(CREATE_ORDER_INDEX);
    await getAppSettingApiCall();
    await getVehicleApiCall();
    await getParcelTypeListApiCall();
    await getCountryApiCall();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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

  getCountryApiCall() async {
    appStore.setLoading(true);
    await getCountryList().then((value) {
      appStore.setLoading(false);
      countryList = value.data!;
      //selectedCountry = countryList[0].id!;
      setState(() {

      });
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  // getCityApiCall() async {
  //   appStore.setLoading(true);
  //   await getCityList(
  //           countryId: selectedCountry!,
  //           vehicle_type: vehicle,
  //           order_type: isBike ? delivery : delivery1)
  //       .then((value) {
  //     appStore.setLoading(false);
  //     cityList.clear();
  //     cityList.addAll(value.data!);
  //     selectedCity = cityList[0].id!;
  //     cityData = cityList[0];
  //     setState(() {});
  //   }).catchError((error) {
  //     appStore.setLoading(false);
  //     log(error);
  //   });
  // }
  //##########################3

// ...

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
          setState(() {
            showohiddenoption = 1;
            getVehicleApiCall();
            //print("Awais");
          });
        } else {
          setState(() {
            showohiddenoption = 0;
            //appStore.isShowVehicle =0;
          });
          Fluttertoast.showToast(
            msg: "No Data available Select another Options",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM_LEFT,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      });
    } catch (error) {
      appStore.setLoading(false);
      print(error);
      // Handle error case
    }
  }

  //##############################3

  getCityDetailApiCall() async {
    await getCityDetail(selectedCity ?? 0).then((value) async {
      cityData = value;
      if (double.tryParse(weightController.text)! < value!.minWeight!) {
        weightController.text = cityData!.minWeight.toString();
      }
      setState(() {
        //print(cityData?.id);
      });
    }).catchError((error) {});
  }

  String getCountryCode() {
    String countryCode = countryList[0].code!;
    countryList.forEach((element) {
      if (element.id == selectedCountry) {
        countryCode = element.code!;
      }
    });
    return countryCode;
  }

  getAppSettingApiCall() async {
    await getAppSetting().then((value) {
      carryPackagesCharge = num.parse(value.carryPackagesCharge! != null
          ? value.carryPackagesCharge!
          : '0');
      print("------------>carryPackagesCharge $carryPackagesCharge");
      // appStore.setCurrencyCode(value.currencyCode ?? currencyCodeDefault);
      print(value);
    }).catchError((error) {
      log(error.toString());
    });
  }
// vical list
  getVehicleApiCall({String? name}) async {
    appStore.setLoading(true);
    await getVehicleList(cityID: selectedCity).then((value) {
      appStore.setLoading(false);
      vehicleList.clear();
      vehicleList = value.data!;
      if (vehicleList.isNotEmpty) selectedVehicle = vehicleList[0].id!;
      setState(() {
        print("awais");
      });
      if(vehicleList.isEmpty) showohiddenoption = 0;
    }).catchError((error) {
      appStore.setLoading(false);
     // appStore.isShowVehicle = 0;
      //showohiddenoption = 0;
      log(error);
    });
  }

  getTotalAmount() {
    totalDistance = calculateDistance(
        double.tryParse(pickLat!),
        double.tryParse(pickLong!),
        double.tryParse(deliverLat!),
        double.tryParse(deliverLong!));
    totalAmount = 0;
    weightCharge = 0;
    distanceCharge = 0;
    totalExtraCharge = 0;

    /// calculate weight Charge
    if (double.tryParse(weightController.text)! >= cityData!.minWeight!) {
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
    num? totalCarryPackagesCharge = isCarry == true ? carryPackagesCharge : 0;
    print("totalCarryPackagesCharge $totalCarryPackagesCharge");

    /// All Charges
    totalAmount = double.parse(
        (totalAmount + totalExtraCharge + totalCarryPackagesCharge!)
            .toStringAsFixed(digitAfterDecimal));
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

  createOrderApiCall(String orderStatus) async {
    Map req = {
      "id": "",
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": selectedCountry.toString(),
      "city_id": selectedCity.toString(),
      if (appStore.isShowVehicle == 1) "vehicle_id": selectedVehicle.toString(),
      "courier_will_carry": isCarry,
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
        }
      ],
      "selected_delivery_point": {
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
        "contact_number": '$deliverCountryCode ${deliverPhoneCont.text.trim()}',
      },
      "extra_charges": extraChargeList,
      "parcel_type": parcelTypeCont.text,
      "total_weight": double.tryParse(weightController.text),
      "total_distance": totalDistance.toStringAsFixed(digitAfterDecimal),
      "payment_collect_from": paymentCollectFrom,
      "status": orderStatus,
      "payment_type": PAYMENT_TYPE_CASH,
      "payment_status": "",
      "fixed_charges": cityData!.fixedCharges.toString(),
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
      Navigator.pushNamed(context, OrderScreen.route);
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
            countryCode: getCountryCode())
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
  Widget build(BuildContext context) {
    Widget pickTimeWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.pick_time, style: boldTextStyle()),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
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
                          if (value!.isEmpty) return errorThisFieldRequired;
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
                          if (value!.isEmpty) return errorThisFieldRequired;
                          double fromTimeInHour =
                              pickFromTime!.hour + pickFromTime!.minute / 60;
                          double toTimeInHour =
                              pickToTime!.hour + pickToTime!.minute / 60;
                          double difference = toTimeInHour - fromTimeInHour;
                          if (difference <= 0) {
                            return language.end_start_time_validation_msg;
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
        ],
      );
    }

    Widget deliverTimeWidget() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.deliver_time, style: boldTextStyle()),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
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
                          if (value!.isEmpty) return errorThisFieldRequired;
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
                          if (value!.isEmpty) return errorThisFieldRequired;
                          double fromTimeInHour = deliverFromTime!.hour +
                              deliverFromTime!.minute / 60;
                          double toTimeInHour =
                              deliverToTime!.hour + deliverToTime!.minute / 60;
                          double difference = toTimeInHour - fromTimeInHour;
                          if (difference < 0) {
                            return language.end_start_time_validation_msg;
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
        ],
      );
    }

    Widget saveOrderButton() {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(defaultRadius)),
          child: Text(language.save, style: boldTextStyle(color: Colors.white)),
        ),
        onTap: () async {
          pickMsg = '';
          deliverMsg = '';
          setState(() {});
          if (_formKey.currentState!.validate()) {
            Duration difference = Duration();
            Duration differenceCurrentTime = Duration();
            if (!isDeliverNow) {
              pickFromDateTime = pickDate!.add(Duration(
                  hours: pickFromTime!.hour, minutes: pickFromTime!.minute));
              pickToDateTime = pickDate!.add(Duration(
                  hours: pickToTime!.hour, minutes: pickToTime!.minute));
              deliverFromDateTime = deliverDate!.add(Duration(
                  hours: deliverFromTime!.hour,
                  minutes: deliverFromTime!.minute));
              deliverToDateTime = deliverDate!.add(Duration(
                  hours: deliverToTime!.hour, minutes: deliverToTime!.minute));
              difference = pickFromDateTime!.difference(deliverFromDateTime!);
              differenceCurrentTime =
                  DateTime.now().difference(pickFromDateTime!);
            }
            if (differenceCurrentTime.inMinutes > 0)
              return toast(language.pickup_current_validation_msg);
            if (difference.inMinutes > 0)
              return toast(language.pickup_deliver_validation_msg);
            extraChargesList();
            getTotalAmount();
            showDialog(
                context: context,
                builder: (context) => CreateOrderConfirmationDialog(
                    extraChargesList: extraChargeList,
                    totalDistance: totalDistance,
                    totalWeight: double.parse(weightController.text),
                    distanceCharge: distanceCharge,
                    weightCharge: weightCharge,
                    totalAmount: totalAmount,
                    onAccept: () async {
                      await createOrderApiCall(ORDER_CREATED);
                    },
                    carryPackagesCharge:
                        isCarry == true ? carryPackagesCharge! : 0));
          }
        },
      );
    }

    return BodyCornerWidget(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 100),
            controller: ScrollController(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveWidget.isSmallScreen(context) &&
                          appStore.isMenuExpanded
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(language.crete_order,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            saveOrderButton(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.crete_order,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            saveOrderButton(),
                          ],
                        ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      scheduleOptionWidget(
                          context: context,
                          isSelected: isDeliverNow,
                          imagePath: 'assets/icons/ic_clock.png',
                          title: language.deliver_now,
                          onTap: () {
                            isDeliverNow = true;
                            setState(() {});
                          }),
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
                  SizedBox(
                    height: 8,
                  ),
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
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: vehicle,
                              dropdownColor: Theme.of(context).cardColor,
                              style: primaryTextStyle(),
                              decoration: commonInputDecoration(),
                              items: [
                                DropdownMenuItem(
                                    value: language.bike,
                                    child: Text(language.bike,
                                        style: primaryTextStyle(),
                                        maxLines: 1)),
                                DropdownMenuItem(
                                    value: language.car,
                                    child: Text(language.car,
                                        style: primaryTextStyle(),
                                        maxLines: 1)),
                              ],
                              onChanged: (value) {
                                vehicle = value!;
                                getCountryApiCall();
                                print("vehicle is selected $vehicle");
                                setState(() {
                                  selectedCity = null;

                                  // getCountryApiCall();
                                  cityList.clear();
                                  if (vehicle == "Bike") {
                                    isBike = true;
                                    //showohiddenoption = 0;
                                    appStore.isShowVehicle = 0;
                                    // delivery = "In-Day Delivery";
                                  } else {
                                    isBike = false;
                                    //showohiddenoption = 1;
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child:
                                      //                              DropdownButtonFormField<String>(
                                      //                                 value: delivery,
                                      //                                   decoration: InputDecoration(
                                      //                                    border: OutlineInputBorder(),
                                      //                                        filled: true,
                                      //                                          fillColor: Colors.grey[200],
                                      //                                         ),
                                      //                                        items: [
                                      //                                           DropdownMenuItem<String>(
                                      //                              value: language.in_day,
                                      //                                  child: Text(
                                      //                                            language.in_day,
                                      //                                            style: primaryTextStyle(),
                                      //                                            maxLines: 1,
                                      //                                          ),
                                      //                                          ),
                                      //                                        DropdownMenuItem<String>(
                                      //                                            value: 'Option 2',
                                      //                                            child: Text(
                                      //                                                      language.express,
                                      //                                                      style: primaryTextStyle(),
                                      //                                                      maxLines: 1,
                                      //                                                    ),
                                      //                                        ),
                                      //                                        DropdownMenuItem<String>(
                                      //                                          value: 'Option 3',
                                      //                                            child: Text(
                                      //                                                      language.vip,
                                      //                                                      style: primaryTextStyle(),
                                      //                                                      maxLines: 1,
                                      //                                                    ),
                                      //                      ),
                                      // ],
                                      //                                  onChanged: (value) {
                                      //                         setState(() {
                                      //                                 delivery = value!;
                                      //                                 getCityApiCall();
                                      //   });
                                      // }

                                      DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: delivery,
                                    dropdownColor: Theme.of(context).cardColor,
                                    style: primaryTextStyle(),
                                    decoration: commonInputDecoration(),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: language.in_day,
                                        child: Text(
                                          language.in_day,
                                          style: primaryTextStyle(),
                                          maxLines: 1,
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: language.express,
                                        child: Text(
                                          language.express,
                                          style: primaryTextStyle(),
                                          maxLines: 1,
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: language.vip,
                                        child: Text(
                                          language.vip,
                                          style: primaryTextStyle(),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != delivery) {
                                        setState(() {
                                          selectedCity = null;
                                          cityList.clear();
                                          delivery = value!;
                                        });
                                        print("here is valueeeeee$delivery");

                                        getCityApiCall();
                                      }
                                    },
                                  ),

                                  // DropdownButtonFormField<String>(
                                  //   isExpanded: true,
                                  //   value: delivery,
                                  //   dropdownColor: Theme.of(context).cardColor,
                                  //   style: primaryTextStyle(),
                                  //   decoration: commonInputDecoration(),
                                  //   items: [
                                  //     DropdownMenuItem<String>(
                                  //       value: "in_day",
                                  //       child: Text(
                                  //         language.in_day,
                                  //         style: primaryTextStyle(),
                                  //         maxLines: 1,
                                  //       ),
                                  //     ),
                                  //     DropdownMenuItem<String>(
                                  //       value: language.express,
                                  //       child: Text(
                                  //         language.express,
                                  //         style: primaryTextStyle(),
                                  //         maxLines: 1,
                                  //       ),
                                  //     ),
                                  //     DropdownMenuItem<String>(
                                  //       value: language.vip,
                                  //       child: Text(
                                  //         language.vip,
                                  //         style: primaryTextStyle(),
                                  //         maxLines: 1,
                                  //       ),
                                  //     ),
                                  //   ],onChanged: (value) {
                                  //   value==delivery ?
                                  //   ScaffoldMessenger.of(context).showSnackBar(
                                  //     SnackBar(
                                  //       content: Text('Value is already selected.'),
                                  //     ),
                                  //   ):delivery = value!;
                                  //   getCityApiCall();
                                  //   print("delivery value is here $value");
                                  //   setState(() {});
                                  //   // setState(() {
                                  //   //   delivery='';
                                  //   //   delivery = value!;
                                  //   //   getCityApiCall();
                                  //   //   print("delivery value is here $value");
                                  //   // }):
                                  //
                                  // },
                                  //   // onChanged: (value) {
                                  //   //   if (value == delivery) {
                                  //   //     print("delivery value is here $delivery");
                                  //   //     ScaffoldMessenger.of(context).showSnackBar(
                                  //   //       SnackBar(
                                  //   //         content: Text('Value is already selected.'),
                                  //   //       ),
                                  //   //     );
                                  //   //   } else {
                                  //   //     print("delivery value is here $delivery");
                                  //   //     delivery = value!;
                                  //   //     getCityApiCall();
                                  //   //     setState(() {});
                                  //   //   }
                                  //   // },
                                  //   // validator: (value) {
                                  //   //   if (value == null) {
                                  //   //     return 'Please select a value.';
                                  //   //   }
                                  //   //   return null;
                                  //   // },
                                  // ),
                                )
                              : SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: delivery1,
                                    dropdownColor: Theme.of(context).cardColor,
                                    style: primaryTextStyle(),
                                    decoration: commonInputDecoration(),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: language.express,
                                        child: Text(
                                          language.express,
                                          style: primaryTextStyle(),
                                          maxLines: 1,
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: language.vip,
                                        child: Text(
                                          language.vip,
                                          style: primaryTextStyle(),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != delivery1) {
                                        setState(() {
                                          selectedCity = null;
                                          cityList.clear();
                                          delivery1 = value!;
                                        });
                                        print("here is valueeeeee$delivery1");

                                        getCityApiCall();
                                      }
                                    },
                                    // onChanged: (value) {
                                    //   if (value == delivery) {
                                    //     print("delivery value is here $delivery");
                                    //     ScaffoldMessenger.of(context).showSnackBar(
                                    //       SnackBar(
                                    //         content: Text('Value is already selected.'),
                                    //       ),
                                    //     );
                                    //   } else {
                                    //     print("delivery value is here $delivery");
                                    //     delivery = value!;
                                    //     getCityApiCall();
                                    //     setState(() {});
                                    //   }
                                    // },
                                    // validator: (value) {
                                    //   if (value == null) {
                                    //     return 'Please select a value.';
                                    //   }
                                    //   return null;
                                    // },
                                  ),
                                  // onChanged: (value) {
                                  //   if (value == delivery1) {
                                  //     print("delivery value is here____ $delivery1");
                                  //
                                  //     ScaffoldMessenger.of(context)
                                  //         .showSnackBar(
                                  //       SnackBar(content: Text(
                                  //           'Value is already selected.'),
                                  //       ),
                                  //     );
                                  //   } else {
                                  //     print("delivery value is here____ $delivery1");
                                  //     delivery1 = value!;
                                  //     getCityApiCall();
                                  //     setState(() {});
                                  //   }
                                  //
                                  // } ),
                                ),

                          //                       SizedBox(
                          //                         width: MediaQuery.of(context).size.width * 0.25,
                          //                         child: DropdownButtonFormField<String>(
                          //                           isExpanded: true,
                          //                           value: delivery,
                          //                           dropdownColor: Theme.of(context).cardColor,
                          //                           style: primaryTextStyle(),
                          //                           decoration: commonInputDecoration(),
                          //                           items: [
                          //                             DropdownMenuItem<String>(
                          //                               value: language.in_day,
                          //                               child: Text(language.in_day,
                          //                                   style: primaryTextStyle(),
                          //                                   maxLines: 1),
                          //                             ),
                          //                             DropdownMenuItem<String>(
                          //                               value: language.express,
                          //                               child: Text(language.express,
                          //                                   style: primaryTextStyle(),
                          //                                   maxLines: 1),
                          //                             ),
                          //                             DropdownMenuItem<String>(
                          //                               value: language.vip,
                          //                               child: Text(language.vip,
                          //                                   style: primaryTextStyle(),
                          //                                   maxLines: 1),
                          //                             ),
                          //                           ],
                          // onChanged: (value) {
                          // if (value == delivery) {
                          // ScaffoldMessenger.of(context)
                          //     .showSnackBar(
                          // SnackBar(content: Text(
                          // 'Value is already selected.'),
                          // ),
                          // );
                          // } else {
                          // delivery = value!;
                          // getCityApiCall();
                          // setState(() {});
                          // }}
                          //                           // onChanged: (value) {
                          //                           //   setState(() {
                          //                           //     delivery = value!;
                          //                           //     // selectedCity = null;
                          //                           //     getCityApiCall();
                          //                           //   });
                          //                           // },
                          //                         ),
                          //                       )

                          // ? SizedBox(
                          //     width:
                          //         MediaQuery.of(context).size.width * 0.25,
                          //     child: DropdownButtonFormField<String>(
                          //       isExpanded: true,
                          //       value: delivery,
                          //       dropdownColor: Theme.of(context).cardColor,
                          //       style: primaryTextStyle(),
                          //       decoration: commonInputDecoration(),
                          //       items: [
                          //         DropdownMenuItem(
                          //             value: language.in_day,
                          //             child: Text(language.in_day,
                          //                 style: primaryTextStyle(),
                          //                 maxLines: 1)),
                          //         DropdownMenuItem(
                          //             value: language.express,
                          //             child: Text(language.express,
                          //                 style: primaryTextStyle(),
                          //                 maxLines: 1)),
                          //         DropdownMenuItem(
                          //             value: language.vip,
                          //             child: Text(language.vip,
                          //                 style: primaryTextStyle(),
                          //                 maxLines: 1)),
                          //       ],
                          //       onChanged: (value) {
                          //         delivery = value!;
                          //       //  selectedCity = null;
                          //         getCityApiCall();
                          //         setState(() {});
                          //       },
                          //     ),
                          //   )
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  if (!isDeliverNow)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: ResponsiveWidget.isSmallScreen(context)
                          ? Column(
                              children: [
                                pickTimeWidget(),
                                SizedBox(height: 16),
                                deliverTimeWidget(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: pickTimeWidget()),
                                SizedBox(width: 16),
                                Expanded(child: deliverTimeWidget())
                              ],
                            ),
                    ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.country, style: boldTextStyle()),
                            SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: selectedCountry,
                              decoration: commonInputDecoration(),
                              dropdownColor: Theme.of(context).cardColor,
                              style: primaryTextStyle(),
                              items: countryList
                                  .map<DropdownMenuItem<int>>((item) {
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
                              validator: (value) {
                                if (selectedCountry == null) {
                                  return errorThisFieldRequired;
                                }
                                return null;
                              },
                            ),

                            // DropdownButtonFormField<int>(
                            //   value: selectedCountry,
                            //   decoration: commonInputDecoration(),
                            //   dropdownColor: Theme.of(context).cardColor,
                            //   style: primaryTextStyle(),
                            //   items: countryList
                            //       .map<DropdownMenuItem<int>>((item) {
                            //     return DropdownMenuItem(
                            //       value: item.id,
                            //       child: Text(item.name ?? ''),
                            //     );
                            //   }).toList(),
                            //   onChanged: (value) {
                            //     selectedCountry = value!;
                            //     selectedCity = null;
                            //     cityData = null;
                            //     pickAddressCont.clear();
                            //     pickLat = null;
                            //     pickLong = null;
                            //     deliverAddressCont.clear();
                            //     deliverLat = null;
                            //     deliverLong = null;
                            //     pickPredictionList = [];
                            //     deliverPredictionList = [];
                            //     // getCityApiCall();
                            //     setState(() {});
                            //   },
                            //   validator: (value) {
                            //     if (selectedCountry == null)
                            //       return errorThisFieldRequired;
                            //     return null;
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.city, style: boldTextStyle()),
                          SizedBox(height: 8),
                          DropdownButtonFormField<int>(
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
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value!;

                                getCityDetailApiCall();
                                getVehicleApiCall();
                                setState(() {
                                  weightController.text =
                                      cityData!.minWeight.toString();
                                });
                              });
                            },
                            validator: (value) {
                              if (selectedCity == null) {
                                return errorThisFieldRequired;
                              }
                              return null;
                            },
                          ),

                          // DropdownButtonFormField<int>(
                          //   value: selectedCity,
                          //   decoration: commonInputDecoration(),
                          //   dropdownColor: Theme.of(context).cardColor,
                          //   style: primaryTextStyle(),
                          //   items: cityList.map<DropdownMenuItem<int>>((item) {
                          //     return DropdownMenuItem(
                          //       value: item.id,
                          //       child: Text(item.name ?? ''),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     selectedCity = value!;
                          //     getCityDetailApiCall();
                          //
                          //     setState(() {
                          //       weightController.text =
                          //           cityData!.minWeight.toString();
                          //     });
                          //   },
                          //   validator: (value) {
                          //     if (selectedCity == null)
                          //       return errorThisFieldRequired;
                          //     return null;
                          //   },
                          // ),
                        ],
                      )),
                      SizedBox(width: 16),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Container(
                        width: ResponsiveWidget.isSmallScreen(context)
                            ? MediaQuery.of(context).size.width
                            : MediaQuery.of(context).size.width * 0.30,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(defaultRadius)),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(language.weight,
                                      style: primaryTextStyle()),
                                ),
                              ),
                              VerticalDivider(thickness: 1),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(Icons.remove,
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                                onTap: () {
                                  if (double.parse(weightController.text) > 1) {
                                    weightController.text =
                                        (double.parse(weightController.text) -
                                                1)
                                            .toString();
                                  }
                                  if (double.tryParse(weightController.text)! <
                                      cityData!.minWeight!) {
                                    weightController.text =
                                        cityData!.minWeight.toString();
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
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: primaryColor)),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              VerticalDivider(thickness: 1),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Icon(Icons.add,
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                                onTap: () {
                                  weightController.text =
                                      (double.parse(weightController.text) + 1)
                                          .toString();
                                  if (double.tryParse(weightController.text)! >
                                      cityData!.maxWeight!) {
                                    weightController.text =
                                        cityData!.maxWeight.toString();
                                    showAlertDialog(context);
                                  }
                                  if (double.tryParse(weightController.text)! <
                                      cityData!.minWeight!) {
                                    weightController.text =
                                        cityData!.minWeight.toString();
                                    // showAlertDialog2(context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: ResponsiveWidget.isSmallScreen(context)
                            ? MediaQuery.of(context).size.width
                            : MediaQuery.of(context).size.width * 0.30,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(defaultRadius)),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(language.number_of_parcels,
                                      style: primaryTextStyle()),
                                ),
                              ),
                              VerticalDivider(thickness: 1),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(Icons.remove,
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                                onTap: () {
                                  if (int.parse(totalParcelController.text) >
                                      1) {
                                    totalParcelController.text =
                                        (int.parse(totalParcelController.text) -
                                                1)
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
                                        borderSide:
                                            BorderSide(color: primaryColor)),
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
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                                onTap: () {
                                  totalParcelController.text =
                                      (int.parse(totalParcelController.text) +
                                              1)
                                          .toString();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(language.parcel_type, style: boldTextStyle()),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: AppTextField(
                          controller: parcelTypeCont,
                          textFieldType: TextFieldType.OTHER,
                          decoration: commonInputDecoration(),
                          validator: (value) {
                            if (value!.isEmpty) return errorThisFieldRequired;
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 30.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: SwitchListTile(
                          value: isCarry,
                          onChanged: (value) {
                            isCarry = value;
                            print(isCarry);
                            setState(() {});
                          },
                          title: Text("Courier will carry packages",
                              style: primaryTextStyle()),
                          controlAffinity: ListTileControlAffinity.trailing,
                          inactiveTrackColor: appStore.isDarkMode
                              ? Colors.white12
                              : Colors.black12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: parcelTypeList.map((item) {
                      return GestureDetector(
                        child: Chip(
                          backgroundColor: Theme.of(context).cardColor,
                          label: Text(item.label!),
                          elevation: 0,
                          labelStyle: primaryTextStyle(color: Colors.grey),
                          padding: EdgeInsets.zero,
                          labelPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            side: BorderSide(
                                color: Theme.of(context).dividerColor),
                          ),
                        ),
                        onTap: () {
                          parcelTypeCont.text = item.label!;
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  //SizedBox(height: 16),
                  /*Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.country, style: boldTextStyle()),
                            SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              isExpanded: true,
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
                                selectedCountry = value!;
                                selectedCity = null;
                                cityData = null;
                                pickAddressCont.clear();
                                pickLat = null;
                                pickLong = null;
                                deliverAddressCont.clear();
                                deliverLat = null;
                                deliverLong = null;
                                pickPredictionList = [];
                                deliverPredictionList = [];
                                selectedVehicle = null;
                                vehicleList.clear();
                                getCityApiCall();
                                setState(() {});
                              },
                              validator: (value) {
                                if (selectedCountry == null) return errorThisFieldRequired;
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.city, style: boldTextStyle()),
                            SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              isExpanded: true,
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
                              onChanged: (value) {
                                selectedCity = value!;
                                getCityDetailApiCall();
                                getVehicleApiCall();
                                setState(() {});
                              },
                              validator: (value) {
                                if (selectedCity == null) return errorThisFieldRequired;
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      if (!ResponsiveWidget.isSmallScreen(context)) Spacer(),
                    ],
                  ),*/
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: ResponsiveWidget.isSmallScreen(context)
                            ? getBodyWidth(context)
                            : (getBodyWidth(context) - 48) * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.pickup_info, style: boldTextStyle()),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.pickup_location,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  AppTextField(
                                    controller: pickAddressCont,
                                    textInputAction: TextInputAction.next,
                                    textFieldType: TextFieldType.ADDRESS,
                                    decoration: commonInputDecoration(
                                        suffixIcon: Icons.location_on_outlined),
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return errorThisFieldRequired;
                                      if (pickLat == null || pickLong == null)
                                        return language
                                            .pleaseSelectValidAddress;
                                      return null;
                                    },
                                    onChanged: (val) async {
                                      pickMsg = '';
                                      pickLat = null;
                                      pickLong = null;
                                      if (val.isNotEmpty) {
                                        if (val.length < 3) {
                                          pickMsg = language
                                              .selectedAddressValidation;
                                          pickPredictionList.clear();
                                          setState(() {});
                                        } else {
                                          pickPredictionList =
                                              await getPlaceAutoCompleteApiCall(
                                                  val);
                                          setState(() {});
                                        }
                                      } else {
                                        pickPredictionList.clear();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  if (!pickMsg.isEmptyOrNull)
                                    Padding(
                                        padding:
                                            EdgeInsets.only(top: 8, left: 8),
                                        child: Text(
                                          pickMsg.validate(),
                                          style: secondaryTextStyle(
                                              color: Colors.red),
                                        )),
                                  if (pickPredictionList.isNotEmpty)
                                    ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        controller: ScrollController(),
                                        padding: EdgeInsets.only(
                                            top: 16, bottom: 16),
                                        shrinkWrap: true,
                                        itemCount: pickPredictionList.length,
                                        itemBuilder: (context, index) {
                                          Predictions mData =
                                              pickPredictionList[index];
                                          return ListTile(
                                            leading: Icon(Icons.location_pin,
                                                color: primaryColor),
                                            title:
                                                Text(mData.description ?? ""),
                                            onTap: () async {
                                              PlaceIdDetailModel? response =
                                                  await getPlaceIdDetailApiCall(
                                                      placeId: mData.placeId!);
                                              if (response != null) {
                                                pickAddressCont.text =
                                                    mData.description ?? "";
                                                pickLat = response.result!
                                                    .geometry!.location!.lat
                                                    .toString();
                                                pickLong = response.result!
                                                    .geometry!.location!.lng
                                                    .toString();
                                                pickPredictionList.clear();
                                                setState(() {});
                                              }
                                            },
                                          );
                                        }),
                                  SizedBox(height: 16),
                                  Text(language.pickup_contact_number,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  AppTextField(
                                    controller: pickPhoneCont,
                                    textInputAction: TextInputAction.next,
                                    textFieldType: TextFieldType.PHONE,
                                    decoration: commonInputDecoration(
                                        suffixIcon: Icons.phone,
                                        prefixIcon: IntrinsicHeight(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CountryCodePicker(
                                                initialSelection:
                                                    pickupCountryCode,
                                                showCountryOnly: false,
                                                showFlag: true,
                                                showFlagDialog: true,
                                                showOnlyCountryWhenClosed:
                                                    false,
                                                alignLeft: false,
                                                textStyle: primaryTextStyle(),
                                                dialogBackgroundColor:
                                                    Theme.of(context).cardColor,
                                                barrierColor: Colors.black12,
                                                dialogTextStyle:
                                                    primaryTextStyle(),
                                                searchDecoration:
                                                    InputDecoration(
                                                  iconColor: Theme.of(context)
                                                      .dividerColor,
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor)),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  primaryColor)),
                                                ),
                                                searchStyle: primaryTextStyle(),
                                                onInit: (c) {
                                                  pickupCountryCode =
                                                      c!.dialCode!;
                                                },
                                                onChanged: (c) {
                                                  pickupCountryCode =
                                                      c.dialCode!;
                                                },
                                              ),
                                              VerticalDivider(
                                                  color: Colors.grey
                                                      .withOpacity(0.5)),
                                            ],
                                          ),
                                        )),
                                    validator: (value) {
                                      if (value!.trim().isEmpty)
                                        return errorThisFieldRequired;
                                      if (value.trim().length <
                                              minContactLength ||
                                          value.trim().length >
                                              maxContactLength)
                                        return language
                                            .contact_length_validation;
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(language.pickup_description,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: pickDesCont,
                                    decoration: commonInputDecoration(
                                        suffixIcon: Icons.notes),
                                    textInputAction: TextInputAction.newline,
                                    maxLines: 3,
                                    minLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveWidget.isSmallScreen(context)
                            ? getBodyWidth(context)
                            : (getBodyWidth(context) - 48) * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.delivery_information,
                                style: boldTextStyle()),
                            SizedBox(height: 8),
                            Container(

                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(language.delivery_location,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  AppTextField(
                                    controller: deliverAddressCont,
                                    textInputAction: TextInputAction.next,
                                    textFieldType: TextFieldType.ADDRESS,
                                    decoration: commonInputDecoration(
                                        suffixIcon: Icons.location_on_outlined),
                                    validator: (value) {
                                      if (value!.isEmpty)
                                        return errorThisFieldRequired;
                                      if (deliverLat == null ||
                                          deliverLong == null)
                                        return language
                                            .pleaseSelectValidAddress;
                                      return null;
                                    },
                                    onChanged: (val) async {
                                      deliverMsg = '';
                                      deliverLat = null;
                                      deliverLong = null;
                                      if (val.isNotEmpty) {
                                        if (val.length < 3) {
                                          deliverMsg = language
                                              .selectedAddressValidation;
                                          deliverPredictionList.clear();
                                          setState(() {});
                                        } else {
                                          deliverPredictionList =
                                              await getPlaceAutoCompleteApiCall(
                                                  val);
                                          setState(() {});
                                        }
                                      } else {
                                        deliverPredictionList.clear();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  if (!deliverMsg.isEmptyOrNull)
                                    Padding(
                                        padding:
                                            EdgeInsets.only(top: 8, left: 8),
                                        child: Text(
                                          deliverMsg.validate(),
                                          style: secondaryTextStyle(
                                              color: Colors.red),
                                        )),
                                  if (deliverPredictionList.isNotEmpty)
                                    ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: ScrollController(),
                                      padding:
                                          EdgeInsets.only(top: 16, bottom: 16),
                                      shrinkWrap: true,
                                      itemCount: deliverPredictionList.length,
                                      itemBuilder: (context, index) {
                                        Predictions mData =
                                            deliverPredictionList[index];
                                        return ListTile(
                                          leading: Icon(Icons.location_pin,
                                              color: primaryColor),
                                          title: Text(mData.description ?? ""),
                                          onTap: () async {
                                            PlaceIdDetailModel? response =
                                                await getPlaceIdDetailApiCall(
                                                    placeId: mData.placeId!);
                                            if (response != null) {
                                              deliverAddressCont.text =
                                                  mData.description ?? "";
                                              deliverLat = response.result!
                                                  .geometry!.location!.lat
                                                  .toString();
                                              deliverLong = response.result!
                                                  .geometry!.location!.lng
                                                  .toString();
                                              deliverPredictionList.clear();
                                              setState(() {});
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  SizedBox(height: 16),
                                  Text(language.delivery_contact_number,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  AppTextField(
                                    controller: deliverPhoneCont,
                                    textInputAction: TextInputAction.next,
                                    textFieldType: TextFieldType.PHONE,
                                    decoration: commonInputDecoration(
                                      suffixIcon: Icons.phone,
                                      prefixIcon: IntrinsicHeight(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CountryCodePicker(
                                              initialSelection:
                                                  deliverCountryCode,
                                              showCountryOnly: false,
                                              showFlag: true,
                                              showFlagDialog: true,
                                              showOnlyCountryWhenClosed: false,
                                              alignLeft: false,
                                              textStyle: primaryTextStyle(),
                                              dialogBackgroundColor:
                                                  Theme.of(context).cardColor,
                                              barrierColor: Colors.black12,
                                              dialogTextStyle:
                                                  primaryTextStyle(),
                                              searchDecoration: InputDecoration(
                                                iconColor: Theme.of(context)
                                                    .dividerColor,
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .dividerColor)),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                primaryColor)),
                                              ),
                                              searchStyle: primaryTextStyle(),
                                              onInit: (c) {
                                                deliverCountryCode =
                                                    c!.dialCode!;
                                              },
                                              onChanged: (c) {
                                                deliverCountryCode =
                                                    c.dialCode!;
                                              },
                                            ),
                                            VerticalDivider(
                                                color: Colors.grey
                                                    .withOpacity(0.5)),
                                            
                                            
                                          ],
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.trim().isEmpty)
                                        return errorThisFieldRequired;
                                      if (value.trim().length <
                                              minContactLength ||
                                          value.trim().length >
                                              maxContactLength)
                                        return language
                                            .contact_length_validation;
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text(language.delivery_description,
                                      style: primaryTextStyle()),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: deliverDesCont,
                                    decoration: commonInputDecoration(
                                        suffixIcon: Icons.notes),
                                    textInputAction: TextInputAction.newline,
                                    maxLines: 3,
                                    minLines: 3,
                                  ),
                                  
                                ],
                              ),
                            ),
                            //start wroking from here
                       

                            // stop working
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  //start working

                  // new Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: <Widget>[
                  //     new Flexible(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(20.0),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(language.payment_collect_form,
                  //                 style: boldTextStyle()),
                  //             SizedBox(height: 8),
                  //             DropdownButtonFormField<String>(
                  //               isExpanded: true,
                  //               value: paymentCollectFrom,
                  //               dropdownColor: Theme.of(context).cardColor,
                  //               style: primaryTextStyle(),
                  //               decoration: commonInputDecoration(),
                  //               items: [
                  //                 DropdownMenuItem(
                  //                     value: PAYMENT_ON_PICKUP,
                  //                     child: Text(language.pickup_location,
                  //                         style: primaryTextStyle(),
                  //                         maxLines: 1)),
                  //                 DropdownMenuItem(
                  //                     value: PAYMENT_ON_DELIVERY,
                  //                     child: Text(language.delivery_location,
                  //                         style: primaryTextStyle(),
                  //                         maxLines: 1)),
                  //               ],
                  //               onChanged: (value) {
                  //                 paymentCollectFrom = value!;
                  //                 setState(() {});
                  //               },
                  //             ),
                  //           ],
                  //         )
                  //       ),
                  //     ),
                  //     new Flexible(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(20.0),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(language.select_vehicle,
                  //                 style: boldTextStyle()),
                  //             SizedBox(height: 8),
                  //             DropdownButtonFormField<int>(
                  //               isExpanded: true,
                  //               value: selectedVehicle,
                  //               decoration: commonInputDecoration(),
                  //               dropdownColor: Theme.of(context).cardColor,
                  //               style: primaryTextStyle(),
                  //               items: vehicleList
                  //                   .map<DropdownMenuItem<int>>((item) {
                  //                 return DropdownMenuItem(
                  //                   value: item.id,
                  //                   child: Row(
                  //                     children: [
                  //                       commonCachedNetworkImage(
                  //                           item.vehicleImage.validate(),
                  //                           height: 40,
                  //                           width: 40),
                  //                       SizedBox(width: 16),
                  //                       Text(item.title ?? ''),
                  //                     ],
                  //                   ),
                  //                 );
                  //               }).toList(),
                  //               onChanged: (value) {
                  //                 selectedVehicle = value;
                  //                 print(selectedVehicle);
                  //                 setState(() {});
                  //               },
                  //               validator: (value) {
                  //                 if (selectedVehicle == null)
                  //                   return errorThisFieldRequired;
                  //                 return null;
                  //               },
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //
                  //   ],
                  // ),
                  
                  
                  
                  // end working
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.payment_collect_form,
                                style: boldTextStyle()),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: paymentCollectFrom,
                              dropdownColor: Theme.of(context).cardColor,
                              style: primaryTextStyle(),
                              decoration: commonInputDecoration(),
                              items: [
                                DropdownMenuItem(
                                    value: PAYMENT_ON_PICKUP,
                                    child: Text(language.pickup_location,
                                        style: primaryTextStyle(),
                                        maxLines: 1)),
                                DropdownMenuItem(
                                    value: PAYMENT_ON_DELIVERY,
                                    child: Text(language.delivery_location,
                                        style: primaryTextStyle(),
                                        maxLines: 1)),
                              ],
                              onChanged: (value) {
                                paymentCollectFrom = value!;
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      if (appStore.isShowVehicle == 1 && showohiddenoption == 1)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.select_vehicle,
                                  style: boldTextStyle()),
                              SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                value: selectedVehicle,
                                decoration: commonInputDecoration(),
                                dropdownColor: Theme.of(context).cardColor,
                                style: primaryTextStyle(),
                                items: vehicleList
                                    .map<DropdownMenuItem<int>>((item) {
                                  return DropdownMenuItem(
                                    value: item.id,
                                    child: Row(
                                      children: [
                                        commonCachedNetworkImage(
                                            item.vehicleImage.validate(),
                                            height: 40,
                                            width: 40),
                                        SizedBox(width: 16),
                                        Text(item.title ?? ''),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedVehicle = value;
                                  print(selectedVehicle);
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (selectedVehicle == null)
                                    return errorThisFieldRequired;
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                      SizedBox(width: 16),
                      if (!ResponsiveWidget.isSmallScreen(context)) Spacer(),
                    ],
                  ),


                ],
              ),
            ),
          ),
          Observer(builder: (context) {
            return Visibility(
                visible: appStore.isLoading,
                child: Positioned.fill(child: loaderWidget()));
          }),
        ],
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
