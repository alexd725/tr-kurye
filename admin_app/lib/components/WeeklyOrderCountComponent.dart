import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/DashboardModel.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../utils/Common.dart';

class WeeklyOrderCountComponent extends StatefulWidget {
  static String tag = '/WeeklyOrderCountComponent';
  final List<WeeklyOrderCount> weeklyOrderCount;

  WeeklyOrderCountComponent({required this.weeklyOrderCount});

  @override
  WeeklyOrderCountComponentState createState() =>
      WeeklyOrderCountComponentState();
}

class WeeklyOrderCountComponentState extends State<WeeklyOrderCountComponent> {
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
      height: 300,
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        title: ChartTitle(
            text: language.weeklyOrderCount,
            textStyle: boldTextStyle(color: primaryColor)),
        tooltipBehavior: TooltipBehavior(enable: true),
        legend:
            Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
        series: <CircularSeries>[
          PieSeries<WeeklyOrderCount, String>(
              dataSource: widget.weeklyOrderCount,
              xValueMapper: (WeeklyOrderCount data, _) => data.day,
              yValueMapper: (WeeklyOrderCount data, _) => data.total,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true, textStyle: boldTextStyle()))
        ],
      ),
      decoration: containerDecoration(),
    );
  }
}
