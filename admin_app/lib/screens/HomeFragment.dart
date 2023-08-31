import 'package:flutter/material.dart';
import '../components/MonthlyOrderCountComponent.dart';
import '../components/MonthlyPaymentCountComponent.dart';
import 'package:mightydelivery_admin_app/models/DashboardModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/LiveStream.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../components/OrderWidgetComponent.dart';
import '../components/WeeklyOrderCountComponent.dart';
//import '../components/WeeklyUserCountComponent.dart';
import '../main.dart';
import '../utils/Common.dart';

class HomeFragment extends StatefulWidget {
  static String tag = '/AppHomeWidget';

  @override
  HomeFragmentState createState() => HomeFragmentState();
}

class HomeFragmentState extends State<HomeFragment> {
  ScrollController scrollController = ScrollController();
  ScrollController recentOrderController = ScrollController();
  ScrollController recentOrderHorizontalController = ScrollController();
  ScrollController upcomingOrderController = ScrollController();
  ScrollController upcomingOrderHorizontalController = ScrollController();
  ScrollController userController = ScrollController();
  ScrollController userHorizontalController = ScrollController();
  ScrollController deliveryBoyController = ScrollController();
  ScrollController deliveryBoyHorizontalController = ScrollController();

  /*List<WeeklyDataModel> userWeeklyCount = [];
  List<WeeklyDataModel> weeklyOrderCount = [];
  List<WeeklyDataModel> weeklyPaymentReport = [];*/

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
    LiveStream().on(streamDarkMode, (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void callMethod(int count) {
    afterBuildCreated(() => appStore.setAllUnreadCount(count));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardModel>(
      future: getDashBoardData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          userWeeklyCount = snapshot.data!.userWeeklyCount ?? [];
          weeklyOrderCount = snapshot.data!.weeklyOrderCount ?? [] ;
          weeklyPaymentReport = snapshot.data!.weeklyPaymentReport ?? [];
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
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    totalUserWidget(context,
                        title: language.totalUser,
                        totalCount: snapshot.data!.totalClient,
                        bgColor: Color(0xFFC8FACD),
                        color: Color(0xFF2A956D)),
                    totalUserWidget(context,
                        title: language.totalDeliveryPerson,
                        totalCount: snapshot.data!.totalDeliveryMan,
                        bgColor: Color(0xFFD0F2FF),
                        color: Color(0xFF0D3380)),
                    totalUserWidget(context,
                        title: language.totalCountry,
                        totalCount: snapshot.data!.totalCountry,
                       // totalCount: 2,
                        bgColor: Color(0xFFFFE7D9),
                        color: Color(0xFF6D001E)),
                    totalUserWidget(context,
                        title: language.totalCity,
                         totalCount: snapshot.data!.totalCity,
                       // totalCount: 2,
                        bgColor: Color(0xFFfadee8),
                        color: Color(0xFFb51f4f)),
                    totalUserWidget(context,
                        title: language.totalOrder,
                        totalCount: snapshot.data!.totalOrder,
                        bgColor: Color(0xFFFFF7CD),
                        color: Color(0xFFB17700)),
                    totalUserWidget(context,
                        title: 'Created order',
                        totalCount: snapshot.data!.totalCreateOrder),
                    totalUserWidget(context,
                        title: 'Accepted Order',
                        totalCount: snapshot.data!.totalActiveOrder),
                    //totalUserWidget(context,title: 'Rejected Order', totalCount: snapshot.data!.tor),
                    totalUserWidget(context,
                        title: 'Picked Order',
                        totalCount: snapshot.data!.totalCourierPickedUpOrder),
                    //totalUserWidget(context,title: 'InTransit Order', totalCount: snapshot.data!.in),
                    //totalUserWidget(context,title: 'In Hub order', totalCount: snapshot.data!.totalOrder),
                    //totalUserWidget(context,title: 'OFD Order', totalCount: snapshot.data!.totalDeliveryMan),
                    //totalUserWidget(context,title: 'Rescheduled Order', totalCount: snapshot.data),
                    totalUserWidget(context,
                        title: 'Delivered Order',
                        totalCount: snapshot.data!.totalCompletedOrder),
                    totalUserWidget(context,
                        title: 'Cancel Order',
                        totalCount: snapshot.data!.totalCancelledOrder),
                  ],
                ),
                SizedBox(height: 16),
                WeeklyOrderCountComponent(weeklyOrderCount: weeklyOrderCount),
                SizedBox(height: 16),
                //  WeeklyUserCountComponent(weeklyCount: userWeeklyCount),
                MonthlyOrderCountComponent(monthlyCount: monthlyOrderCount),
                SizedBox(height: 16),
                //  WeeklyUserCountComponent(weeklyCount: weeklyPaymentReport,isTypePayment: true),
                MonthlyPaymentCountComponent(
                    monthlyCompletePayment: monthlyCompletePaymentReport,
                    monthlyCancelPayment: monthlyCancelPaymentReport,
                    isPaymentType: true),
                SizedBox(height: 16),
                snapshot.data!.recentOrder!.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.only(left: 12, top: 12, right: 12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: containerDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.recentOrder,
                                style: boldTextStyle(color: primaryColor)),
                            SizedBox(height: 16),
                            ListView.builder(
                                primary: true,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.recentOrder!.length,
                                itemBuilder: (context, i) {
                                  return orderWidget(
                                      context, snapshot.data!.recentOrder![i]);
                                }),
                          ],
                        ),
                      )
                    : SizedBox(),
                snapshot.data!.upcomingOrder!.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.only(left: 12, top: 12, right: 12),
                        decoration: containerDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.upcomingOrder,
                                style: boldTextStyle(color: primaryColor)),
                            SizedBox(height: 20),
                            ListView.builder(
                                primary: true,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.upcomingOrder!.length,
                                itemBuilder: (context, i) {
                                  return orderWidget(context,
                                      snapshot.data!.upcomingOrder![i]);
                                })
                          ],
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return emptyWidget();
        }
        return loaderWidget();
      },
    );
  }
}
