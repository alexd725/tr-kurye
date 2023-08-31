import 'package:flutter/material.dart';
import '/../main.dart';
import '/../models/DashboardModel.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/text_styles.dart';

class WeeklyUserCountComponent extends StatefulWidget {
  static String tag = '/WeeklyUserCountComponent';
  final List<WeeklyOrderCount> weeklyCount;
  final bool isPaymentType;

  WeeklyUserCountComponent({required this.weeklyCount, this.isPaymentType = false});

  @override
  WeeklyUserCountComponentState createState() => WeeklyUserCountComponentState();
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
      padding: EdgeInsets.all(16),
      height: 350,
      child: SfCartesianChart(
        title: ChartTitle(text: widget.isPaymentType ? language.weeklyPaymentReport : language.weekly_user_count, textStyle: boldTextStyle(color: primaryColor)),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries>[
          StackedColumnSeries<WeeklyOrderCount, String>(
            color: primaryColor,
            enableTooltip: true,
            markerSettings: MarkerSettings(isVisible: true),
            dataSource: widget.weeklyCount,
            xValueMapper: (WeeklyOrderCount exp, _) => dayTranslate(exp.day!),
            yValueMapper: (WeeklyOrderCount exp, _) => widget.isPaymentType ? exp.totalAmount : exp.total,
          ),
        ],
        primaryXAxis: CategoryAxis(isVisible: true),
      ),
      decoration: BoxDecoration(
        boxShadow: commonBoxShadow(),
        color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    );
  }
}
