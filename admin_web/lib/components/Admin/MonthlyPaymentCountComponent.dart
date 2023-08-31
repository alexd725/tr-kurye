import 'dart:developer';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_delivery_admin/utils/Extensions/int_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/string_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/widget_extensions.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../network/RestApis.dart';
import '../../utils/Constants.dart';
import '/../main.dart';
import '/../models/DashboardModel.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';

import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/text_styles.dart';

class MonthlyPaymentCountComponent extends StatefulWidget {
  static String tag = '/MonthlyPaymentCountComponent';
  List<MonthlyPaymentCompletedReport> monthlyCompletePayment;
  List<MonthlyPaymentCompletedReport> monthlyCancelPayment;

  final bool isPaymentType;

  MonthlyPaymentCountComponent({required this.monthlyCompletePayment, required this.monthlyCancelPayment, this.isPaymentType = false});

  @override
  MonthlyPaymentCountComponentState createState() => MonthlyPaymentCountComponentState();
}

class MonthlyPaymentCountComponentState extends State<MonthlyPaymentCountComponent> {
  String? startDate;
  String? endDate;

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
    await getCompletePaymentChartData(MONTHLY_PAYMENT_COMPLETED_REPORT, sDate, eDate).then((value1) async {
      await getCancelPaymentChartData(MONTHLY_PAYMENT_CANCELLED_REPORT, sDate, eDate).then((value) {
        widget.monthlyCompletePayment.clear();
        widget.monthlyCancelPayment.clear();
        widget.monthlyCompletePayment = value1.monthlyPaymentCompletedReport!;
        widget.monthlyCancelPayment = value.monthlyPaymentCancelledReport!;
        setState(() {});
        appStore.setLoading(false);
      });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.monthlyPaymentCount, style: primaryTextStyle()),
              Row(
                children: [
                  Text(DateFormat('MMM yyyy').format(startDate != null ? DateTime.parse(startDate!) : DateTime.now()), style: primaryTextStyle(size: 14)),
                  IconButton(
                    onPressed: () {
                      showMonthYearPicker(
                        context: context,
                        initialDate: startDate != null ? DateTime.parse(startDate!) : DateTime.now(),
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
            ],
          ).paddingSymmetric(horizontal: 8),
          /*   SfCartesianChart(
            tooltipBehavior: TooltipBehavior(enable: true),
            enableAxisAnimation: true,
            series: [
              StackedColumnSeries(
                color: primaryColor,
                dataSource: widget.monthlyCompletePayment,
                xValueMapper: (MonthlyPaymentCompletedReport data, _) => data.date,
                yValueMapper: (MonthlyPaymentCompletedReport data, _) => data.totalAmount,
              ),
              StackedColumnSeries(
                color: Colors.red,
                dataSource: widget.monthlyCancelPayment,
                xValueMapper: (MonthlyPaymentCompletedReport data, _) => data.date,
                yValueMapper: (MonthlyPaymentCompletedReport data, _) => data.totalAmount,
              ),
            ],
            axes: [
              NumericAxis(name: 'xAxis', opposedPosition: true, interval: 1, minimum: 0, maximum: 5, title: AxisTitle(text: 'Secondary X Axis')),
              NumericAxis(name: 'yAxis', opposedPosition: true, title: AxisTitle(text: 'Secondary Y Axis'))
            ],
            primaryXAxis: CategoryAxis(
              arrangeByIndex: true,
            ),
          ),*/
          SizedBox(
            height: 370,
            child: BarChart(
              [
                Series<MonthlyPaymentCompletedReport, String>(
                  displayName: language.completed,
                  id: 'Completed',
                  domainFn: (MonthlyPaymentCompletedReport data, _) => DateTime.parse(data.date).day.toString(),
                  measureFn: (MonthlyPaymentCompletedReport data, _) => data.totalAmount,
                  data: widget.monthlyCompletePayment,
                  colorFn: (MonthlyPaymentCompletedReport sales, _) {
                    return MaterialPalette.green.shadeDefault;
                  },
                  fillColorFn: (MonthlyPaymentCompletedReport sales, _) {
                    return MaterialPalette.green.shadeDefault;
                  },
                ),
                Series<MonthlyPaymentCompletedReport, String>(
                  displayName: language.cancelled,
                  id: 'Cancelled',
                  domainFn: (MonthlyPaymentCompletedReport data, _) => DateTime.parse(data.date).day.toString(),
                  measureFn: (MonthlyPaymentCompletedReport data, _) => data.totalAmount,
                  data: widget.monthlyCancelPayment,
                  colorFn: (MonthlyPaymentCompletedReport sales, _) {
                    return MaterialPalette.red.shadeDefault;
                  },
                  fillColorFn: (MonthlyPaymentCompletedReport sales, _) {
                    return MaterialPalette.red.shadeDefault;
                  },
                ),
              ],
              animate: true,
              vertical: true,
              barGroupingType: BarGroupingType.grouped,
              behaviors: [
                new SeriesLegend(
                  showMeasures: true,
                  position: BehaviorPosition.top,
                  horizontalFirst: true,
                  measureFormatter: (num? value) {
                    return value == null ? '-' : '${printAmount(value)}';
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        boxShadow: commonBoxShadow(),
        color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    );
  }
}
