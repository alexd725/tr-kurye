import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/Admin/MonthlyOrderCountComponent.dart';
import '../../components/Admin/MonthlyPaymentCountComponent.dart';
import 'DeliveryBoyScreen.dart';
import 'UserScreen.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '/../screens/Client/DashboardScreen.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../models/DashboardModel.dart';
import '/../models/models.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/DataProvider.dart';
import '/../utils/Extensions/live_stream.dart';
import '/../utils/Extensions/string_extensions.dart';
import '/../main.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/text_styles.dart';
import '../../components/Admin/HomeWidgetUserList.dart';
import '../../components/Admin/TotalUserWidget.dart';
import '../../components/Admin/WeeklyOrderCountComponent.dart';

class AdminHomeScreen extends StatefulWidget {
  static String route = '/admin/dashboard';

  @override
  AdminHomeScreenState createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  List<MenuItemModel> menuList = getMenuItems();

  ScrollController scrollController = ScrollController();
  ScrollController recentOrderController = ScrollController();
  ScrollController recentOrderHorizontalController = ScrollController();
  ScrollController upcomingOrderController = ScrollController();
  ScrollController upcomingOrderHorizontalController = ScrollController();
  ScrollController userController = ScrollController();
  ScrollController userHorizontalController = ScrollController();
  ScrollController deliveryBoyController = ScrollController();
  ScrollController deliveryBoyHorizontalController = ScrollController();

  List<WeeklyOrderCount> userWeeklyCount = [];
  List<WeeklyOrderCount> weeklyOrderCount = [];
  List<WeeklyOrderCount> weeklyPaymentReport = [];

