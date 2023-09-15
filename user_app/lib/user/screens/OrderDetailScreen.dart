import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../main/Chat/ChatScreen.dart';
import '../../main/components/BodyCornerWidget.dart';
import '../../main/components/OrderSummeryWidget.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/ExtraChargeRequestModel.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/models/OrderDetailModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';
import '../components/CancelOrderDialog.dart';
import 'OrderHistoryScreen.dart';
import 'ReturnOrderScreen.dart';

class OrderDetailScreen extends StatefulWidget {
  static String tag = '/OrderDetailScreen';

  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  UserData? userData;

  OrderData? orderData;
  List<OrderHistory>? orderHistory;
  Payment? payment;
  List<ExtraChargeRequestModel> list = [];
  List<dynamic> deliveryPointsList = [];

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    orderDetailApiCall();
  }

  orderDetailApiCall() async {
    appStore.setLoading(true);
    await getOrderDetails(widget.orderId).then((value) {
      appStore.setLoading(false);
      orderData = value.data!;
      deliveryPointsList = value.data!.deliveryPointsList ?? [];
      orderHistory = value.orderHistory!;
      payment = value.payment ?? Payment();
      if (orderData!.extraCharges.runtimeType == List<dynamic>) {
        (orderData!.extraCharges as List<dynamic>).forEach((element) {
          list.add(ExtraChargeRequestModel.fromJson(element));
        });
      }
      if (getStringAsync(USER_TYPE) == CLIENT) {
        if (orderData!.deliveryManId != null)
          userDetailApiCall(orderData!.deliveryManId!);
      } else {
        if (orderData!.clientId != null)
          userDetailApiCall(orderData!.clientId!);
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  userDetailApiCall(int id) async {
    appStore.setLoading(true);
    await getUserDetail(id).then((value) {
      appStore.setLoading(false);
      userData = value;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    afterBuildCreated(() {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        finish(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(
                '${orderData != null ? orderData!.status!.replaceAll("_", " ").capitalizeFirstLetter() : ''}')),
        body: BodyCornerWidget(
          child: Stack(
            children: [
              orderData != null
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 16, bottom: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(language.orderId,
                                      style: boldTextStyle(size: 20)),
                                  Text('#${orderData!.id}',
                                      style: boldTextStyle(size: 20)),
                                ],
                              ),
                              16.height,
                              Text(
                                  '${language.createdAt} ${printDate(orderData!.date.toString())}',
                                  style: secondaryTextStyle()),
                              Divider(height: 30, thickness: 1),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      ImageIcon(
                                          AssetImage(
                                              'assets/icons/ic_pick_location.png'),
                                          size: 24,
                                          color: colorPrimary),
                                      16.width,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (orderData!.pickupDatetime != null)
                                            Text('${language.pickedAt} ${printDate(orderData!.pickupDatetime!)}',
                                                    style: secondaryTextStyle())
                                                .paddingOnly(bottom: 8),
                                          Text(
                                              '${orderData!.pickupPoint!.address}',
                                              style: primaryTextStyle()),
                                          if (orderData!
                                                  .pickupPoint!.contactNumber !=
                                              null)
                                            Row(
                                              children: [
                                                Icon(Icons.call,
                                                        color: Colors.green,
                                                        size: 18)
                                                    .onTap(() {
                                                  commonLaunchUrl(
                                                      'tel:${orderData!.pickupPoint!.contactNumber}');
                                                }),
                                                8.width,
                                                Text(
                                                    '${orderData!.pickupPoint!.contactNumber}',
                                                    style:
                                                        secondaryTextStyle()),
                                              ],
                                            ).paddingOnly(top: 8),
                                          if (orderData!.pickupDatetime ==
                                                  null &&
                                              orderData!.pickupPoint!.endTime !=
                                                  null &&
                                              orderData!
                                                      .pickupPoint!.startTime !=
                                                  null)
                                            Text('${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.endTime!).toLocal())}',
                                                    style: secondaryTextStyle())
                                                .paddingOnly(top: 8),
                                          if (orderData!
                                              .pickupPoint!.description
                                              .validate()
                                              .isNotEmpty)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 8.0),
                                              child: ReadMoreText(
                                                '${language.remark}: ${orderData!.pickupPoint!.description.validate()}',
                                                trimLines: 3,
                                                style:
                                                    primaryTextStyle(size: 14),
                                                colorClickableText:
                                                    colorPrimary,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText:
                                                    language.showMore,
                                                trimExpandedText:
                                                    language.showLess,
                                              ),
                                            ),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                  16.height,
                                  Row(
                                    children: [
                                      ImageIcon(
                                          AssetImage(
                                              'assets/icons/ic_delivery_location.png'),
                                          size: 24,
                                          color: colorPrimary),
                                      16.width,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (orderData!.deliveryDatetime !=
                                              null)
                                            Text('${language.deliveredAt} ${printDate(orderData!.deliveryDatetime!)}',
                                                    style: secondaryTextStyle())
                                                .paddingOnly(bottom: 8),
                                          Text(
                                              '${orderData!.deliveryPoint!.address}',
                                              style: primaryTextStyle()),
                                          if (orderData!.deliveryPoint!
                                                  .contactNumber !=
                                              null)
                                            Row(
                                              children: [
                                                Icon(Icons.call,
                                                        color: Colors.green,
                                                        size: 18)
                                                    .onTap(() {
                                                  commonLaunchUrl(
                                                      'tel:${orderData!.deliveryPoint!.contactNumber}');
                                                }),
                                                8.width,
                                                Text(
                                                    '${orderData!.deliveryPoint!.contactNumber}',
                                                    style:
                                                        secondaryTextStyle()),
                                              ],
                                            ).paddingOnly(top: 8),
                                          if (orderData!.deliveryDatetime ==
                                                  null &&
                                              orderData!
                                                      .deliveryPoint!.endTime !=
                                                  null &&
                                              orderData!.deliveryPoint!
                                                      .startTime !=
                                                  null)
                                            Text('${language.note} ${language.courierWillDeliverAt}${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.endTime!).toLocal())}',
                                                    style: secondaryTextStyle())
                                                .paddingOnly(top: 8),
                                          if (orderData!
                                              .deliveryPoint!.description
                                              .validate()
                                              .isNotEmpty)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 8.0),
                                              child: ReadMoreText(
                                                '${language.remark}: ${orderData!.deliveryPoint!.description.validate()}',
                                                trimLines: 3,
                                                style:
                                                    primaryTextStyle(size: 14),
                                                colorClickableText:
                                                    colorPrimary,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText:
                                                    language.showMore,
                                                trimExpandedText:
                                                    language.showLess,
                                              ),
                                            ),
                                        ],
                                      ).expand(),
                                    ],
                                  ),
                                  16.height,
                                  if (deliveryPointsList.length > 1) ...[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Other Delivery points",
                                              style: boldTextStyle(size: 16)),
                                          if (deliveryPointsList.length >= 1 &&
                                              orderData!.deliveryPointsList![0]
                                                          ['address']
                                                      .toString() !=
                                                  orderData!
                                                      .deliveryPoint!.address
                                                      .toString()) ...[
                                            8.height,
                                            Row(
                                              children: [
                                                ImageIcon(
                                                    AssetImage(
                                                        'assets/icons/ic_delivery_location.png'),
                                                    size: 24,
                                                    color: colorPrimary),
                                                16.width,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (orderData!
                                                            .deliveryDatetime !=
                                                        null)
                                                      Text('${language.deliveredAt} ${printDate(orderData!.deliveryDatetime!)}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(
                                                              bottom: 8),
                                                    Text(
                                                        '${orderData!.deliveryPointsList![0]['address']}',
                                                        style:
                                                            primaryTextStyle()),
                                                    if (orderData!
                                                                .deliveryPointsList![0]
                                                            [
                                                            'contact_number'] !=
                                                        null)
                                                      Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 18)
                                                              .onTap(() {
                                                            launchUrl(Uri.parse(
                                                                'tel:${orderData!.deliveryPointsList![0]['contact_number']}'));
                                                          }),
                                                          8.width,
                                                          Text(
                                                              '${orderData!.deliveryPointsList![0]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ).paddingOnly(top: 8),
                                                    if (orderData!.deliveryDatetime == null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .endTime !=
                                                            null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .startTime !=
                                                            null)
                                                      Text('${language.note} ${language.courierWillDeliverAt}${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPointsList![0]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![0]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![0]['end_time']!).toLocal())}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(top: 8),
                                                    if (orderData!
                                                        .deliveryPointsList![0]
                                                            ['description']
                                                        .toString()
                                                        .validate()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 8.0),
                                                        child: ReadMoreText(
                                                          '${language.remark}: ${orderData!.deliveryPointsList![0]['description'].toString().validate()}',
                                                          trimLines: 3,
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
                                                          colorClickableText:
                                                              colorPrimary,
                                                          trimMode:
                                                              TrimMode.Line,
                                                          trimCollapsedText:
                                                              language.showMore,
                                                          trimExpandedText:
                                                              language.showLess,
                                                        ),
                                                      ),
                                                  ],
                                                ).expand(),
                                              ],
                                            ),
                                          ],
                                          if (deliveryPointsList.length >= 2 &&
                                              orderData!.deliveryPointsList![1]
                                                          ['address']
                                                      .toString() !=
                                                  orderData!
                                                      .deliveryPoint!.address
                                                      .toString()) ...[
                                            8.height,
                                            Row(
                                              children: [
                                                ImageIcon(
                                                    AssetImage(
                                                        'assets/icons/ic_delivery_location.png'),
                                                    size: 24,
                                                    color: colorPrimary),
                                                16.width,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (orderData!
                                                            .deliveryDatetime !=
                                                        null)
                                                      Text('${language.deliveredAt} ${printDate(orderData!.deliveryDatetime!)}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(
                                                              bottom: 8),
                                                    Text(
                                                        '${orderData!.deliveryPointsList![1]['address']}',
                                                        style:
                                                            primaryTextStyle()),
                                                    if (orderData!
                                                                .deliveryPointsList![1]
                                                            [
                                                            'contact_number'] !=
                                                        null)
                                                      Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 18)
                                                              .onTap(() {
                                                            launchUrl(Uri.parse(
                                                                'tel:${orderData!.deliveryPointsList![1]['contact_number']}'));
                                                          }),
                                                          8.width,
                                                          Text(
                                                              '${orderData!.deliveryPointsList![1]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ).paddingOnly(top: 8),
                                                    if (orderData!.deliveryDatetime == null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .endTime !=
                                                            null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .startTime !=
                                                            null)
                                                      Text('${language.note} ${language.courierWillDeliverAt}${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPointsList![1]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![1]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![1]['end_time']!).toLocal())}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(top: 8),
                                                    if (orderData!
                                                        .deliveryPointsList![1]
                                                            ['description']
                                                        .toString()
                                                        .validate()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 8.0),
                                                        child: ReadMoreText(
                                                          '${language.remark}: ${orderData!.deliveryPointsList![1]['description'].toString().validate()}',
                                                          trimLines: 3,
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
                                                          colorClickableText:
                                                              colorPrimary,
                                                          trimMode:
                                                              TrimMode.Line,
                                                          trimCollapsedText:
                                                              language.showMore,
                                                          trimExpandedText:
                                                              language.showLess,
                                                        ),
                                                      ),
                                                  ],
                                                ).expand(),
                                              ],
                                            ),
                                          ],
                                          if (deliveryPointsList.length >= 3 &&
                                              orderData!.deliveryPointsList![2]
                                                          ['address']
                                                      .toString() !=
                                                  orderData!
                                                      .deliveryPoint!.address
                                                      .toString()) ...[
                                            8.height,
                                            Row(
                                              children: [
                                                ImageIcon(
                                                    AssetImage(
                                                        'assets/icons/ic_delivery_location.png'),
                                                    size: 24,
                                                    color: colorPrimary),
                                                16.width,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (orderData!
                                                            .deliveryDatetime !=
                                                        null)
                                                      Text('${language.deliveredAt} ${printDate(orderData!.deliveryDatetime!)}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(
                                                              bottom: 8),
                                                    Text(
                                                        '${orderData!.deliveryPointsList![2]['address']}',
                                                        style:
                                                            primaryTextStyle()),
                                                    if (orderData!
                                                                .deliveryPointsList![2]
                                                            [
                                                            'contact_number'] !=
                                                        null)
                                                      Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 18)
                                                              .onTap(() {
                                                            launchUrl(Uri.parse(
                                                                'tel:${orderData!.deliveryPointsList![2]['contact_number']}'));
                                                          }),
                                                          8.width,
                                                          Text(
                                                              '${orderData!.deliveryPointsList![2]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ).paddingOnly(top: 8),
                                                    if (orderData!.deliveryDatetime == null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .endTime !=
                                                            null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .startTime !=
                                                            null)
                                                      Text('${language.note} ${language.courierWillDeliverAt}${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPointsList![2]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![2]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![2]['end_time']!).toLocal())}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(top: 8),
                                                    if (orderData!
                                                        .deliveryPointsList![2]
                                                            ['description']
                                                        .toString()
                                                        .validate()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 8.0),
                                                        child: ReadMoreText(
                                                          '${language.remark}: ${orderData!.deliveryPointsList![2]['description'].toString().validate()}',
                                                          trimLines: 3,
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
                                                          colorClickableText:
                                                              colorPrimary,
                                                          trimMode:
                                                              TrimMode.Line,
                                                          trimCollapsedText:
                                                              language.showMore,
                                                          trimExpandedText:
                                                              language.showLess,
                                                        ),
                                                      ),
                                                  ],
                                                ).expand(),
                                              ],
                                            ),
                                          ],
                                          if (deliveryPointsList.length >= 4 &&
                                              orderData!.deliveryPointsList![3]
                                                          ['address']
                                                      .toString() !=
                                                  orderData!
                                                      .deliveryPoint!.address
                                                      .toString()) ...[
                                            8.height,
                                            Row(
                                              children: [
                                                ImageIcon(
                                                    AssetImage(
                                                        'assets/icons/ic_delivery_location.png'),
                                                    size: 24,
                                                    color: colorPrimary),
                                                16.width,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (orderData!
                                                            .deliveryDatetime !=
                                                        null)
                                                      Text('${language.deliveredAt} ${printDate(orderData!.deliveryDatetime!)}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(
                                                              bottom: 8),
                                                    Text(
                                                        '${orderData!.deliveryPointsList![3]['address']}',
                                                        style:
                                                            primaryTextStyle()),
                                                    if (orderData!
                                                                .deliveryPointsList![3]
                                                            [
                                                            'contact_number'] !=
                                                        null)
                                                      Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 18)
                                                              .onTap(() {
                                                            launchUrl(Uri.parse(
                                                                'tel:${orderData!.deliveryPointsList![3]['contact_number']}'));
                                                          }),
                                                          8.width,
                                                          Text(
                                                              '${orderData!.deliveryPointsList![3]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ).paddingOnly(top: 8),
                                                    if (orderData!.deliveryDatetime == null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .endTime !=
                                                            null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .startTime !=
                                                            null)
                                                      Text('${language.note} ${language.courierWillDeliverAt}${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPointsList![3]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![3]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![3]['end_time']!).toLocal())}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(top: 8),
                                                    if (orderData!
                                                        .deliveryPointsList![3]
                                                            ['description']
                                                        .toString()
                                                        .validate()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 8.0),
                                                        child: ReadMoreText(
                                                          '${language.remark}: ${orderData!.deliveryPointsList![3]['description'].toString().validate()}',
                                                          trimLines: 3,
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
                                                          colorClickableText:
                                                              colorPrimary,
                                                          trimMode:
                                                              TrimMode.Line,
                                                          trimCollapsedText:
                                                              language.showMore,
                                                          trimExpandedText:
                                                              language.showLess,
                                                        ),
                                                      ),
                                                  ],
                                                ).expand(),
                                              ],
                                            ),
                                          ],
                                          if (deliveryPointsList.length >= 5 &&
                                              orderData!.deliveryPointsList![4]
                                                          ['address']
                                                      .toString() !=
                                                  orderData!
                                                      .deliveryPoint!.address
                                                      .toString()) ...[
                                            8.height,
                                            Row(
                                              children: [
                                                ImageIcon(
                                                    AssetImage(
                                                        'assets/icons/ic_delivery_location.png'),
                                                    size: 24,
                                                    color: colorPrimary),
                                                16.width,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (orderData!
                                                            .deliveryDatetime !=
                                                        null)
                                                      Text('${language.deliveredAt} ${printDate(orderData!.deliveryDatetime!)}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(
                                                              bottom: 8),
                                                    Text(
                                                        '${orderData!.deliveryPointsList![4]['address']}',
                                                        style:
                                                            primaryTextStyle()),
                                                    if (orderData!
                                                                .deliveryPointsList![4]
                                                            [
                                                            'contact_number'] !=
                                                        null)
                                                      Row(
                                                        children: [
                                                          Icon(Icons.call,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 18)
                                                              .onTap(() {
                                                            launchUrl(Uri.parse(
                                                                'tel:${orderData!.deliveryPointsList![4]['contact_number']}'));
                                                          }),
                                                          8.width,
                                                          Text(
                                                              '${orderData!.deliveryPointsList![4]['contact_number']}',
                                                              style:
                                                                  secondaryTextStyle()),
                                                        ],
                                                      ).paddingOnly(top: 8),
                                                    if (orderData!.deliveryDatetime == null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .endTime !=
                                                            null &&
                                                        orderData!
                                                                .deliveryPoint!
                                                                .startTime !=
                                                            null)
                                                      Text('${language.note} ${language.courierWillDeliverAt}${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPointsList![4]['start_time']!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![4]['start_time']!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPointsList![4]['end_time']!).toLocal())}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(top: 8),
                                                    if (orderData!
                                                        .deliveryPointsList![4]
                                                            ['description']
                                                        .toString()
                                                        .validate()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 8.0),
                                                        child: ReadMoreText(
                                                          '${language.remark}: ${orderData!.deliveryPointsList![4]['description'].toString().validate()}',
                                                          trimLines: 3,
                                                          style:
                                                              primaryTextStyle(
                                                                  size: 14),
                                                          colorClickableText:
                                                              colorPrimary,
                                                          trimMode:
                                                              TrimMode.Line,
                                                          trimCollapsedText:
                                                              language.showMore,
                                                          trimExpandedText:
                                                              language.showLess,
                                                        ),
                                                      ),
                                                  ],
                                                ).expand(),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: AppButton(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  padding: EdgeInsets.all(6),
                                  shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    side: BorderSide(color: colorPrimary),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(language.viewHistory,
                                          style: primaryTextStyle(
                                              color: colorPrimary)),
                                      Icon(Icons.arrow_right,
                                          color: colorPrimary),
                                    ],
                                  ),
                                  onTap: () {
                                    OrderHistoryScreen(
                                            orderHistory:
                                                orderHistory.validate())
                                        .launch(context);
                                  },
                                ),
                              ),
                              Divider(height: 30, thickness: 1),
                              Text(language.parcelDetails,
                                  style: boldTextStyle(size: 16)),
                              12.height,
                              Container(
                                decoration: BoxDecoration(
                                    color: appStore.isDarkMode
                                        ? scaffoldSecondaryDark
                                        : colorPrimary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration:
                                              boxDecorationWithRoundedCorners(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: borderColor,
                                                      width: appStore.isDarkMode
                                                          ? 0.2
                                                          : 1),
                                                  backgroundColor:
                                                      Colors.transparent),
                                          padding: EdgeInsets.all(8),
                                          child: Image.asset(
                                              parcelTypeIcon(orderData!
                                                  .parcelType
                                                  .validate()),
                                              height: 24,
                                              width: 24,
                                              color: Colors.grey),
                                        ),
                                        8.width,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                orderData!.parcelType
                                                    .validate(),
                                                style: boldTextStyle()),
                                            4.height,
                                            Text(
                                                '${orderData!.totalWeight} ${CountryModel.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}',
                                                style: secondaryTextStyle()),
                                          ],
                                        ).expand(),
                                      ],
                                    ),
                                    Divider(height: 30).visible(
                                        orderData!.totalParcel != null),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.numberOfParcels,
                                            style: primaryTextStyle()),
                                        Text('${orderData!.totalParcel ?? 1}',
                                            style: primaryTextStyle()),
                                      ],
                                    ).visible(orderData!.totalParcel != null),
                                    8.height,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Vehicle Type",
                                            style: primaryTextStyle()),
                                        Text('${orderData!.vehicle_type ?? ""}',
                                            style: primaryTextStyle()),
                                      ],
                                    ).visible(orderData!.vehicle_type != null),
                                    8.height,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Delivery Type",
                                            style: primaryTextStyle()),
                                        Text('${orderData!.order_type ?? ""}',
                                            style: primaryTextStyle()),
                                      ],
                                    ).visible(orderData!.order_type != null),
                                    8.height,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Receiver Name",
                                            style: primaryTextStyle()),
                                        Text(
                                            '${orderData!.deliveryReceiverName ?? ""}',
                                            style: primaryTextStyle()),
                                      ],
                                    ).visible(orderData!.deliveryReceiverName !=
                                        null),
                                    8.height,
                                    // parcelDetails
                                  ],
                                ),
                              ),
                              24.height,
                              Text(language.paymentDetails,
                                  style: boldTextStyle(size: 16)),
                              12.height,
                              Container(
                                decoration: BoxDecoration(
                                    color: appStore.isDarkMode
                                        ? scaffoldSecondaryDark
                                        : colorPrimary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.paymentType,
                                            style: primaryTextStyle()),
                                        Text(
                                            '${paymentType(orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH))}',
                                            style: primaryTextStyle()),
                                      ],
                                    ),
                                    Divider(height: 30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.paymentStatus,
                                            style: primaryTextStyle()),
                                        Text(
                                            '${paymentStatus(orderData!.paymentStatus.validate(value: PAYMENT_PENDING))}',
                                            style: primaryTextStyle()),
                                      ],
                                    ),
                                    Divider(height: 30).visible(
                                        orderData!.paymentType.validate(
                                                value: PAYMENT_TYPE_CASH) ==
                                            PAYMENT_TYPE_CASH),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(language.paymentCollectFrom,
                                            style: primaryTextStyle()),
                                        Text(
                                            '${paymentCollectForm(orderData!.paymentCollectFrom!)}',
                                            style: primaryTextStyle()),
                                      ],
                                    ).visible(orderData!.paymentType.validate(
                                            value: PAYMENT_TYPE_CASH) ==
                                        PAYMENT_TYPE_CASH),
                                  ],
                                ),
                              ),
                              12.height,
                              if (orderData!.vehicleData != null)
                                Text(language.vehicle, style: boldTextStyle()),
                              if (orderData!.vehicleData != null) 12.height,
                              if (orderData!.vehicleData != null)
                                Container(
                                    decoration: BoxDecoration(
                                        color: appStore.isDarkMode
                                            ? scaffoldSecondaryDark
                                            : colorPrimary.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                language.vehicle_name,
                                                style: primaryTextStyle(),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                  '${orderData!.vehicleData!.title.validate()}',
                                                  style: primaryTextStyle()),
                                            )
                                          ],
                                        ),
                                        // if (orderModel.vehicleData!.vehicleImage != null)
                                        if (orderData!.vehicleImage != null)
                                          Container(
                                            margin: EdgeInsets.all(10),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: commonCachedNetworkImage(
                                                    orderData!.vehicleImage,
                                                    fit: BoxFit.fill,
                                                    height: 100,
                                                    width: 150)),
                                          ),
                                      ],
                                    )),
                              12.height,
                              if (userData != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    24.height,
                                    Text(
                                        '${getStringAsync(USER_TYPE) == CLIENT ? language.aboutDeliveryMan : language.aboutUser}',
                                        style: boldTextStyle(size: 16)),
                                    12.height,
                                    Container(
                                      decoration: BoxDecoration(
                                          color: appStore.isDarkMode
                                              ? scaffoldSecondaryDark
                                              : colorPrimary.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Image.network(
                                                      userData!.profileImage
                                                          .validate(),
                                                      height: 60,
                                                      width: 60,
                                                      fit: BoxFit.cover,
                                                      alignment:
                                                          Alignment.center)
                                                  .cornerRadiusWithClipRRect(
                                                      60),
                                              16.width,
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      '${userData!.name.validate()}',
                                                      style: boldTextStyle()),
                                                  userData!.contactNumber !=
                                                          null
                                                      ? Text('${userData!.contactNumber}',
                                                              style:
                                                                  secondaryTextStyle())
                                                          .paddingOnly(top: 4)
                                                          .onTap(() {
                                                          commonLaunchUrl(
                                                              'tel:${userData!.contactNumber}');
                                                        })
                                                      : SizedBox()
                                                ],
                                              ).expand(),
                                              IconButton(
                                                      onPressed: () {
                                                        ChatScreen(
                                                                userData:
                                                                    userData)
                                                            .launch(context);
                                                      },
                                                      icon: Icon(Icons.chat))
                                                  .visible(orderData!.status !=
                                                          ORDER_DELIVERED &&
                                                      orderData!.status !=
                                                          ORDER_CANCELLED)
                                            ],
                                          ),
                                          if (getStringAsync(USER_TYPE) ==
                                                  CLIENT &&
                                              userData!.isVerifiedDeliveryMan ==
                                                  1)
                                            Row(
                                              children: [
                                                Icon(Icons.verified_user,
                                                    color: Colors.green),
                                                8.width,
                                                Text(language.verified,
                                                    style: primaryTextStyle(
                                                        color: Colors.green)),
                                              ],
                                            ).paddingOnly(top: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              if (orderData!.reason.validate().isNotEmpty &&
                                  orderData!.status != ORDER_CANCELLED)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    24.height,
                                    Text(language.returnReason,
                                        style: boldTextStyle()),
                                    12.height,
                                    Container(
                                      width: context.width(),
                                      decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                          '${orderData!.reason.validate(value: "-")}',
                                          style: primaryTextStyle(
                                              color: Colors.red)),
                                    ),
                                  ],
                                ),
                              if (orderData!.status == ORDER_CANCELLED)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    24.height,
                                    Text(language.cancelledReason,
                                        style: boldTextStyle()),
                                    12.height,
                                    Container(
                                      width: context.width(),
                                      decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                          '${orderData!.reason.validate(value: "-")}',
                                          style: primaryTextStyle(
                                              color: Colors.red)),
                                    ),
                                  ],
                                ),
                              Divider(height: 30, thickness: 1),
                              (orderData!.extraCharges!.runtimeType ==
                                      List<dynamic>)
                                  ? OrderSummeryWidget(
                                      extraChargesList: list,
                                      totalDistance: orderData!.totalDistance,
                                      totalWeight:
                                          orderData!.totalWeight.validate(),
                                      distanceCharge:
                                          orderData!.distanceCharge.validate(),
                                      weightCharge:
                                          orderData!.weightCharge.validate(),
                                      totalAmount: orderData!.totalAmount,
                                      payment: payment,
                                      status: orderData!.status,
                                      onAnotherCharges:
                                          orderData!.chargePerAddress,
                                      carryPackagesCharge:
                                          orderData!.carryPackagesCharge,
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(language.deliveryCharge,
                                                style: primaryTextStyle()),
                                            16.width,
                                            Text(
                                                '${printAmount(orderData!.fixedCharges.validate())}',
                                                style: primaryTextStyle()),
                                          ],
                                        ),
                                        if (orderData!.distanceCharge
                                                .validate() !=
                                            0)
                                          Column(
                                            children: [
                                              8.height,
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(language.distanceCharge,
                                                      style:
                                                          primaryTextStyle()),
                                                  16.width,
                                                  Text(
                                                      '${printAmount(orderData!.distanceCharge.validate())}',
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              )
                                            ],
                                          ),
                                        if (orderData!.weightCharge
                                                .validate() !=
                                            0)
                                          Column(
                                            children: [
                                              8.height,
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(language.weightCharge,
                                                      style:
                                                          primaryTextStyle()),
                                                  16.width,
                                                  Text(
                                                      '${printAmount(orderData!.weightCharge.validate())}',
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              ),
                                            ],
                                          ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Column(
                                            children: [
                                              8.height,
                                              Text(
                                                  '${printAmount(orderData!.fixedCharges.validate() + orderData!.distanceCharge.validate() + orderData!.weightCharge.validate())}',
                                                  style: primaryTextStyle()),
                                            ],
                                          ),
                                        ).visible((orderData!.distanceCharge
                                                        .validate() !=
                                                    0 ||
                                                orderData!.weightCharge
                                                        .validate() !=
                                                    0) &&
                                            orderData!
                                                    .extraCharges.keys.length !=
                                                0),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            16.height,
                                            Text(language.extraCharges,
                                                style: boldTextStyle()),
                                            8.height,
                                            Column(
                                                children: List.generate(
                                                    orderData!.extraCharges.keys
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
                                                        orderData!
                                                            .extraCharges.keys
                                                            .elementAt(index)
                                                            .replaceAll(
                                                                "_", " "),
                                                        style:
                                                            primaryTextStyle()),
                                                    16.width,
                                                    Text(
                                                        '${printAmount(orderData!.extraCharges.values.elementAt(index))}',
                                                        style:
                                                            primaryTextStyle()),
                                                  ],
                                                ),
                                              );
                                            }).toList()),
                                          ],
                                        ).visible(orderData!
                                                .extraCharges.keys.length !=
                                            0),
                                        16.height,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(language.total,
                                                style: boldTextStyle(size: 20)),
                                            (orderData!.status ==
                                                        ORDER_CANCELLED &&
                                                    payment != null &&
                                                    payment!.deliveryManFee ==
                                                        0)
                                                ? Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          '${printAmount(orderData!.totalAmount.validate())}',
                                                          style: secondaryTextStyle(
                                                              size: 16,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough)),
                                                      8.width,
                                                      Text(
                                                          '${printAmount(payment!.cancelCharges.validate())}',
                                                          style: boldTextStyle(
                                                              size: 20)),
                                                      //Text('${printAmount(orderData!.totalAmount.validate())}', style: boldTextStyle(size: 20, color: colorPrimary)),
                                                    ],
                                                  )
                                                : Text(
                                                    '${printAmount(orderData!.totalAmount.validate())}',
                                                    style: boldTextStyle(
                                                        size: 20)),
                                          ],
                                        ),
                                      ],
                                    ),
                              16.height,
                              if (orderData!.status == ORDER_CANCELLED &&
                                  payment != null)
                                Container(
                                  width: context.width(),
                                  decoration: BoxDecoration(
                                      color: appStore.isDarkMode
                                          ? scaffoldSecondaryDark
                                          : colorPrimary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                      '${language.note} ${payment!.deliveryManFee == 0 ? language.cancelBeforePickMsg : language.cancelAfterPickMsg}',
                                      style: secondaryTextStyle(
                                          color: Colors.red)),
                                ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  children: [
                                    commonButton(language.cancelOrder, () {
                                      showInDialog(
                                        context,
                                        contentPadding: EdgeInsets.all(16),
                                        builder: (p0) {
                                          return CancelOrderDialog(
                                              orderId: orderData!.id.validate(),
                                              onUpdate: () {
                                                orderDetailApiCall();
                                                LiveStream()
                                                    .emit('UpdateOrderData');
                                              });
                                        },
                                      );
                                    }, width: context.width()),
                                    8.height,
                                    Container(
                                      width: context.width(),
                                      decoration: BoxDecoration(
                                          color: appStore.isDarkMode
                                              ? scaffoldSecondaryDark
                                              : colorPrimary.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: EdgeInsets.all(12),
                                      child: Text(language.cancelNote,
                                          style: secondaryTextStyle()),
                                    ),
                                  ],
                                ),
                              ).visible(getStringAsync(USER_TYPE) == CLIENT &&
                                  orderData!.status != ORDER_DELIVERED &&
                                  orderData!.status != ORDER_CANCELLED)
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: commonButton(language.returnOrder, () {
                            ReturnOrderScreen(orderData!).launch(context);
                          }, width: context.width())
                              .paddingAll(16),
                        ).visible(orderData!.status == ORDER_DELIVERED &&
                            !orderData!.returnOrderId! &&
                            getStringAsync(USER_TYPE) == CLIENT)
                      ],
                    )
                  : SizedBox(),
              Observer(
                  builder: (context) =>
                      loaderWidget().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }
}
