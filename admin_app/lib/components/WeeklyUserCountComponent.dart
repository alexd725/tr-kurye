import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/DashboardModel.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../utils/Common.dart';

class WeeklyUserCountComponent extends StatefulWidget {
  static String tag = '/WeeklyUserCountComponent';
  final List<WeeklyOrderCount> weeklyCount;
  final bool isTypePayment;

  WeeklyUserCountComponent(
      {required this.weeklyCount, this.isTypePayment = false});

  @override
  WeeklyUserCountComponentState createState() =>
      WeeklyUserCountComponentState();
}

class WeeklyUserCountComponentState extends State<WeeklyUserCountComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      height: 350,
      decoration: containerDecoration(),
      child: SfCartesianChart(
        title: ChartTitle(
            text: widget.isTypePayment
                ? language.weeklyPaymentReport
                : language.weeklyUserCount,
            textStyle: boldTextStyle(color: primaryColor)),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries>[
          StackedColumnSeries<WeeklyOrderCount, String>(
            color: primaryColor,
            enableTooltip: true,
            markerSettings: MarkerSettings(isVisible: true),
            dataSource: widget.weeklyCount,
            xValueMapper: (WeeklyOrderCount exp, _) => exp.day,
            yValueMapper: (WeeklyOrderCount exp, _) =>
                widget.isTypePayment ? exp.totalAmount : exp.total,
          ),
        ],
        primaryXAxis: CategoryAxis(isVisible: true),
      ),
    );
  }
}
