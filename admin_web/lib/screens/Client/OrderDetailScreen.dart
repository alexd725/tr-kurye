import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:local_delivery_admin/models/VehicleListModel.dart';
import '../../components/Client/OrderHistoryComponent.dart';
import '../../components/Client/OrderSummeryWidget.dart';
import '../../models/OrderModel.dart';
import '../../models/UserModel.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/list_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import 'package:readmore/readmore.dart';
import '../../components/Client/CancelOrderComponent.dart';
import '../../components/Client/HeaderWidget.dart';
import '../../components/Client/ReturnOrderComponent.dart';
import '../../main.dart';
import '../../models/CountryListModel.dart';
import '../../models/ExtraChargeRequestModel.dart';
import '../../models/OrderDetailModel.dart';
import '../../models/OrderHistoryModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';
import 'package:flutter/material.dart';
import 'ChatScreen.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String route = '/orderdetail';

  final int? orderId;

  OrderDetailScreen({this.orderId});

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  UserModel? userData;

  OrderModel? orderData;
  List<OrderHistoryModel>? orderHistory;
  Payment? payment;
  List<ExtraChargeRequestModel> list = [];

  VehicleData? vehicleData;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    orderDetailApiCall();
  }

  orderDetailApiCall() async {
    appStore.setLoading(true);
    await orderDetail(orderId: widget.orderId.validate()).then((value) {
      appStore.setLoading(false);
      orderData = value.data!;
      orderHistory = value.orderHistory!;
      payment = value.payment ?? Payment();
      if (orderData!.extraCharges is List<dynamic>) {
        (orderData!.extraCharges as List<dynamic>).forEach((element) {
          list.add(ExtraChargeRequestModel.fromJson(element));
        });
      }
      if (orderData!.deliveryManId != null)
        userDetailApiCall(orderData!.deliveryManId!);
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

  Widget mTitle(String value) {
    return Text(value, style: boldTextStyle());
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

  Widget mParcelDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mTitle(language.parcelDetails),
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
                  mHeadingValue(orderData!.paymentType.validate()).expand(),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  mHeading(language.weight),
                  mHeadingValue(
                      '${orderData!.totalWeight} ${CountryData.fromJson(getJSONAsync(COUNTRY_DATA)).weightType}'),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  mHeading(language.number_of_parcels),
                  mHeadingValue('${orderData!.totalParcel ?? 1}'),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget mPaymentInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mTitle(language.payment_information),
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
                  mHeading(language.payment_type),
                  mHeadingValue(
                      '${paymentType(orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH))}'),
                ],
              ),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  mHeading(language.payment_status),
                  mHeadingValue(
                      '${paymentStatus(orderData!.paymentStatus.validate(value: PAYMENT_PENDING))}'),
                ],
              ),
              16.height.visible(
                  orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH) ==
                      PAYMENT_TYPE_CASH),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  mHeading(language.payment_collect_form),
                  mHeadingValue(
                      '${paymentCollectForm(orderData!.paymentCollectFrom!)}'),
                ],
              ).visible(
                  orderData!.paymentType.validate(value: PAYMENT_TYPE_CASH) ==
                      PAYMENT_TYPE_CASH),
            ],
          ),
        )
      ],
    );
  }

  Widget mAddress({bool isPick = true}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mTitle(isPick ? language.pickup_address : language.delivery_address),
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
                  Row(
                    children: [
                      Icon(Icons.location_on, color: primaryColor),
                      8.width,
                      Text(
                              isPick
                                  ? orderData!.pickupPoint!.address.validate()
                                  : orderData!.deliveryPoint!.address
                                      .validate(),
                              style: primaryTextStyle(size: 14))
                          .expand(),
                    ],
                  ),
                  16.height,
                  Row(
                    children: [
                      Icon(Icons.call, color: Colors.green, size: 18),
                      8.width,
                      Text(
                          isPick
                              ? orderData!.pickupPoint!.contactNumber.validate()
                              : orderData!.deliveryPoint!.contactNumber
                                  .validate(),
                          style: secondaryTextStyle()),
                    ],
                  ),
                  isPick
                      ? Column(
                          children: [
                            if (orderData!.pickupDatetime == null &&
                                orderData!.pickupPoint!.endTime != null &&
                                orderData!.pickupPoint!.startTime != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                    '${language.note} ${language.courierWillPickupAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.pickupPoint!.endTime!).toLocal())}',
                                    style: secondaryTextStyle()),
                              ),
                            if (orderData!.pickupPoint!.description
                                .validate()
                                .isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: ReadMoreText(
                                  '${language.remark}: ${orderData!.pickupPoint!.description.validate()}',
                                  trimLines: 3,
                                  style: primaryTextStyle(size: 14),
                                  colorClickableText: primaryColor,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: language.showMore,
                                  trimExpandedText: language.showLess,
                                ),
                              ),
                          ],
                        )
                      : Column(
                          children: [
                            if (orderData!.deliveryDatetime == null &&
                                orderData!.deliveryPoint!.endTime != null &&
                                orderData!.deliveryPoint!.startTime != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                    '${language.note} ${language.courierWillDeliveredAt} ${DateFormat('dd MMM yyyy').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.from} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.startTime!).toLocal())} ${language.to} ${DateFormat('hh:mm').format(DateTime.parse(orderData!.deliveryPoint!.endTime!).toLocal())}',
                                    style: secondaryTextStyle()),
                              ),
                            if (orderData!.deliveryPoint!.description
                                .validate()
                                .isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: ReadMoreText(
                                  '${language.remark}: ${orderData!.deliveryPoint!.description.validate()}',
                                  trimLines: 3,
                                  style: primaryTextStyle(size: 14),
                                  colorClickableText: primaryColor,
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: language.showMore,
                                  trimExpandedText: language.showLess,
                                ),
                              ),
                          ],
                        )
                ],
              ).expand(),
            ],
          ),
        ),
      ],
    );
  }

  Widget mCharges() {
    return (orderData!.extraCharges is List<dynamic>)
        ? OrderSummeryWidget(
            extraChargesList: list,
            totalDistance: orderData!.totalDistance!,
            totalWeight: orderData!.totalWeight ?? 0,
            distanceCharge: orderData!.distanceCharge ?? 0,
            weightCharge: orderData!.weightCharge ?? 0,
            totalAmount: orderData!.totalAmount!,
            carryPackagesCharge: orderData!.carryPackagesCharge!,
            payment: payment,
            status: orderData!.status,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.delivery_charges, style: primaryTextStyle()),
                  16.width,
                  Text('${printAmount(orderData!.fixedCharges ?? 0)}',
                      style: primaryTextStyle()),
                ],
              ),
              if ((orderData!.distanceCharge ?? 0) != 0)
                Column(
                  children: [
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.distance_charge,
                            style: primaryTextStyle()),
                        16.width,
                        Text('${printAmount(orderData!.distanceCharge ?? 0)}',
                            style: primaryTextStyle()),
                      ],
                    )
                  ],
                ),
              if ((orderData!.weightCharge ?? 0) != 0)
                Column(
                  children: [
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.weight_charge, style: primaryTextStyle()),
                        16.width,
                        Text('${printAmount(orderData!.weightCharge ?? 0)}',
                            style: primaryTextStyle()),
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
                        '${printAmount((orderData!.fixedCharges ?? 0) + (orderData!.distanceCharge ?? 0) + (orderData!.weightCharge ?? 0))}',
                        style: primaryTextStyle()),
                  ],
                ),
              ).visible(((orderData!.distanceCharge ?? 0) != 0 ||
                      (orderData!.weightCharge ?? 0) != 0) &&
                  orderData!.extraCharges.keys.length != 0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(language.extra_charges, style: boldTextStyle()),
                  8.height,
                  Column(
                      children: List.generate(
                          orderData!.extraCharges.keys.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              orderData!.extraCharges.keys
                                  .elementAt(index)
                                  .replaceAll("_", " "),
                              style: primaryTextStyle()),
                          16.width,
                          Text(
                              '${printAmount(orderData!.extraCharges.values.elementAt(index))}',
                              style: primaryTextStyle()),
                        ],
                      ),
                    );
                  }).toList()),
                ],
              ).visible(orderData!.extraCharges.keys.length != 0),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.total, style: boldTextStyle(size: 20)),
                  (orderData!.status == ORDER_CANCELLED &&
                          payment != null &&
                          payment!.deliveryManFee == 0)
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${printAmount(orderData!.totalAmount ?? 0)}',
                                style: secondaryTextStyle(
                                    size: 16,
                                    decoration: TextDecoration.lineThrough)),
                            8.width,
                            Text('${printAmount(payment!.cancelCharges ?? 0)}',
                                style: boldTextStyle(size: 20)),
                          ],
                        )
                      : Text('${printAmount(orderData!.totalAmount ?? 0)}',
                          style: boldTextStyle(size: 20)),
                ],
              ),
            ],
          );
  }

  Widget mVehicle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.vehicle, style: boldTextStyle()),
        Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.all(16),
          decoration: containerDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.vehicle_name, style: primaryTextStyle()),
              Text('${orderData!.vehicleData!.title.validate()}',
                  style: primaryTextStyle())
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        finish(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            HeaderWidget(),
            Stack(
              children: [
                if (orderData != null)
                  SingleChildScrollView(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Container(
                          width: ResponsiveWidget.isLessMediumScreen(context)
                              ? context.width() * 0.8
                              : context.width() * 0.5,
                          decoration: boxDecorationRoundedWithShadow(
                              defaultRadius.toInt(),
                              backgroundColor: accentColor),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: radiusOnly(
                                        topLeft: defaultRadius,
                                        topRight: defaultRadius),
                                    backgroundColor: primaryColor),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(language.order_id,
                                                style: boldTextStyle(
                                                    color: Colors.white)),
                                            10.width,
                                            Text('#${orderData!.id}',
                                                style: boldTextStyle(
                                                    color: Colors.white)),
                                          ],
                                        ),
                                        8.height,
                                        Text(printDate(orderData!.date!),
                                            style: secondaryTextStyle(
                                                color: Colors.white60)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        orderData!.status != ORDER_DELIVERED &&
                                                orderData!.status !=
                                                    ORDER_CANCELLED
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6),
                                                decoration:
                                                    boxDecorationWithRoundedCorners(
                                                        border: Border.all(
                                                            color: borderColor),
                                                        borderRadius:
                                                            radius(20)),
                                                child: Text(
                                                    language.cancelOrder,
                                                    style: boldTextStyle(
                                                        color: primaryColor,
                                                        size: 14)),
                                              ).onTap(() {
                                                showDialog(
                                                    context: context,
                                                    builder: (_) {
                                                      return CancelOrderComponent(
                                                          orderId: orderData!.id
                                                              .validate(),
                                                          onUpdate: () {
                                                            orderDetailApiCall();
                                                          });
                                                    });
                                              })
                                            : SizedBox(),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration:
                                              boxDecorationWithRoundedCorners(
                                                  border: Border.all(
                                                      color: borderColor),
                                                  borderRadius: radius(20)),
                                          child: Text(language.returnOrder,
                                              style: boldTextStyle(
                                                  color: primaryColor,
                                                  size: 14)),
                                        ).onTap(() {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ReturnOrderComponent(
                                                  orderData!, onUpdate: () {
                                                orderDetailApiCall();
                                              });
                                            },
                                          );
                                        }).visible(orderData!.status ==
                                                ORDER_DELIVERED &&
                                            !orderData!.returnOrderId! &&
                                            getStringAsync(USER_TYPE) ==
                                                CLIENT),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  22.height,
                                  !ResponsiveWidget.isSmallScreen(context)
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            mParcelDetail().expand(),
                                            16.width,
                                            mPaymentInformation().expand(),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            mParcelDetail(),
                                            16.height,
                                            mPaymentInformation(),
                                          ],
                                        ),
                                  22.height,
                                  !ResponsiveWidget.isSmallScreen(context)
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            mAddress().expand(),
                                            16.width,
                                            mAddress(isPick: false).expand(),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            mAddress(),
                                            16.height,
                                            mAddress(isPick: false),
                                          ],
                                        ),
                                  22.height,
                                  if (orderData!.vehicleData != null)
                                    mVehicle(),
                                  22.height,
                                  if (orderData!.reason.validate().isNotEmpty &&
                                      orderData!.status != ORDER_CANCELLED)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(language.returnedReason,
                                            style: boldTextStyle()),
                                        12.height,
                                        Container(
                                          width: context.width(),
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: EdgeInsets.all(12),
                                          child: Text(
                                              '${orderData!.reason.validate(value: "-")}',
                                              style: primaryTextStyle(
                                                  color: Colors.red)),
                                        ),
                                        22.height,
                                      ],
                                    ),
                                  if (orderData!.status == ORDER_CANCELLED)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(language.cancelledReason,
                                            style: boldTextStyle()),
                                        12.height,
                                        Container(
                                          width: context.width(),
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: EdgeInsets.all(12),
                                          child: Text(
                                              '${orderData!.reason.validate(value: "-")}',
                                              style: primaryTextStyle(
                                                  color: Colors.red)),
                                        ),
                                        22.height,
                                      ],
                                    ),
                                  mCharges(),
                                  22.height,
                                ],
                              ).paddingSymmetric(horizontal: 16),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveWidget.isLessMediumScreen(context)
                              ? context.width() * 0.8
                              : context.width() * 0.22,
                          child: Column(
                            children: [
                              if (userData != null)
                                Container(
                                  decoration: boxDecorationRoundedWithShadow(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: radiusOnly(
                                                topLeft: 8, topRight: 8)),
                                        padding: EdgeInsets.all(16),
                                        child: Text(language.aboutDeliveryMan,
                                            style: boldTextStyle(
                                                color: Colors.white)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60),
                                                    child:
                                                        commonCachedNetworkImage(
                                                            userData!
                                                                .profileImage
                                                                .validate(),
                                                            height: 60,
                                                            width: 60,
                                                            fit: BoxFit.cover,
                                                            alignment: Alignment
                                                                .center)),
                                                SizedBox(width: 16),
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
                                                            launchUrlWidget(
                                                                'tel:${userData!.contactNumber}');
                                                          })
                                                        : SizedBox()
                                                  ],
                                                ).expand(),
                                                IconButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              ChatScreen.route +
                                                                  "?user_Id=${userData!.id}");
                                                        },
                                                        icon: Icon(Icons.chat))
                                                    .visible(orderData!
                                                                .status !=
                                                            ORDER_DELIVERED &&
                                                        orderData!.status !=
                                                            ORDER_CANCELLED)
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 16.0),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.email_outlined,
                                                      color: primaryColor),
                                                  SizedBox(width: 16),
                                                  Text(
                                                      userData!.email
                                                          .validate(),
                                                      style:
                                                          primaryTextStyle()),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (userData != null) 16.height,
                              Container(
                                decoration: boxDecorationRoundedWithShadow(8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: radiusOnly(
                                              topRight: 8, topLeft: 8)),
                                      padding: EdgeInsets.all(16),
                                      child: Text(language.orderHistory,
                                          style: boldTextStyle(
                                              color: Colors.white)),
                                    ),
                                    OrderHistoryComponent(
                                        orderHistory: orderHistory.validate()),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ).paddingSymmetric(
                        horizontal: ResponsiveWidget.isLessMediumScreen(context)
                            ? mCommonPadding1(context)
                            : mCommonPadding(context),
                        vertical: 16),
                  ),
                appStore.isLoading
                    ? loaderWidget()
                    : orderData == null
                        ? emptyWidget()
                        : SizedBox(),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
