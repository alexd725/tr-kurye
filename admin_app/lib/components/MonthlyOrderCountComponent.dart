import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../../network/RestApis.dart';
import '../../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '/../main.dart';
import '/../models/DashboardModel.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyOrderCountComponent extends StatefulWidget {
  static String tag = '/WeeklyUserCountComponent';
  List<MonthlyOrderCount>? monthlyCount;
  final bool isPaymentType;

  MonthlyOrderCountComponent({required this.monthlyCount, this.isPaymentType = false});

  @override
  MonthlyOrderCountComponentState createState() => MonthlyOrderCountComponentState();
}

class MonthlyOrderCountComponentState extends State<MonthlyOrderCountComponent> {
  String? startDate;
  String? endDate;
  List<MonthlyOrderCount> monthlyCount1 = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  getMonthChartData(sDate, eDate) async {
    appStore.setLoading(true);
    await getDashBoardChartData(MONTHLY_ORDER_COUNT, sDate, eDate).then((value) {
      monthlyCount1 = value.monthlyOrderCount!;
      widget.monthlyCount!.clear();
      widget.monthlyCount = value.monthlyOrderCount!;
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      log(e);
      appStore.setLoading(false);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Order count', style: primaryTextStyle()),
                IconButton(
                  onPressed: () {
                    showMonthYearPicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    ).then((value) {
                      DateFormat date = DateFormat('yyyy-MM-dd');
                      startDate = date.format(value!);
                      DateTime d = DateTime(value.year, value.month + 1, 0);
                      endDate = date.format(d);
                      getMonthChartData(startDate, endDate);
                    });
                  },
                  icon: Icon(Icons.calendar_month),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SfCartesianChart(
            enableAxisAnimation: true,
            enableSideBySideSeriesPlacement: true,
            indicators: [],
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries>[
              StackedColumnSeries<MonthlyOrderCount, String>(
                color: primaryColor,
                enableTooltip: true,
                markerSettings: MarkerSettings(isVisible: true),
                dataSource: widget.monthlyCount!,
                xValueMapper: (MonthlyOrderCount exp, _) => exp.date!,
                yValueMapper: (MonthlyOrderCount exp, _) => widget.isPaymentType ? exp.total : exp.total,
              ),
            ],
            primaryXAxis: CategoryAxis(isVisible: true),
          ),
        ],
      ),
      decoration:containerDecoration()
    );
  }
}
