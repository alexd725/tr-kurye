import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_delivery_admin/models/VehicleListModel.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/Admin/GenerateInvoice.dart';
import '../../components/Admin/OrderDetailComponent.dart';
import '../../components/Client/OrderHistoryComponent.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../main.dart';
import '../../models/OrderDetailModel.dart';
import '../../models/OrderHistoryModel.dart';
import '../../models/UserModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../network/CommonApiCall.dart';
import '../../utils/Constants.dart';
import '../../models/ExtraChargeRequestModel.dart';
import '../../models/OrderModel.dart';
import '../../utils/Extensions/live_stream.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  static String route = '/admin/orderdetail';
  final int orderId;

  AdminOrderDetailScreen({required this.orderId});

  @override
  AdminOrderDetailScreenState createState() => AdminOrderDetailScreenState();
}

class AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> with SingleTickerProviderStateMixin {
  OrderModel? orderModel;
  List<OrderHistoryModel> orderHistory = [];
  Payment? payment;
  VehicleData? vehicleData;

  List<ExtraChargeRequestModel> extraChargeForListType = [];
  bool extraChargeTypeIsList = true;

  List<String> tabList = [language.order_detail, language.orderHistory];

  int selectedTab = 0;

  UserModel? userData;
  UserModel? deliveryManData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await getAllCountryApiCall();
    await orderDetailApiCall();
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
      if (value.data!.deliveryManId != null) await userDetailApiCall(value.data!.deliveryManId!);
      if (value.data!.clientId != null) await userDetailApiCall(value.data!.clientId!);
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
    appStore.setLoading(true);
    await getUserDetail(id).then((value) {
      appStore.setLoading(false);
      if (value.userType == DELIVERYMAN) {
        deliveryManData = value;
      } else {
        userData = value;
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget orderDetailWidget() {
      return DefaultTabController(
        length: tabList.length,
        initialIndex: selectedTab,
        child: Builder(builder: (context) {
          final TabController? tabController = DefaultTabController.of(context);
          tabController!.addListener(() {
            if (!tabController.indexIsChanging) {
              setState(() => selectedTab = tabController.index);
            }
          });
          return Container(
            decoration: BoxDecoration(
              boxShadow: commonBoxShadow(),
              color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius)),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                  child: TabBar(
                    indicatorColor: Colors.transparent,
                    tabs: tabList.map((item) {
                      int index = tabList.indexOf(item);
                      return Container(
                        margin: EdgeInsets.only(right: index < tabList.length - 1 ? 30 : 0),
                        child: Text(item, style: boldTextStyle(color: selectedTab == index ? primaryColor : null)),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedTab == index ? Theme.of(context).cardColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(defaultRadius),
                        ),
                        alignment: Alignment.center,
                      );
                    }).toList(),
                    onTap: (index) {
                      selectedTab = index;
                      setState(() {});
                    },
                  ),
                ),
                selectedTab == 0 ? OrderDetailComponent(orderModel: orderModel!, payment: payment, vehicleData: vehicleData, extraChargeForListType: extraChargeForListType) : OrderHistoryComponent(orderHistory: orderHistory),
              ],
            ),
          );
        }),
      );
    }

    Widget aboutUserWidget() {
      return ListView(
        shrinkWrap: true,
        controller: ScrollController(),
        children: [
          if (userData != null)
            Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                boxShadow: commonBoxShadow(),
                color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(language.aboutUser, style: boldTextStyle()),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: commonCachedNetworkImage(userData!.profileImage ?? "", height: 60, width: 60, fit: BoxFit.cover, alignment: Alignment.center)),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('${userData!.name}', style: boldTextStyle()),
                                  userData!.contactNumber != null
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text('${userData!.contactNumber}', style: secondaryTextStyle()),
                                        )
                                      : SizedBox()
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (userData!.email != null)
                          Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined, color: primaryColor),
                                SizedBox(width: 16),
                                Text('${userData!.email}', style: primaryTextStyle()),
                              ],
                            ),
                          ),
                        if (userData!.address != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: primaryColor),
                                SizedBox(width: 16),
                                Text('${userData!.address}', style: primaryTextStyle()),
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
            Container(
              decoration: BoxDecoration(
                boxShadow: commonBoxShadow(),
                color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                borderRadius: BorderRadius.circular(defaultRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(language.aboutDeliveryMan, style: boldTextStyle()),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: commonCachedNetworkImage(deliveryManData!.profileImage ?? "", height: 60, width: 60, fit: BoxFit.cover, alignment: Alignment.center)),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('${deliveryManData!.name}', style: boldTextStyle()),
                                  deliveryManData!.contactNumber != null
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text('${deliveryManData!.contactNumber}', style: secondaryTextStyle()),
                                        )
                                      : SizedBox()
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (deliveryManData!.email != null)
                          Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined, color: primaryColor),
                                SizedBox(width: 16),
                                Text('${deliveryManData!.email}', style: primaryTextStyle()),
                              ],
                            ),
                          ),
                        if (deliveryManData!.address != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: primaryColor),
                                SizedBox(width: 16),
                                Text('${deliveryManData!.address}', style: primaryTextStyle()),
                              ],
                            ),
                          ),
                        if (deliveryManData!.isVerifiedDeliveryMan == 1) SizedBox(height: 8),
                        if (deliveryManData!.isVerifiedDeliveryMan == 1)
                          Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.green),
                              SizedBox(width: 8),
                              Text(language.verified, style: primaryTextStyle(color: Colors.green)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        finish(context, true);
        return false;
      },
      child: BodyCornerWidget(
        child: Observer(builder: (context) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (orderModel != null && orderModel!.status != ORDER_CANCELLED)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: primaryColor,
                                  padding: EdgeInsets.all(6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: primaryColor)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(language.invoiceCapital, style: primaryTextStyle(color: Colors.white)),
                                    Icon(Icons.download_outlined, color: Colors.white),
                                  ],
                                ),
                                onPressed: () async {
                                  generateInvoiceCall(orderModel!);
                                },
                              ),
                            SizedBox(width: 16),
                            backButton(context, value: true),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      if (orderModel != null)
                        ResponsiveWidget.isLargeScreen(context)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: orderDetailWidget()),
                                  SizedBox(width: 16),
                                  Expanded(child: aboutUserWidget()),
                                ],
                              )
                            : Column(
                                children: [
                                  orderDetailWidget(),
                                  SizedBox(height: 16),
                                  aboutUserWidget(),
                                ],
                              ),
                      SizedBox(height: 80)
                    ],
                  ),
                ),
              ),
              Visibility(visible: appStore.isLoading, child: loaderWidget()),
            ],
          );
        }),
      ),
    );
  }
}
