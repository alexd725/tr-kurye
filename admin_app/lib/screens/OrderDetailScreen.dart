import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
/*import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/OrderHistoryModel.dart';
import 'package:mightydelivery_admin_app/models/UserModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Common.dart';*/
import '../components/GenerateInvoice.dart';
import '../main.dart';
import '../models/OrderDetailModel.dart';
import '../models/OrderHistoryModel.dart';
import '../models/UserModel.dart';
import '../models/VehicleModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/CommonApiCall.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/DeliveryOrderAssignComponent.dart';
import '../components/OrderSummeryWidget.dart';
import '../models/ExtraChargeRequestModel.dart';
import '../models/OrderModel.dart';
import '../utils/Extensions/LiveStream.dart';
import 'OrderHistoryScreen.dart';
import 'package:readmore/readmore.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final OrderModel? orderModel;

  OrderDetailScreen({required this.orderId, this.orderModel});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? orderModel;
  List<OrderHistoryModel> orderHistory = [];
  Payment? payment;
  VehicleData? vehicleData;

  List<ExtraChargeRequestModel> extraChargeForListType = [];
  bool extraChargeTypeIsList = true;
  List<dynamic> deliveryPointsList = [];

  List<String> tabList = [language.orderDetail, language.orderHistory];

  int selectedTab = 0;

  UserModel? userData;
  UserModel? deliveryManData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getAllCountryApiCall();
    if (widget.orderModel != null) {
      orderModel = widget.orderModel;
      print("-----> ${orderModel!.carryPackagesCharge}");
      deliveryPointsList = orderModel!.deliveryPointsList ?? [];
      extraChargeTypeIsList = orderModel!.extraCharges is List<dynamic>;
      if (extraChargeTypeIsList) {
        (orderModel!.extraCharges as List<dynamic>).forEach((element) {
          extraChargeForListType.add(ExtraChargeRequestModel.fromJson(element));
        });
      }
      if (orderModel!.deliveryManId != null)
        await userDetailApiCall(orderModel!.deliveryManId!);
      if (orderModel!.clientId != null)
        await userDetailApiCall(orderModel!.clientId!);
      await orderDetail(orderId: widget.orderId).then((value) async {
        payment = value.payment;
        setState(() {});
      }).catchError((error) {});
      setState(() {});
    } else {
      await orderDetailApiCall();
    }
    LiveStream().on(streamLanguage, (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  orderDetailApiCall() async {
    appStore.setLoading(true);
    await orderDetail(orderId: widget.orderId).then((value) async {
      if (value.data!.deliveryManId != null)
        await userDetailApiCall(value.data!.deliveryManId!);
      if (value.data!.clientId != null)
        await userDetailApiCall(value.data!.clientId!);
      appStore.setLoading(false);
      orderModel = value.data!;
      orderHistory = value.orderHistory!;
      payment = value.payment;
      extraChargeTypeIsList = orderModel!.extraCharges is List<dynamic>;
      if (extraChargeTypeIsList) {
        (orderModel!.extraCharges as List<dynamic>).forEach((element) {
          extraChargeForListType.add(ExtraChargeRequestModel.fromJson(element));
        });
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  userDetailApiCall(int id) async {
    await getUserDetail(id).then((value) {
      if (value.userType == DELIVERYMAN) {
        deliveryManData = value;
      } else {
        userData = value;
      }
      setState(() {});
    }).catchError((error) {
      print(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    //return Observer(builder: (context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(orderModel != null
              ? orderStatus(orderModel!.status.validate())
              : ""),
          actions: [
            if (((orderModel != null &&
                orderModel!.status != ORDER_DELIVERED &&
                orderModel!.status != ORDER_CANCELLED &&
                orderModel!.status != ORDER_DRAFT &&
                orderModel!.deletedAt == null)))
              GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(color: Colors.white)),
                  child: Text(
                      orderModel!.deliveryManId == null
                          ? language.assign
                          : language.transfer,
                      style: boldTextStyle(color: Colors.white)),
                ),
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (_) {
                      return DeliveryOrderAssignComponent(
                        orderModel: orderModel!,
                        orderId: orderModel!.id!,
                        onUpdate: () {
                          orderDetailApiCall();
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
        body: Stack(
          children: [
            orderModel != null
                ? SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    controller: ScrollController(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${language.id} #${orderModel!.id}',
                                style: boldTextStyle(size: 18)),
                            Spacer(),
                            if (orderModel!.status != ORDER_CANCELLED)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.all(6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    side: BorderSide(color: primaryColor),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(language.invoiceCapital,
                                        style: primaryTextStyle(
                                            color: Colors.white)),
                                    Icon(Icons.download_outlined,
                                        color: Colors.white),
                                  ],
                                ),
                                onPressed: () {
                                  generateInvoiceCall(orderModel!);
                                },
                              ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.all(6),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(defaultRadius),
                                  side: BorderSide(color: primaryColor),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(language.orderHistory,
                                      style: primaryTextStyle(
                                          color: primaryColor)),
                                  Icon(Icons.arrow_right, color: primaryColor),
                                ],
                              ),
                              onPressed: () {
                                launchScreen(
                                    context,
                                    OrderHistoryScreen(
                                        orderId: orderModel!.id,
                                        orderHistoryData: orderHistory));
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(language.parcelDetails, style: boldTextStyle()),
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(12),
                          decoration: containerDecoration(),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(language.parcelType,
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                      child: Text(orderModel!.parcelType ?? '-',
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.weight,
                                      style: primaryTextStyle()),
                                  //Text('${orderModel!.totalWeight.toString()} ${language.kg}', style: primaryTextStyle()),
                                  Text(
                                      '${orderModel!.totalWeight.toString()} ${appStore.countryList.isNotEmpty ? '${appStore.countryList.firstWhere((element) => element.id == orderModel!.countryId).weightType ?? 'kg'}' : 'kg'}',
                                      style: primaryTextStyle()),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(language.numberOfParcels,
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                      child: Text(
                                          '${orderModel!.totalParcel ?? 1}',
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text("Vehicle Type",
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                      child: Text(
                                          '${orderModel!.vehicle_type ?? ""}',
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text("Delivery Type",
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                      child: Text(
                                          '${orderModel!.order_type ?? ""}',
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text("Receiver Name",
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)),
                                  Expanded(
                                      child: Text(
                                          '${orderModel!.deliveryReceiverName ?? ""}',
                                          style: primaryTextStyle(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(language.paymentDetails, style: boldTextStyle()),
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(12),
                          decoration: containerDecoration(),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.paymentType,
                                      style: primaryTextStyle()),
                                  Text(
                                      '${paymentType(orderModel!.paymentType ?? PAYMENT_TYPE_CASH)}',
                                      style: primaryTextStyle()),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.paymentStatus,
                                      style: primaryTextStyle()),
                                  Text(
                                      '${paymentStatus(orderModel!.paymentStatus ?? PAYMENT_PENDING)}',
                                      style: primaryTextStyle()),
                                ],
                              ),
                              if ((orderModel!.paymentType ??
                                      PAYMENT_TYPE_CASH) ==
                                  PAYMENT_TYPE_CASH)
                                SizedBox(height: 16),
                              if ((orderModel!.paymentType ??
                                      PAYMENT_TYPE_CASH) ==
                                  PAYMENT_TYPE_CASH)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(language.paymentCollectFrom,
                                        style: primaryTextStyle()),
                                    Text(
                                        '${paymentCollectForm(orderModel!.paymentCollectFrom!)}',
                                        style: primaryTextStyle()),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (orderModel!.pickupPoint!.address != null)
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.pickupAddress,
                                    style: boldTextStyle()),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: containerDecoration(),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          MapsLauncher.launchCoordinates(
                                              double.parse(orderModel!
                                                  .pickupPoint!.latitude
                                                  .validate()),
                                              double.parse(orderModel!
                                                  .pickupPoint!.longitude
                                                  .validate()));
                                        },
                                        child: ImageIcon(
                                            AssetImage(
                                                'assets/icons/ic_pick_location.png'),
                                            size: 24,
                                            color: primaryColor),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (orderModel!.pickupDatetime !=
                                                null)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                    '${language.pickedAt} ${printDate(orderModel!.pickupDatetime!)}',
                                                    style:
                                                        secondaryTextStyle()),
                                              ),
                                            Text(
                                                '${orderModel!.pickupPoint!.address}',
                                                style: primaryTextStyle()),
                                            if (orderModel!.pickupPoint!
                                                    .contactNumber !=
                                                null)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    launchUrl(Uri.parse(
                                                        'tel:${orderModel!.pickupPoint!.contactNumber}'));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.call,
                                                          color: Colors.green,
                                                          size: 18),
                                                      SizedBox(width: 8),
                                                      Text(
                                                          '${orderModel!.pickupPoint!.contactNumber}',
                                                          style:
                                                              secondaryTextStyle()),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (orderModel!.pickupDatetime ==
                                                    null &&
                                                orderModel!
                                                        .pickupPoint!.endTime !=
                                                    null &&
                                                orderModel!.pickupPoint!
                                                        .startTime !=
                                                    null)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                    '${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderModel!.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.pickupPoint!.endTime!).toLocal())}',
                                                    style:
                                                        secondaryTextStyle()),
                                              ),
                                            if (orderModel!
                                                .pickupPoint!.description
                                                .validate()
                                                .isNotEmpty)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.0),
                                                child: ReadMoreText(
                                                  '${language.remark}: ${orderModel!.pickupPoint!.description.validate()}',
                                                  trimLines: 3,
                                                  style: primaryTextStyle(
                                                      size: 14),
                                                  colorClickableText:
                                                      primaryColor,
                                                  trimMode: TrimMode.Line,
                                                  trimCollapsedText:
                                                      language.showMore,
                                                  trimExpandedText:
                                                      language.showLess,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (orderModel!.deliveryPoint!.address != null)
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.deliveryAddress,
                                    style: boldTextStyle()),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: containerDecoration(),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          MapsLauncher.launchCoordinates(
                                              double.parse(orderModel!
                                                  .deliveryPoint!.latitude
                                                  .validate()),
                                              double.parse(orderModel!
                                                  .deliveryPoint!.longitude
                                                  .validate()));
                                        },
                                        child: ImageIcon(
                                            AssetImage(
                                                'assets/icons/ic_delivery_location.png'),
                                            size: 24,
                                            color: primaryColor),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (orderModel!.deliveryDatetime !=
                                                null)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                    '${language.deliveredAt} ${printDate(orderModel!.deliveryDatetime!)}',
                                                    style:
                                                        secondaryTextStyle()),
                                              ),
                                            Text(
                                                '${orderModel!.deliveryPoint!.address}',
                                                style: primaryTextStyle()),
                                            if (orderModel!.deliveryPoint!
                                                    .contactNumber !=
                                                null)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    launchUrl(Uri.parse(
                                                        'tel:${orderModel!.deliveryPoint!.contactNumber}'));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.call,
                                                          color: Colors.green,
                                                          size: 18),
                                                      SizedBox(width: 8),
                                                      Text(
                                                          '${orderModel!.deliveryPoint!.contactNumber}',
                                                          style:
                                                              secondaryTextStyle()),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (orderModel!.deliveryDatetime ==
                                                    null &&
                                                orderModel!.deliveryPoint!
                                                        .endTime !=
                                                    null &&
                                                orderModel!.deliveryPoint!
                                                        .startTime !=
                                                    null)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                    '${language.note} ${language.courierWillDeliveredAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderModel!.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPoint!.endTime!).toLocal())}',
                                                    style:
                                                        secondaryTextStyle()),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (deliveryPointsList.length > 1) ...[
                                  SizedBox(height: 16.0),
                                  Text("Other Delivery Addresses",
                                      style: boldTextStyle()),
                                  if (deliveryPointsList.length >= 1 &&
                                      orderModel!.deliveryPointsList![0]
                                                  ['address']
                                              .toString() !=
                                          orderModel!.deliveryPoint!.address
                                              .toString()) ...[
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      padding: EdgeInsets.all(12),
                                      decoration: containerDecoration(),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              MapsLauncher.launchCoordinates(
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![0]
                                                          ['latitude']
                                                      .toString()
                                                      .validate()),
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![0]
                                                          ['longitude']
                                                      .toString()
                                                      .validate()));
                                            },
                                            child: ImageIcon(
                                                AssetImage(
                                                    'assets/icons/ic_delivery_location.png'),
                                                size: 24,
                                                color: primaryColor),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (orderModel!
                                                        .deliveryDatetime !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8.0),
                                                    child: Text(
                                                        '${language.deliveredAt} ${printDate(orderModel!.deliveryDatetime!)}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                                Text(
                                                    '${orderModel!.deliveryPointsList![0]['address']}',
                                                    style: primaryTextStyle()),
                                                if (orderModel!
                                                            .deliveryPointsList![
                                                        0]['contact_number'] !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        launchUrl(Uri.parse(
                                                            'tel:${orderModel!.deliveryPointsList![0]['contact_number']}'));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                              color:
                                                                  Colors.green,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              '${orderModel!.deliveryPointsList![0]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (orderModel!
                                                            .deliveryDatetime ==
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            0]['end_time'] !=
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            0]['start_time'] !=
                                                        null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                        '${language.note} ${language.courierWillDeliveredAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderModel!.deliveryPointsList![0]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![0]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![0]['end_time']!).toLocal())}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (deliveryPointsList.length >= 2 &&
                                      orderModel!.deliveryPointsList![1]
                                                  ['address']
                                              .toString() !=
                                          orderModel!.deliveryPoint!.address
                                              .toString()) ...[
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      padding: EdgeInsets.all(12),
                                      decoration: containerDecoration(),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              MapsLauncher.launchCoordinates(
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![1]
                                                          ['latitude']
                                                      .toString()
                                                      .validate()),
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![1]
                                                          ['longitude']
                                                      .toString()
                                                      .validate()));
                                            },
                                            child: ImageIcon(
                                                AssetImage(
                                                    'assets/icons/ic_delivery_location.png'),
                                                size: 24,
                                                color: primaryColor),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (orderModel!
                                                        .deliveryDatetime !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8.0),
                                                    child: Text(
                                                        '${language.deliveredAt} ${printDate(orderModel!.deliveryDatetime!)}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                                Text(
                                                    '${orderModel!.deliveryPointsList![1]['address']}',
                                                    style: primaryTextStyle()),
                                                if (orderModel!
                                                            .deliveryPointsList![
                                                        1]['contact_number'] !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        launchUrl(Uri.parse(
                                                            'tel:${orderModel!.deliveryPointsList![1]['contact_number']}'));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                              color:
                                                                  Colors.green,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              '${orderModel!.deliveryPointsList![1]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (orderModel!
                                                            .deliveryDatetime ==
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            1]['end_time'] !=
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            1]['start_time'] !=
                                                        null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                        '${language.note} ${language.courierWillDeliveredAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderModel!.deliveryPointsList![1]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![1]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![1]['end_time']!).toLocal())}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (deliveryPointsList.length >= 3 &&
                                      orderModel!.deliveryPointsList![2]
                                                  ['address']
                                              .toString() !=
                                          orderModel!.deliveryPoint!.address
                                              .toString()) ...[
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      padding: EdgeInsets.all(12),
                                      decoration: containerDecoration(),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              MapsLauncher.launchCoordinates(
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![2]
                                                          ['latitude']
                                                      .toString()
                                                      .validate()),
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![2]
                                                          ['longitude']
                                                      .toString()
                                                      .validate()));
                                            },
                                            child: ImageIcon(
                                                AssetImage(
                                                    'assets/icons/ic_delivery_location.png'),
                                                size: 24,
                                                color: primaryColor),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (orderModel!
                                                        .deliveryDatetime !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8.0),
                                                    child: Text(
                                                        '${language.deliveredAt} ${printDate(orderModel!.deliveryDatetime!)}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                                Text(
                                                    '${orderModel!.deliveryPointsList![2]['address']}',
                                                    style: primaryTextStyle()),
                                                if (orderModel!
                                                            .deliveryPointsList![
                                                        2]['contact_number'] !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        launchUrl(Uri.parse(
                                                            'tel:${orderModel!.deliveryPointsList![2]['contact_number']}'));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                              color:
                                                                  Colors.green,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              '${orderModel!.deliveryPointsList![2]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (orderModel!
                                                            .deliveryDatetime ==
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            2]['end_time'] !=
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            2]['start_time'] !=
                                                        null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                        '${language.note} ${language.courierWillDeliveredAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderModel!.deliveryPointsList![2]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![2]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![2]['end_time']!).toLocal())}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (deliveryPointsList.length >= 4 &&
                                      orderModel!.deliveryPointsList![3]
                                                  ['address']
                                              .toString() !=
                                          orderModel!.deliveryPoint!.address
                                              .toString()) ...[
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      padding: EdgeInsets.all(12),
                                      decoration: containerDecoration(),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              MapsLauncher.launchCoordinates(
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![3]
                                                          ['latitude']
                                                      .toString()
                                                      .validate()),
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![3]
                                                          ['longitude']
                                                      .toString()
                                                      .validate()));
                                            },
                                            child: ImageIcon(
                                                AssetImage(
                                                    'assets/icons/ic_delivery_location.png'),
                                                size: 24,
                                                color: primaryColor),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (orderModel!
                                                        .deliveryDatetime !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8.0),
                                                    child: Text(
                                                        '${language.deliveredAt} ${printDate(orderModel!.deliveryDatetime!)}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                                Text(
                                                    '${orderModel!.deliveryPointsList![3]['address']}',
                                                    style: primaryTextStyle()),
                                                if (orderModel!
                                                            .deliveryPointsList![
                                                        3]['contact_number'] !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        launchUrl(Uri.parse(
                                                            'tel:${orderModel!.deliveryPointsList![3]['contact_number']}'));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                              color:
                                                                  Colors.green,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              '${orderModel!.deliveryPointsList![3]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (orderModel!
                                                            .deliveryDatetime ==
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            3]['end_time'] !=
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            3]['start_time'] !=
                                                        null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                        '${language.note} ${language.courierWillDeliveredAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderModel!.deliveryPointsList![3]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![3]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![3]['end_time']!).toLocal())}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (deliveryPointsList.length >= 5 &&
                                      orderModel!.deliveryPointsList![4]
                                                  ['address']
                                              .toString() !=
                                          orderModel!.deliveryPoint!.address
                                              .toString()) ...[
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      padding: EdgeInsets.all(12),
                                      decoration: containerDecoration(),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              MapsLauncher.launchCoordinates(
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![4]
                                                          ['latitude']
                                                      .toString()
                                                      .validate()),
                                                  double.parse(orderModel!
                                                      .deliveryPointsList![4]
                                                          ['longitude']
                                                      .toString()
                                                      .validate()));
                                            },
                                            child: ImageIcon(
                                                AssetImage(
                                                    'assets/icons/ic_delivery_location.png'),
                                                size: 24,
                                                color: primaryColor),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (orderModel!
                                                        .deliveryDatetime !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 8.0),
                                                    child: Text(
                                                        '${language.deliveredAt} ${printDate(orderModel!.deliveryDatetime!)}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                                Text(
                                                    '${orderModel!.deliveryPointsList![4]['address']}',
                                                    style: primaryTextStyle()),
                                                if (orderModel!
                                                            .deliveryPointsList![
                                                        4]['contact_number'] !=
                                                    null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        launchUrl(Uri.parse(
                                                            'tel:${orderModel!.deliveryPointsList![4]['contact_number']}'));
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                              color:
                                                                  Colors.green,
                                                              size: 18),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              '${orderModel!.deliveryPointsList![4]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (orderModel!
                                                            .deliveryDatetime ==
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            4]['end_time'] !=
                                                        null &&
                                                    orderModel!.deliveryPointsList![
                                                            4]['start_time'] !=
                                                        null)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: Text(
                                                        '${language.note} ${language.courierWillDeliveredAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderModel!.deliveryPointsList![4]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![4]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderModel!.deliveryPointsList![4]['end_time']!).toLocal())}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  ),
                                                if (orderModel!
                                                    .deliveryPoint!.description
                                                    .validate()
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 8.0),
                                                    child: ReadMoreText(
                                                      '${language.remark}: ${orderModel!.deliveryPoint!.description.validate()}',
                                                      trimLines: 3,
                                                      style: primaryTextStyle(
                                                          size: 14),
                                                      colorClickableText:
                                                          primaryColor,
                                                      trimMode: TrimMode.Line,
                                                      trimCollapsedText:
                                                          language.showMore,
                                                      trimExpandedText:
                                                          language.showLess,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ]
                              ],
                            ),
                          ),
                        if (orderModel!.vehicleData != null)
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.vehicle, style: boldTextStyle()),
                                Container(
                                  margin: EdgeInsets.only(top: 16),
                                  padding: EdgeInsets.all(16),
                                  decoration: containerDecoration(),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Text(language.vehicle_name,
                                                style: boldTextStyle()),
                                          ),
                                          Expanded(
                                            child: Text(
                                                '${orderModel!.vehicleData!.title.validate()}',
                                                style: primaryTextStyle()),
                                          )
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: commonCachedNetworkImage(
                                                orderModel!.vehicleImage,
                                                fit: BoxFit.fill,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            if (orderModel!.pickupConfirmByClient == 1)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(language.picUpSignature,
                                          style: boldTextStyle()),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.only(top: 8),
                                        padding: EdgeInsets.all(12),
                                        decoration: containerDecoration(),
                                        child: orderModel!
                                                .pickupTimeSignature!.isNotEmpty
                                            ? commonCachedNetworkImage(
                                                orderModel!
                                                        .pickupTimeSignature ??
                                                    '-',
                                                fit: BoxFit.contain,
                                                height: 140,
                                                width: 140)
                                            : Text(language.noData),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            orderModel!.pickupConfirmByDeliveryMan == 1
                                ? Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 16, left: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(language.deliverySignature,
                                              style: boldTextStyle()),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: EdgeInsets.only(top: 8),
                                            padding: EdgeInsets.all(12),
                                            decoration: containerDecoration(),
                                            child: orderModel!
                                                    .deliveryTimeSignature!
                                                    .isNotEmpty
                                                ? commonCachedNetworkImage(
                                                    orderModel!
                                                        .deliveryTimeSignature!,
                                                    fit: BoxFit.contain,
                                                    height: 140,
                                                    width: 140)
                                                : Text(language.noData),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Spacer(),
                          ],
                        ),
                        if (userData != null)
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.aboutUser,
                                    style: boldTextStyle()),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: containerDecoration(),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey
                                                  .withOpacity(0.15)),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  '${userData!.profileImage ?? ""}'),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('${userData!.name}',
                                                    style: boldTextStyle()),
                                                if (userData!.contactNumber !=
                                                    null)
                                                  GestureDetector(
                                                    onTap: () {
                                                      launchUrl(Uri.parse(
                                                          'tel:${userData!.contactNumber}'));
                                                    },
                                                    child: Image.asset(
                                                        'assets/icons/ic_call.png',
                                                        width: 24,
                                                        height: 24),
                                                  )
                                              ],
                                            ),
                                            userData!.contactNumber != null
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 6),
                                                    child: Text(
                                                        '${userData!.contactNumber}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (deliveryManData != null)
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.aboutDeliveryMan,
                                    style: boldTextStyle()),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  padding: EdgeInsets.all(12),
                                  decoration: containerDecoration(),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.15)),
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: NetworkImage(
                                                      '${deliveryManData!.profileImage ?? ""}'),
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          if (deliveryManData!
                                                  .isVerifiedDeliveryMan ==
                                              1)
                                            Icon(Icons.verified_user,
                                                color: Colors.green, size: 22),
                                        ],
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('${deliveryManData!.name}',
                                                    style: boldTextStyle()),
                                                if (deliveryManData!
                                                        .contactNumber !=
                                                    null)
                                                  GestureDetector(
                                                    onTap: () {
                                                      launchUrl(Uri.parse(
                                                          'tel:${deliveryManData!.contactNumber}'));
                                                    },
                                                    child: Image.asset(
                                                        'assets/icons/ic_call.png',
                                                        width: 24,
                                                        height: 24),
                                                  )
                                              ],
                                            ),
                                            deliveryManData!.contactNumber !=
                                                    null
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 6),
                                                    child: Text(
                                                        '${deliveryManData!.contactNumber}',
                                                        style:
                                                            secondaryTextStyle()),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (orderModel!.status == ORDER_CANCELLED)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Text("Cancelled reason", style: boldTextStyle()),
                              SizedBox(height: 8),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16)),
                                padding: EdgeInsets.all(12),
                                child: Text(
                                    '${orderModel!.reason.validate(value: "-")}',
                                    style: primaryTextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          padding: EdgeInsets.all(12),
                          decoration: containerDecoration(),
                          child: (orderModel!.extraCharges is List<dynamic>)
                              ? OrderSummeryWidget(
                                  extraChargesList: extraChargeForListType,
                                  totalDistance: orderModel!.totalDistance ?? 0,
                                  totalWeight: orderModel!.totalWeight ?? 0,
                                  distanceCharge:
                                      orderModel!.distanceCharge ?? 0,
                                  weightCharge: orderModel!.weightCharge ?? 0,
                                  totalAmount: orderModel!.totalAmount ?? 0,
                                  onAnotherCharges:
                                      orderModel!.chargePerAddress,
                                  carryPackagesCharge:
                                      orderModel!.carryPackagesCharge,
                                  status: orderModel!.status,
                                  payment: payment,
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.deliveryCharges,
                                            style: primaryTextStyle()),
                                        SizedBox(width: 16),
                                        Text(
                                            '${printAmount(orderModel!.fixedCharges ?? 0)}',
                                            style: primaryTextStyle()),
                                      ],
                                    ),
                                    if (orderModel!.distanceCharge != 0)
                                      Column(
                                        children: [
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.distanceCharge,
                                                  style: primaryTextStyle()),
                                              SizedBox(width: 16),
                                              Text(
                                                  '${printAmount(orderModel!.distanceCharge ?? 0)}',
                                                  style: primaryTextStyle()),
                                            ],
                                          )
                                        ],
                                      ),
                                    if (orderModel!.weightCharge != 0)
                                      Column(
                                        children: [
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.weightCharge,
                                                  style: primaryTextStyle()),
                                              SizedBox(width: 16),
                                              Text(
                                                  '${printAmount(orderModel!.weightCharge ?? 0)}',
                                                  style: primaryTextStyle()),
                                            ],
                                          ),
                                        ],
                                      ),
                                    if ((orderModel!.distanceCharge != 0 ||
                                            orderModel!.weightCharge != 0) &&
                                        orderModel!.extraCharges.keys.length !=
                                            0)
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Column(
                                          children: [
                                            SizedBox(height: 8),
                                            Text(
                                                '${printAmount((orderModel!.fixedCharges ?? 0) + (orderModel!.distanceCharge ?? 0) + (orderModel!.weightCharge ?? 0))}',
                                                style: primaryTextStyle()),
                                          ],
                                        ),
                                      ),
                                    if (orderModel!.extraCharges.keys.length !=
                                        0)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 16),
                                          Text(language.extraCharges,
                                              style: boldTextStyle()),
                                          SizedBox(height: 8),
                                          Column(
                                              children: List.generate(
                                                  orderModel!.extraCharges.keys
                                                      .length, (index) {
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      orderModel!
                                                          .extraCharges.keys
                                                          .elementAt(index)
                                                          .replaceAll("_", " "),
                                                      style:
                                                          primaryTextStyle()),
                                                  SizedBox(width: 16),
                                                  Text(
                                                      '${printAmount(orderModel!.extraCharges.values.elementAt(index))}',
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              ),
                                            );
                                          }).toList()),
                                        ],
                                      ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.total,
                                            style: boldTextStyle(size: 20)),
                                        (orderModel!.status ==
                                                    ORDER_CANCELLED &&
                                                payment != null &&
                                                payment!.deliveryManFee == 0)
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      '${printAmount(orderModel!.totalAmount ?? 0)}',
                                                      style: secondaryTextStyle(
                                                          size: 16,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough)),
                                                  SizedBox(width: 8),
                                                  Text(
                                                      '${printAmount(payment!.cancelCharges ?? 0)}',
                                                      style: boldTextStyle(
                                                          size: 20)),
                                                ],
                                              )
                                            : Text(
                                                '${printAmount(orderModel!.totalAmount ?? 0)}',
                                                style: boldTextStyle(size: 20)),
                                        /*Text(language.total, style: boldTextStyle(size: 20, color: primaryColor)),
                                          Text('${printAmount(orderModel!.totalAmount ?? 0)}', style: boldTextStyle(size: 20, color: primaryColor)),*/
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            Visibility(visible: appStore.isLoading, child: loaderWidget()),
          ],
        ),
      ),
    );
  }
}