  List<MonthlyOrderCount> monthlyOrderCount = [];
  List<MonthlyPaymentCompletedReport> monthlyCompletePaymentReport = [];
  List<MonthlyPaymentCompletedReport> monthlyCancelPaymentReport = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(DASHBOARD_INDEX);
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? currencyCodeDefault);
      appStore.setCurrencySymbol(value.currency ?? currencySymbolDefault);
      appStore.setCurrencyPosition(
          value.currencyPosition ?? CURRENCY_POSITION_LEFT);
      appStore.isShowVehicle = value.isVehicleInOrder ?? 0;

      log('********************${appStore.isShowVehicle}');
      // (appStore.isShowVehicle == 1) ? true : false;
      // appStore.isShowVehicle(value.isVehicleInOrder ?? 0);
    }).catchError((error) {
      log(error.toString());
    });
    firebaseOnMessage();
    LiveStream().on(streamLanguage, (p0) {
      menuList.clear();
      menuList = getMenuItems();
      setState(() {});
    });
    LiveStream().on(streamDarkMode, (p0) {
      setState(() {});
    });
  }

  void firebaseOnMessage() {
    FirebaseMessaging.onMessage.listen((event) async {
      ElegantNotification.info(
        title: Text(event.notification!.title.validate(),
            style: boldTextStyle(color: primaryColor, size: 18)),
        description: Text(event.notification!.body.validate(),
            style: primaryTextStyle(color: Colors.black, size: 16)),
        notificationPosition: NotificationPosition.topCenter,
        autoDismiss: true,
        animation: AnimationType.fromTop,
        showProgressIndicator: false,
        width: 400,
        height: 100,
        toastDuration: Duration(seconds: 10),
        iconSize: 0,
      ).show(context);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void callMethod(int count) {
    afterBuildCreated(() => appStore.setAllUnreadCount(count));
  }

  double? getChartWidth() {
    return ResponsiveWidget.isSmallScreen(context)
        ? null
        : (getBodyWidth(context) - 40) * 0.5;
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveWidget.isSmallScreen(context)) {
      appStore.setExpandedMenu(false);
    } else {
      appStore.setExpandedMenu(true);
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, DashboardScreen.route);
        return false;
      },
      child: BodyCornerWidget(
        child: Stack(
          children: [
            FutureBuilder<DashboardModel>(
              future: getDashBoardData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  userWeeklyCount = snapshot.data!.userWeeklyCount ?? [];
                  weeklyOrderCount = snapshot.data!.weeklyOrderCount ?? [];
                  weeklyPaymentReport =
                      snapshot.data!.weeklyPaymentReport ?? [];
                  monthlyOrderCount = snapshot.data!.monthlyOrderCount ?? [];
                  monthlyCompletePaymentReport =
                      snapshot.data!.monthlyPaymentCompletedReport ?? [];
                  monthlyCancelPaymentReport =
                      snapshot.data!.monthlyPaymentCancelledReport ?? [];

                  callMethod(snapshot.data!.allUnreadCount ?? 0);
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            TotalUserWidget(
                                title: language.total_order,
                                totalCount: snapshot.data!.totalOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.createdOrder,
                                totalCount: snapshot.data!.totalCreateOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.assignedOrder,
                                totalCount:
                                    snapshot.data!.totalCourierAssignedOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.acceptedOrder,
                                totalCount: snapshot.data!.totalActiveOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.arrivedOrder,
                                totalCount:
                                    snapshot.data!.totalCourierArrivedOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.pickedOrder,
                                totalCount:
                                    snapshot.data!.totalCourierPickedUpOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.departedOrder,
                                totalCount:
                                    snapshot.data!.totalCourierDepartedOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.deliveredOrder,
                                totalCount: snapshot.data!.totalCompletedOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.cancelledOrder,
                                totalCount: snapshot.data!.totalCancelledOrder,
                                image: 'assets/icons/ic_orders.png'),
                            TotalUserWidget(
                                title: language.total_user,
                                totalCount: snapshot.data!.totalClient,
                                image: 'assets/icons/ic_users.png'),
                            TotalUserWidget(
                                title: language.total_delivery_person,
                                totalCount: snapshot.data!.totalDeliveryMan,
                                image: 'assets/icons/ic_users.png'),
                          ],
                        ),
                        SizedBox(height: 16),
                        ResponsiveWidget.isLargeScreen(context)
                            ? Row(
                                children: [
                                  Expanded(
                                      child: WeeklyOrderCountComponent(
                                          weeklyOrderCount: weeklyOrderCount)),
                                  SizedBox(width: 16),
                                  Expanded(
                                      child: MonthlyOrderCountComponent(
                                          monthlyCount: monthlyOrderCount,
                                          isPaymentType: false)),
                                ],
                              )
                            : Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(
                                      width: getChartWidth(),
                                      child: WeeklyOrderCountComponent(
                                          weeklyOrderCount: weeklyOrderCount)),
                                  SizedBox(
                                      width: getChartWidth(),
                                      child: MonthlyOrderCountComponent(
                                          monthlyCount: monthlyOrderCount)),
                                ],
                              ),
                        SizedBox(height: 16),
                        MonthlyPaymentCountComponent(
                            monthlyCompletePayment:
                                monthlyCompletePaymentReport,
                            monthlyCancelPayment: monthlyCancelPaymentReport,
                            isPaymentType: true),
                        SizedBox(height: 16),
                        Wrap(
                          runSpacing: 16,
                          spacing: 16,
                          children: [
                            snapshot.data!.recentOrder!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(context),
                                    width: getTableWidth(context),
                                    child: SingleChildScrollView(
                                      controller: recentOrderController,
                                      padding:
                                          EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(language.recent_order,
                                              style: boldTextStyle(
                                                  color: primaryColor)),
                                          RawScrollbar(
                                            scrollbarOrientation:
                                                ScrollbarOrientation.bottom,
                                            controller:
                                                recentOrderHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode
                                                ? Colors.white12
                                                : Colors.black12,
                                            radius:
                                                Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller:
                                                  recentOrderHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.only(
                                                  bottom: 16, top: 16),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minWidth:
                                                        getTableWidth(context)),
                                                child: DataTable(
                                                  headingTextStyle:
                                                      boldTextStyle(),
                                                  dataTextStyle:
                                                      primaryTextStyle(
                                                          size: 15),
                                                  headingRowColor:
                                                      MaterialStateColor
                                                          .resolveWith((states) =>
                                                              primaryColor
                                                                  .withOpacity(
                                                                      0.1)),
                                                  showCheckboxColumn: false,
                                                  dataRowHeight: 45,
                                                  headingRowHeight: 45,
                                                  horizontalMargin: 16,
                                                  columns: [
                                                    DataColumn(
                                                        label: Text(
                                                            language.order_id)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .customer_name)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .delivery_person)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .pickup_date)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .created_date)),
                                                    DataColumn(
                                                        label: Text(
                                                            language.status)),
                                                  ],
                                                  rows: snapshot
                                                      .data!.recentOrder!
                                                      .map((e) {
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                            Text('${e.id}')),
                                                        DataCell(Text(
                                                            e.clientName ??
                                                                "-")),
                                                        DataCell(Text(
                                                            e.deliveryManName ??
                                                                "-")),
                                                        DataCell(Text(e
                                                                    .pickupPoint!
                                                                    .startTime !=
                                                                null
                                                            ? printDate(e
                                                                .pickupPoint!
                                                                .startTime!)
                                                            : '-')),
                                                        DataCell(Text(e
                                                            .readableDate
                                                            .toString())),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Text(
                                                                orderStatus(e
                                                                    .status
                                                                    .validate()),
                                                                style: boldTextStyle(
                                                                    color: statusColor(
                                                                        e.status ??
                                                                            ""),
                                                                    size: 15)),
                                                            decoration: BoxDecoration(
                                                                color: statusColor(
                                                                        e.status ??
                                                                            "")
                                                                    .withOpacity(
                                                                        0.15),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            defaultRadius)),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode
                                          ? scaffoldColorDark
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                            snapshot.data!.upcomingOrder!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(context),
                                    width: getTableWidth(context),
                                    child: SingleChildScrollView(
                                      controller: upcomingOrderController,
                                      padding:
                                          EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(language.upcoming_order,
                                              style: boldTextStyle(
                                                  color: primaryColor)),
                                          RawScrollbar(
                                            scrollbarOrientation:
                                                ScrollbarOrientation.bottom,
                                            controller:
                                                upcomingOrderHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode
                                                ? Colors.white12
                                                : Colors.black12,
                                            radius:
                                                Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller:
                                                  upcomingOrderHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.only(
                                                  bottom: 16, top: 16),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minWidth:
                                                        getTableWidth(context)),
                                                child: DataTable(
                                                  headingTextStyle:
                                                      boldTextStyle(),
                                                  dataTextStyle:
                                                      primaryTextStyle(
                                                          size: 15),
                                                  headingRowColor:
                                                      MaterialStateColor
                                                          .resolveWith((states) =>
                                                              primaryColor
                                                                  .withOpacity(
                                                                      0.1)),
                                                  showCheckboxColumn: false,
                                                  dataRowHeight: 45,
                                                  headingRowHeight: 45,
                                                  horizontalMargin: 16,
                                                  columns: [
                                                    DataColumn(
                                                        label: Text(
                                                            language.order_id)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .customer_name)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .delivery_person)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .pickup_date)),
                                                    DataColumn(
                                                        label: Text(language
                                                            .created_date)),
                                                    DataColumn(
                                                        label: Text(
                                                            language.status)),
                                                  ],
                                                  rows: snapshot
                                                      .data!.upcomingOrder!
                                                      .map((e) {
                                                    return DataRow(
                                                      cells: [
                                                        DataCell(
                                                            Text('${e.id}')),
                                                        DataCell(Text(
                                                            e.clientName ??
                                                                "-")),
                                                        DataCell(Text(
                                                            e.deliveryManName ??
                                                                "-")),
                                                        DataCell(Text(e
                                                                    .pickupPoint!
                                                                    .startTime !=
                                                                null
                                                            ? printDate(e
                                                                .pickupPoint!
                                                                .startTime!)
                                                            : '-')),
                                                        DataCell(Text(e
                                                            .readableDate
                                                            .toString())),
                                                        DataCell(
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    6),
                                                            child: Text(
                                                                orderStatus(e
                                                                    .status
                                                                    .validate()),
                                                                style: boldTextStyle(
                                                                    color: statusColor(
                                                                        e.status ??
                                                                            ""),
                                                                    size: 15)),
                                                            decoration: BoxDecoration(
                                                                color: statusColor(
                                                                        e.status ??
                                                                            "")
                                                                    .withOpacity(
                                                                        0.15),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            defaultRadius)),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode
                                          ? scaffoldColorDark
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                            snapshot.data!.recentClient!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(context),
                                    width: getTableWidth(context),
                                    child: SingleChildScrollView(
                                      controller: userController,
                                      padding:
                                          EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.recent_user,
                                                  style: boldTextStyle(
                                                      color: primaryColor)),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context,
                                                      UsersScreen.route);
                                                },
                                                child: Text(language.view_all,
                                                    style: boldTextStyle(
                                                        color: primaryColor)),
                                              ),
                                            ],
                                          ),
                                          RawScrollbar(
                                            scrollbarOrientation:
                                                ScrollbarOrientation.bottom,
                                            controller:
                                                userHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode
                                                ? Colors.white12
                                                : Colors.black12,
                                            radius:
                                                Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller:
                                                  userHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.only(
                                                  bottom: 16, top: 16),
                                              child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      minWidth: getTableWidth(
                                                          context)),
                                                  child: HomeWidgetUserList(
                                                      userModel: snapshot.data!
                                                          .recentClient!)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode
                                          ? scaffoldColorDark
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                            snapshot.data!.recentDeliveryMan!.isNotEmpty
                                ? Container(
                                    height: getTableHeight(context),
                                    width: getTableWidth(context),
                                    child: SingleChildScrollView(
                                      controller: deliveryBoyController,
                                      padding:
                                          EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.recent_delivery,
                                                  style: boldTextStyle(
                                                      color: primaryColor)),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushNamed(context,
                                                      DeliveryBoyScreen.route);
                                                },
                                                child: Text(language.view_all,
                                                    style: boldTextStyle(
                                                        color: primaryColor)),
                                              )
                                            ],
                                          ),
                                          RawScrollbar(
                                            scrollbarOrientation:
                                                ScrollbarOrientation.bottom,
                                            controller:
                                                deliveryBoyHorizontalController,
                                            thumbVisibility: true,
                                            thumbColor: appStore.isDarkMode
                                                ? Colors.white12
                                                : Colors.black12,
                                            radius:
                                                Radius.circular(defaultRadius),
                                            child: SingleChildScrollView(
                                              controller:
                                                  deliveryBoyHorizontalController,
                                              scrollDirection: Axis.horizontal,
                                              padding: EdgeInsets.only(
                                                  bottom: 16, top: 16),
                                              child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      minWidth: getTableWidth(
                                                          context)),
                                                  child: HomeWidgetUserList(
                                                      userModel: snapshot.data!
                                                          .recentDeliveryMan!)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: commonBoxShadow(),
                                      color: appStore.isDarkMode
                                          ? scaffoldColorDark
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(defaultRadius),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        SizedBox(height: 80)
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  print(
                      'Error occurred at line ${StackTrace.current}: ${snapshot.error}');
                  print('Error is _____: ${snapshot.error}');

                  return emptyWidget();
                }
                return loaderWidget();
              },
            ),
            Observer(
                builder: (context) => Visibility(
                    visible: appStore.isLoading, child: loaderWidget())),
          ],
        ),
      ),
    );
  }
}
