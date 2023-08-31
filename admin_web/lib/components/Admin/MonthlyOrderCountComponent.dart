import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_delivery_admin/utils/Extensions/common.dart';
import 'package:local_delivery_admin/utils/Extensions/int_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/widget_extensions.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../../network/RestApis.dart';
import '../../utils/Constants.dart';
import '/../main.dart';
import '/../models/DashboardModel.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/text_styles.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.monthlyOrderCount, style: primaryTextStyle()),
              Row(
                children: [
                 Text(DateFormat('MMM yyyy').format(startDate!=null ? DateTime.parse(startDate!) : DateTime.now()),style: primaryTextStyle(size: 14)),
                  IconButton(
                    onPressed: () {
                      showMonthYearPicker(
                        context: context,
                        initialDate: startDate!=null ? DateTime.parse(startDate!) : DateTime.now(),
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
          16.height,
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
      decoration: BoxDecoration(
        boxShadow: commonBoxShadow(),
        color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
        borderRadius: BorderRadius.circular(defaultRadius),
      ),
    );
  }
}
