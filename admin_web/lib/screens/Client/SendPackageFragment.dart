import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:local_delivery_admin/utils/Extensions/live_stream.dart';
import '../../components/Admin/OrderSummeryWidget.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../models/CityListModel.dart';
import '../../models/CountryListModel.dart';
import '../../models/OrderModel.dart';
import '../../models/VehicleListModel.dart';
import '../../network/ClientRestApi.dart';
import '../../network/RestApis.dart';
import '../../screens/Client/DashboardScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Extensions/widget_extensions.dart';
import 'package:flutter/material.dart';
import '../../components/Client/DashboardComponent/DashboardFooterComponent.dart';
import '../../components/Client/HeaderWidget.dart';
import '../../main.dart';
import '../../models/AutoCompletePlacesListModel.dart';
import '../../models/Client/PaymentModel.dart';
import '../../models/ExtraChargeRequestModel.dart';
import '../../models/ParcelTypeListModel.dart';
import '../../models/PlaceIdDetailModel.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';

class SendPackageFragment extends StatefulWidget {
  static const String route = '/sendpackage';
  final int? orderId;

  SendPackageFragment({this.orderId});

  @override
  SendPackageFragmentState createState() => SendPackageFragmentState();
}

class SendPackageFragmentState extends State<SendPackageFragment> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CityData? cityData;
  List<ParcelTypeData> parcelTypeList = [];

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

  FocusNode pickPhoneFocus = FocusNode();
  FocusNode pickDesFocus = FocusNode();
  FocusNode deliverPhoneFocus = FocusNode();
  FocusNode deliverDesFocus = FocusNode();

  String deliverCountryCode = defaultPhoneCode;
  String pickupCountryCode = defaultPhoneCode;

  DateTime? pickFromDateTime,
      pickToDateTime,
      deliverFromDateTime,
      deliverToDateTime;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  String? pickLat, pickLong, deliverLat, deliverLong;

  int selectedTabIndex = 0;

  bool isDeliverNow = true;
  int isSelected = 1;

  String paymentCollectFrom = PAYMENT_ON_PICKUP;

  DateTime? currentBackPressTime;

  num totalDistance = 0;
  num totalAmount = 0;

  num weightCharge = 0;
  num distanceCharge = 0;
  num totalExtraCharge = 0;
  num carryPackagesCharge = 0;

  int? selectedVehicle;

  List<VehicleData> vehicleList = [];
  VehicleData? vehicleData;

  OrderModel? orderModel;

  int? selectedCity;
  int? selectedCountry;
  List<PaymentModel> mPaymentList = getPaymentItems();

  List<ExtraChargeRequestModel> extraChargeList = [];

  List<Predictions> pickPredictionList = [];
  List<Predictions> deliverPredictionList = [];

  String? pickMsg, deliverMsg;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await getCityDetailApiCall(getIntAsync(CITY_ID));
    getParcelTypeListApiCall();
    extraChargesList();
    getVehicleList(cityID: getIntAsync(CITY_ID));
    LiveStream().on(streamVehicleMode, (p0) {
      getVehicleApiCall();
    });

    if (widget.orderId != null) {
      await orderDetail(orderId: widget.orderId!).then((value) {
        if (value.data!.totalWeight != 0)
          weightController.text = value.data!.totalWeight!.toString();
        if (value.data!.totalParcel != null)
          totalParcelController.text = value.data!.totalParcel!.toString();
        parcelTypeCont.text = value.data!.parcelType.validate();

        pickAddressCont.text = value.data!.pickupPoint!.address.validate();
        pickLat = value.data!.pickupPoint!.latitude.validate();
        pickLong = value.data!.pickupPoint!.longitude.validate();
        if (value.data!.pickupPoint!.contactNumber
                .validate()
                .split(" ")
                .length ==
            1) {
          pickPhoneCont.text =
              value.data!.pickupPoint!.contactNumber.validate().split(" ").last;
        } else {
          pickupCountryCode = value.data!.pickupPoint!.contactNumber
              .validate()
              .split(" ")
              .first;
          pickPhoneCont.text =
              value.data!.pickupPoint!.contactNumber.validate().split(" ").last;
        }
        pickDesCont.text = value.data!.pickupPoint!.description.validate();

        deliverAddressCont.text = value.data!.deliveryPoint!.address.validate();
        deliverLat = value.data!.deliveryPoint!.latitude.validate();
        deliverLong = value.data!.deliveryPoint!.longitude.validate();
        if (value.data!.deliveryPoint!.contactNumber
                .validate()
                .split(" ")
                .length ==
            1) {
          deliverPhoneCont.text = value.data!.deliveryPoint!.contactNumber
              .validate()
              .split(" ")
              .last;
        } else {
          deliverCountryCode = value.data!.deliveryPoint!.contactNumber
              .validate()
              .split(" ")
              .first;
          deliverPhoneCont.text = value.data!.deliveryPoint!.contactNumber
              .validate()
              .split(" ")
              .last;
        }
        deliverDesCont.text = value.data!.deliveryPoint!.description.validate();

        paymentCollectFrom =
            value.data!.paymentCollectFrom.validate(value: PAYMENT_ON_PICKUP);
      }).catchError((e) {});
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
      await setValue(CITY_DATA, value.toJson());
      cityData = value;
      getVehicleApiCall();
      setState(() {});
    }).catchError((error) {});
  }

  getVehicleApiCall({String? name}) async {
    appStore.setLoading(true);
    await getVehicleList(cityID: getIntAsync(CITY_ID)).then((value) {
      appStore.setLoading(false);
      vehicleList.clear();
      //selectedVehicle = null;
      vehicleList = value.data!;
      if (vehicleList.isNotEmpty) selectedVehicle = vehicleList[0].id!;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
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

  getTotalAmount() {
    totalDistance = calculateDistance(pickLat.toDouble(), pickLong.toDouble(),
        deliverLat.toDouble(), deliverLong.toDouble());
    totalAmount = 0;
    weightCharge = 0;
    distanceCharge = 0;
    totalExtraCharge = 0;

    /// calculate weight Charge
    if (weightController.text.toDouble() > cityData!.minWeight!) {
      weightCharge =
          ((weightController.text.toDouble() - cityData!.minWeight!) *
                  cityData!.perWeightCharges!)
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

    /// total amount
    totalAmount = cityData!.fixedCharges! + weightCharge + distanceCharge;

    /// calculate extra charges
    cityData!.extraCharges!.forEach((element) {
      totalExtraCharge += countExtraCharge(
          totalAmount: totalAmount,
          charges: element.charges!,
          chargesType: element.chargesType!);
    });

    /// All Charges
    totalAmount = (totalAmount + totalExtraCharge)
        .toStringAsFixed(digitAfterDecimal)
        .toDouble();
  }

  createOrderApiCall(String orderStatus) async {
    finish(context);
    appStore.setLoading(true);
    Map req = {
      "id": widget.orderId != null ? widget.orderId : "",
      "client_id": getIntAsync(USER_ID).toString(),
      "date": DateTime.now().toString(),
      "country_id": getIntAsync(COUNTRY_ID).toString(),
      "city_id": getIntAsync(CITY_ID).toString(),
      if (appStore.isShowVehicle == 1) "vehicle_id": selectedVehicle.toString(),
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
      "delivery_point": {
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
    };

    log("req----" + req.toString());
    await createOrder(req).then((value) async {
      appStore.setLoading(false);
      toast(value.message);
      log(value.message);
      if (isSelected == 2) {
        log("-----" +
            clientStore.availableBal.toString() +
            totalAmount.toString());

        if (clientStore.availableBal > totalAmount) {
          savePaymentApiCall(
              paymentType: PAYMENT_TYPE_WALLET,
              paymentStatus: PAYMENT_PAID,
              totalAmount: totalAmount.toString(),
              orderID: value.orderId.toString());
        } else {
          toast(language.lessAmountBal);
          cashConfirmDialog();
        }
      } else {
        finish(context);
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
      Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route,
          (route) {
        return true;
      });
    }).catchError((error) {
      appStore.setLoading(false);
      print(error.toString());
    });
  }

  Future<List<Predictions>> getPlaceAutoCompleteApiCall(String text) async {
    List<Predictions> list = [];
    await placeAutoCompleteApi(
            searchText: text,
            language: 'en',
            countryCode: CountryData.fromJson(getJSONAsync(COUNTRY_DATA))
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

  /// Component 1
  Widget mWeight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.weight, style: boldTextStyle()),
        8.height,
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(defaultRadius)),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.weight, style: primaryTextStyle())
                    .paddingAll(12)
                    .expand(),
                VerticalDivider(thickness: 1),
                Icon(Icons.remove, color: Colors.grey).paddingAll(12).onTap(() {
                  if (weightController.text.toDouble() > 1) {
                    weightController.text =
                        (weightController.text.toDouble() - 1).toString();
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
                    decoration: InputDecoration(
                      counterText: '',
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryColor)),
                      border: InputBorder.none,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9 .]')),
                    ],
                  ),
                ),
                VerticalDivider(thickness: 1),
                Icon(Icons.add, color: Colors.grey).paddingAll(12).onTap(() {
                  weightController.text =
                      (weightController.text.toDouble() + 1).toString();
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget mNomOfParcel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.number_of_parcels, style: boldTextStyle()),
        8.height,
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(defaultRadius)),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.number_of_parcels, style: primaryTextStyle())
                    .paddingAll(12)
                    .expand(),
                VerticalDivider(thickness: 1),
                Icon(Icons.remove, color: Colors.grey).paddingAll(12).onTap(() {
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
                          borderSide: BorderSide(color: primaryColor)),
                      border: InputBorder.none,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                VerticalDivider(thickness: 1),
                Icon(Icons.add, color: Colors.grey).paddingAll(12).onTap(() {
                  totalParcelController.text =
                      (totalParcelController.text.toInt() + 1).toString();
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget mPick() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.pick_time, style: boldTextStyle()),
        16.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          child: Column(
            children: [
              Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(primary: primaryColor),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                child: DateTimePicker(
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
              ),
              16.height,
              Row(
                children: [
                  Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(primary: primaryColor),
                      buttonTheme:
                          ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: DateTimePicker(
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
                  ),
                  16.width,
                  Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(primary: primaryColor),
                      buttonTheme:
                          ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: DateTimePicker(
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
                          return language.end_start_time_validation_msg;
                        }
                        return null;
                      },
                      decoration: commonInputDecoration(
                          suffixIcon: Icons.access_time, hintText: language.to),
                    ).expand(),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget mDrop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.deliver_time, style: boldTextStyle()),
        16.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          child: Column(
            children: [
              Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(primary: primaryColor),
                  buttonTheme:
                      ButtonThemeData(textTheme: ButtonTextTheme.primary),
                ),
                child: DateTimePicker(
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
              ),
              16.height,
              Row(
                children: [
                  Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(primary: primaryColor),
                      buttonTheme:
                          ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
                    child: DateTimePicker(
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
                  ),
                  16.width,
                  Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(primary: primaryColor),
                      buttonTheme:
                          ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    ),
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
                          suffixIcon: Icons.access_time, hintText: language.to),
                    ).expand(),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createOrderStep1() {
    return SizedBox(
      height: context.height() - 275,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                clientScheduleOptionWidget(
                        context,
                        isDeliverNow,
                        MaterialCommunityIcons.clock_time_five_outline,
                        language.deliver_now)
                    .onTap(() {
                  isDeliverNow = true;
                  setState(() {});
                }).expand(),
                16.width,
                clientScheduleOptionWidget(context, !isDeliverNow,
                        AntDesign.calendar, language.schedule)
                    .onTap(() {
                  isDeliverNow = false;
                  setState(() {});
                }).expand(),
              ],
            ),
            16.height,
            if (!isDeliverNow)
              ResponsiveWidget.isSmallScreen(context)
                  ? Column(
                      children: [
                        mPick(),
                        16.height,
                        mDrop(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        mPick().expand(),
                        16.width,
                        mDrop().expand(),
                      ],
                    ),
            16.height,
            if (ResponsiveWidget.isSmallScreen(context))
              Column(children: [mWeight(), 16.height, mNomOfParcel()])
            else
              Row(children: [
                mWeight().expand(),
                16.width,
                mNomOfParcel().expand()
              ]),
            16.height,
            Text(language.parcel_type, style: boldTextStyle()),
            8.height,
            AppTextField(
              controller: parcelTypeCont,
              textFieldType: TextFieldType.OTHER,
              decoration: commonInputDecoration(),
              validator: (value) {
                if (value!.isEmpty) return language.field_required_msg;
                return null;
              },
            ),
            16.height,
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
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    side: BorderSide(color: borderColor),
                  ),
                ).onTap(() {
                  parcelTypeCont.text = item.label!;
                  setState(() {});
                });
              }).toList(),
            ),
            8.height,
            if (appStore.isShowVehicle == 1 && vehicleList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.select_vehicle, style: boldTextStyle()),
                  SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    value: selectedVehicle,
                    decoration: commonInputDecoration(),
                    dropdownColor: Theme.of(context).cardColor,
                    style: primaryTextStyle(),
                    items: vehicleList.map<DropdownMenuItem<int>>((item) {
                      return DropdownMenuItem(
                        value: item.id,
                        child: Row(
                          children: [
                            commonCachedNetworkImage(
                                item.vehicleImage.validate(),
                                height: 40,
                                width: 40),
                            SizedBox(width: 16),
                            Text(item.title ?? '', style: primaryTextStyle()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedVehicle = value;
                      print(selectedVehicle);
                      setState(() {
                        // print(item.title);
                      });
                    },
                    validator: (value) {
                      if (selectedVehicle == null)
                        return errorThisFieldRequired;
                      return null;
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Component 2
  Widget createOrderStep2() {
    return SizedBox(
      height: context.height() - 275,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.pickUpInformation, style: boldTextStyle()),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.pickUpLocation, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: pickAddressCont,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.ADDRESS,
                    decoration: commonInputDecoration(
                        suffixIcon: Icons.location_on_outlined),
                    validator: (value) {
                      if (value!.isEmpty) return errorThisFieldRequired;
                      if (pickLat == null || pickLong == null)
                        return language.pleaseSelectValidAddress;
                      return null;
                    },
                    onChanged: (val) async {
                      pickMsg = '';
                      pickLat = null;
                      pickLong = null;
                      if (val.isNotEmpty) {
                        if (val.length < 3) {
                          pickMsg = language.selectedAddressValidation;
                          pickPredictionList.clear();
                          setState(() {});
                        } else {
                          pickPredictionList =
                              await getPlaceAutoCompleteApiCall(val);
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
                            leading:
                                Icon(Icons.location_pin, color: primaryColor),
                            title: Text(mData.description ?? ""),
                            onTap: () async {
                              PlaceIdDetailModel? response =
                                  await getPlaceIdDetailApiCall(
                                      placeId: mData.placeId!);
                              if (response != null) {
                                pickAddressCont.text = mData.description ?? "";
                                pickLat = response
                                    .result!.geometry!.location!.lat
                                    .toString();
                                pickLong = response
                                    .result!.geometry!.location!.lng
                                    .toString();
                                pickPredictionList.clear();
                                setState(() {});
                              }
                            },
                          );
                        }),
                  16.height,
                  Text(language.pickup_contact_number,
                      style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: pickPhoneCont,
                    focus: pickPhoneFocus,
                    nextFocus: pickDesFocus,
                    textFieldType: TextFieldType.PHONE,
                    decoration: commonInputDecoration(
                      suffixIcon: Icons.phone,
                      prefixIcon: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountryCodePicker(
                              initialSelection: pickupCountryCode,
                              showCountryOnly: false,
                              dialogSize: Size(
                                  context.width() - 60, context.height() * 0.6),
                              showFlag: true,
                              showFlagDialog: true,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: primaryTextStyle(),
                              dialogBackgroundColor:
                                  Theme.of(context).cardColor,
                              barrierColor: Colors.black12,
                              dialogTextStyle: primaryTextStyle(),
                              searchDecoration: InputDecoration(
                                iconColor: Theme.of(context).dividerColor,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).dividerColor)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: primaryColor)),
                              ),
                              searchStyle: primaryTextStyle(),
                              onInit: (c) {
                                pickupCountryCode = c!.dialCode!;
                              },
                              onChanged: (c) {
                                pickupCountryCode = c.dialCode!;
                              },
                            ),
                            VerticalDivider(
                                color: Colors.grey.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.trim().isEmpty)
                        return language.field_required_msg;
                      if (value.trim().length < minContactLength ||
                          value.trim().length > maxContactLength)
                        return language.contact_length_validation;
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  16.height,
                  Text(language.pickup_description, style: primaryTextStyle()),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Component 3
  Widget createOrderStep3() {
    return SizedBox(
      height: context.height() - 275,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.delivery_information, style: boldTextStyle()),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.delivery_location, style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: deliverAddressCont,
                    textInputAction: TextInputAction.next,
                    textFieldType: TextFieldType.ADDRESS,
                    decoration: commonInputDecoration(
                        suffixIcon: Icons.location_on_outlined),
                    validator: (value) {
                      if (value!.isEmpty) return errorThisFieldRequired;
                      if (deliverLat == null || deliverLong == null)
                        return language.pleaseSelectValidAddress;
                      return null;
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
                          deliverPredictionList =
                              await getPlaceAutoCompleteApiCall(val);
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
                        padding: EdgeInsets.only(top: 8, left: 8),
                        child: Text(
                          deliverMsg.validate(),
                          style: secondaryTextStyle(color: Colors.red),
                        )),
                  if (deliverPredictionList.isNotEmpty)
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      controller: ScrollController(),
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      shrinkWrap: true,
                      itemCount: deliverPredictionList.length,
                      itemBuilder: (context, index) {
                        Predictions mData = deliverPredictionList[index];
                        return ListTile(
                          leading:
                              Icon(Icons.location_pin, color: primaryColor),
                          title: Text(mData.description ?? ""),
                          onTap: () async {
                            PlaceIdDetailModel? response =
                                await getPlaceIdDetailApiCall(
                                    placeId: mData.placeId!);
                            if (response != null) {
                              deliverAddressCont.text = mData.description ?? "";
                              deliverLat = response
                                  .result!.geometry!.location!.lat
                                  .toString();
                              deliverLong = response
                                  .result!.geometry!.location!.lng
                                  .toString();
                              deliverPredictionList.clear();
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
                  16.height,
                  Text(language.delivery_contact_number,
                      style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: deliverPhoneCont,
                    textInputAction: TextInputAction.next,
                    focus: deliverPhoneFocus,
                    nextFocus: deliverDesFocus,
                    textFieldType: TextFieldType.PHONE,
                    decoration: commonInputDecoration(
                      suffixIcon: Icons.phone,
                      prefixIcon: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountryCodePicker(
                              initialSelection: deliverCountryCode,
                              showCountryOnly: false,
                              dialogSize: Size(
                                  context.width() - 60, context.height() * 0.6),
                              showFlag: true,
                              showFlagDialog: true,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: primaryTextStyle(),
                              dialogBackgroundColor:
                                  Theme.of(context).cardColor,
                              barrierColor: Colors.black12,
                              dialogTextStyle: primaryTextStyle(),
                              searchDecoration: InputDecoration(
                                iconColor: Theme.of(context).dividerColor,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).dividerColor)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: primaryColor)),
                              ),
                              searchStyle: primaryTextStyle(),
                              onInit: (c) {
                                deliverCountryCode = c!.dialCode!;
                              },
                              onChanged: (c) {
                                deliverCountryCode = c.dialCode!;
                              },
                            ),
                            VerticalDivider(
                                color: Colors.grey.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.trim().isEmpty)
                        return language.field_required_msg;
                      if (value.trim().length < minContactLength ||
                          value.trim().length > maxContactLength)
                        return language.contact_length_validation;
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  16.height,
                  Text(language.delivery_description,
                      style: primaryTextStyle()),
                  8.height,
                  TextField(
                    controller: deliverDesCont,
                    focusNode: deliverDesFocus,
                    decoration: commonInputDecoration(suffixIcon: Icons.notes),
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    minLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Component 4
  Widget createOrderStep4() {
    return SizedBox(
      height: context.height() - 275,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mTitle(language.package_information),
            8.height,
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                  border: Border.all(color: borderColor)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      mHeading(language.parcel_type).expand(),
                      mHeadingValue(parcelTypeCont.text).expand(),
                    ],
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      mHeading(language.weight),
                      mHeadingValue(
                          '${weightController.text} ${CountryData.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}'),
                    ],
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      mHeading(language.number_of_parcels),
                      mHeadingValue('${totalParcelController.text}'),
                    ],
                  ),
                ],
              ),
            ),
            20.height,
            ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      mAddress(isPick: true),
                      16.height,
                      mAddress(isPick: false),
                    ],
                  )
                : Row(
                    children: [
                      mAddress(isPick: true).expand(),
                      16.width,
                      mAddress(isPick: false).expand(),
                    ],
                  ),
            20.height,
            OrderSummeryWidget(
                extraChargesList: extraChargeList,
                totalDistance: totalDistance,
                totalWeight: weightController.text.toDouble(),
                distanceCharge: distanceCharge,
                weightCharge: weightCharge,
                carryPackagesCharge: carryPackagesCharge,
                totalAmount: totalAmount),
            16.height,
            Text(language.payment, style: boldTextStyle()),
            16.height,
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: mPaymentList.map((mData) {
                return mData.title == PAYMENT_TYPE_WALLET &&
                        clientStore.availableBal < totalAmount
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.all(16),
                        decoration: boxDecorationWithRoundedCorners(
                            border: Border.all(
                                color: isSelected == mData.index
                                    ? primaryColor
                                    : borderColor),
                            backgroundColor: context.cardColor),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ImageIcon(AssetImage(mData.image!),
                                size: 20,
                                color: isSelected == mData.index
                                    ? primaryColor
                                    : Colors.grey),
                            16.width,
                            Text(mData.title.validate().capitalizeFirstLetter(),
                                style: boldTextStyle()),
                          ],
                        ),
                      ).onTap(() {
                        isSelected = mData.index!;
                        setState(() {});
                      });
              }).toList(),
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
                        child: Text(language.pickup_location,
                            style: primaryTextStyle(), maxLines: 1)),
                    DropdownMenuItem(
                        value: PAYMENT_ON_DELIVERY,
                        child: Text(language.delivery_location,
                            style: primaryTextStyle(), maxLines: 1)),
                  ],
                  onChanged: (value) {
                    paymentCollectFrom = value!;
                    setState(() {});
                  },
                ).expand(),
              ],
            ).visible(isSelected == 1),
          ],
        ),
      ),
    );
  }

  Widget mHeading(String value) {
    return Text(value,
        style: secondaryTextStyle(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis);
  }

  Widget mHeadingValue(String value) {
    return Text(value,
        style: primaryTextStyle(weight: FontWeight.w600, size: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end);
  }

  Widget mTitle(String value) {
    return Text(value, style: boldTextStyle());
  }

  Widget mAddress({required bool isPick}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mTitle(isPick ? language.pickup_location : language.delivery_location),
        Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
              border: Border.all(color: borderColor)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPick ? pickAddressCont.text : deliverAddressCont.text,
                      style: primaryTextStyle()),
                  8.height.visible(isPick
                      ? pickPhoneCont.text.isNotEmpty
                      : deliverPhoneCont.text.isNotEmpty),
                  Text(
                          isPick
                              ? '$pickupCountryCode ${pickPhoneCont.text}'
                              : '$deliverCountryCode ${deliverPhoneCont.text}',
                          style: secondaryTextStyle())
                      .visible(isPick
                          ? pickPhoneCont.text.isNotEmpty
                          : deliverPhoneCont.text.isNotEmpty),
                ],
              ).expand()
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            HeaderWidget(),
            Stack(
              children: [
                SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveWidget.isLessMediumScreen(context)
                                    ? mCommonPadding1(context)
                                    : mCommonPadding(context),
                            vertical: 16),
                        decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: lightPrimaryColor),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: context.height() - 75,
                              width:
                                  ResponsiveWidget.isLessMediumScreen(context)
                                      ? context.width() * 0.8
                                      : context.width() * 0.7,
                              decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: lightPrimaryColor),
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(language.sendPackages,
                                          style: boldTextStyle(size: 20)),
                                      2.height,
                                      Text(language.demandlocalcourier,
                                          style: secondaryTextStyle()),
                                      24.height,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: List.generate(4, (index) {
                                          return Row(
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                height: 28,
                                                width: 28,
                                                decoration: BoxDecoration(
                                                  color:
                                                      selectedTabIndex >= index
                                                          ? primaryColor
                                                          : borderColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text('${index + 1}',
                                                    style: primaryTextStyle(
                                                        color:
                                                            selectedTabIndex >=
                                                                    index
                                                                ? Colors.white
                                                                : null)),
                                              ),
                                              if (index < 3)
                                                Container(
                                                    width:
                                                        context.width() * 0.1,
                                                    height: 3,
                                                    color: selectedTabIndex >=
                                                            index
                                                        ? primaryColor
                                                        : borderColor)
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                      30.height,
                                      if (selectedTabIndex == 0)
                                        createOrderStep1(),
                                      if (selectedTabIndex == 1)
                                        createOrderStep2(),
                                      if (selectedTabIndex == 2)
                                        createOrderStep3(),
                                      if (selectedTabIndex == 3)
                                        createOrderStep4()
                                    ],
                                  ).paddingAll(30),
                                  Wrap(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (selectedTabIndex != 0)
                                            GestureDetector(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                                selectedTabIndex--;
                                                setState(() {});
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 45),
                                                decoration:
                                                    boxDecorationWithRoundedCorners(
                                                        borderRadius: radius(
                                                            defaultRadius),
                                                        border: Border.all(
                                                            color: primaryColor,
                                                            width: 1)),
                                                child: Text(language.previous,
                                                    style: boldTextStyle(
                                                        color: primaryColor,
                                                        size: 14)),
                                              ),
                                            ),
                                          16.width,
                                          InkWell(
                                            onTap: () {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              if (selectedTabIndex != 3) {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  Duration difference =
                                                      Duration();
                                                  Duration
                                                      differenceCurrentTime =
                                                      Duration();
                                                  if (!isDeliverNow) {
                                                    pickFromDateTime = pickDate!
                                                        .add(Duration(
                                                            hours: pickFromTime!
                                                                .hour,
                                                            minutes:
                                                                pickFromTime!
                                                                    .minute));
                                                    pickToDateTime = pickDate!
                                                        .add(Duration(
                                                            hours: pickToTime!
                                                                .hour,
                                                            minutes: pickToTime!
                                                                .minute));
                                                    deliverFromDateTime =
                                                        deliverDate!.add(Duration(
                                                            hours:
                                                                deliverFromTime!
                                                                    .hour,
                                                            minutes:
                                                                deliverFromTime!
                                                                    .minute));
                                                    deliverToDateTime =
                                                        deliverDate!.add(Duration(
                                                            hours:
                                                                deliverToTime!
                                                                    .hour,
                                                            minutes:
                                                                deliverToTime!
                                                                    .minute));
                                                    difference = pickFromDateTime!
                                                        .difference(
                                                            deliverFromDateTime!);
                                                    differenceCurrentTime =
                                                        DateTime.now().difference(
                                                            pickFromDateTime!);
                                                  }
                                                  if (differenceCurrentTime
                                                          .inMinutes >
                                                      0)
                                                    return toast(language
                                                        .pickup_current_validation_msg);
                                                  if (difference.inMinutes > 0)
                                                    return toast(language
                                                        .pickup_deliver_validation_msg);
                                                  selectedTabIndex++;
                                                  if (selectedTabIndex == 3) {
                                                    getTotalAmount();
                                                  }
                                                  setState(() {});
                                                }
                                              } else {
                                                commonConfirmationDialog(
                                                    context, DIALOG_TYPE_ENABLE,
                                                    () {
                                                  createOrderApiCall(
                                                      ORDER_CREATED);
                                                },
                                                    title: language
                                                        .createOrderConfirmation,
                                                    subtitle: language
                                                            .createOrderConfirmation +
                                                        '?');
                                              }
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 45),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      radius(defaultRadius),
                                                  color: primaryColor),
                                              child: Text(
                                                  selectedTabIndex != 3
                                                      ? language.next
                                                      : language.create_order,
                                                  style: boldTextStyle(
                                                      color: Colors.white,
                                                      size: 14)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ).paddingAll(16)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      55.height,
                      DashboardFooterComponent(),
                    ],
                  ),
                ),
                Observer(
                    builder: (context) =>
                        loaderWidget().visible(appStore.isLoading)),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
