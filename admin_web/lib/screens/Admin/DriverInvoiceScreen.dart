import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_delivery_admin/components/Admin/BodyCornerWidget.dart';
import 'package:local_delivery_admin/main.dart';
import 'package:local_delivery_admin/models/UserModel.dart';
import 'package:local_delivery_admin/utils/Colors.dart';
import 'package:local_delivery_admin/utils/Common.dart';
import 'package:local_delivery_admin/utils/Constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:local_delivery_admin/components/PdfGenerator.dart';
import 'package:local_delivery_admin/network/RestApis.dart';

class DriverInvoices extends StatefulWidget {
  static String route = '/admin/DriverInvoices';
  const DriverInvoices({Key? key}) : super(key: key);

  @override
  State<DriverInvoices> createState() => _DriverInvoicesState();
}

class _DriverInvoicesState extends State<DriverInvoices> {
  bool isLoading = true;
  List<UserModel> _searchResult = [];
  TextEditingController textSearch = TextEditingController();
  TextEditingController plateSearch = TextEditingController();

  Future onSearchTextChanged(String text) async {
    _searchResult.clear();

    setState(() {
      isLoading = true;
    });

    getAllDriver().then((value) {
      if (text.isEmpty) {
        setState(() {});
        return;
      }

      driversList.forEach((userDetail) {
        if (userDetail.name!.contains(textSearch.text) ||
            userDetail.userType!.contains(textSearch.text)) {
          _searchResult.add(userDetail);
        }
      });
    }).then((value) {
      setState(() {
        isLoading = false;
        driversList = _searchResult;
      });
    });
  }
  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    getAllDriver().then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  var pdf = pw.Document();
  var anchor;

  savePDF() async {
    Uint8List pdfInBytes = await pdf.save();
    final blob = html.Blob([pdfInBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'pdf.pdf';
    html.document.body!.children.add(anchor);
  }

  Future<void> pdfGet() async {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Hello World!'),
        ),
      ),
    );

    savePDF();
  }

  void pdfAll() async {
    final headers = [
      'Year',
      'Month',
      'Name',
      'Booking',
      'Plate',
      'Type',
      'Earning'
    ];
    final drivers = driversList.map((e) => Driver(
        year: e.createdAtYear.toString(),
        month: e.createdAtMonth.toString(),
        name: e.name.toString(),
        booking: e.orderAmount!.length.toString(),
        plate: e.idNo.toString(),
        type: e.userType == "delivery_man" ? "Delivery" : "User",
        earning: e.amount.toString()));
    // final drivers = [
    //         Driver(year: e.createdAtYear.toString(), month: e.createdAtMonth.toString(), name: e.name.toString(), booking: e.orderAmount!.length.toString(), plate: e.idNo.toString(), type: e.userType == "delivery_man"
    //             ? "Delivery"
    //             : "User", earning: e.amount.toString()),
    // ];
    final data = drivers
        .map((driver) => [
              driver.year,
              driver.month,
              driver.name,
              driver.booking,
              driver.plate,
              driver.type,
              driver.earning
            ])
        .toList();

    pdf.addPage(pw.Page(
      build: (context) => pw.Table.fromTextArray(
        headers: headers,
        data: data,
      ),
    ));
    await savePDF();
    anchor.click();
  }

  Future<void> allPdfInvoices() async {
    driversList.forEach((i) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text(i.name!),
                  pw.Text(i.orderAmount!.length.toString())
                ]),
          ),
        ),
      );
    });
    savePDF();
  }

  Iterable<E> mapIndexed<E, T>(
      Iterable<T> items, E Function(int index, T item) f) sync* {
    var index = 0;

    for (final item in items) {
      yield f(index, item);
      index = index + 1;
    }
  }

  @override
  void dispose() {
    driversList.clear();
    super.dispose();
  }

  bool loading = false;

  DateRangePickerController date = DateRangePickerController();

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body: SafeArea(
          child: BodyCornerWidget(
          child: ListView(
            children: [
              CupertinoButton(
                child: Text(
                  "Generate All Invoices",
                  style: TextStyle(
                    color: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                  ),
                ),
                onPressed: () async {
                  pdfAll();
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextFormField(
                              style: TextStyle(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : scaffoldColorDark,
                              ),
                              controller: textSearch,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : scaffoldColorDark,
                                ),
                                labelText: "Search here",
                                hoverColor: appStore.isDarkMode
                                    ? Colors.white
                                    : scaffoldColorDark,
                                fillColor: appStore.isDarkMode
                                    ? Colors.white
                                    : scaffoldColorDark,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : scaffoldColorDark,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                searchDriver(textSearch.text).then((value) {
                                  setState(() {
                                    textSearch.clear();
                                    isLoading = false;
                                  });
                                });
                              },
                              child: Text(
                                "Search",
                                style: TextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : scaffoldColorDark,
                                ),
                              ),
                            ),
                            TextFormField(
                              style: TextStyle(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : scaffoldColorDark,
                              ),
                              controller: plateSearch,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : scaffoldColorDark,
                                ),
                                labelText: "Search here",
                                hoverColor: appStore.isDarkMode
                                    ? Colors.white
                                    : scaffoldColorDark,
                                fillColor: appStore.isDarkMode
                                    ? Colors.white
                                    : scaffoldColorDark,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : scaffoldColorDark,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                searchDriverByPlate(plateSearch.text).then((value) {
                                  setState(() {
                                    plateSearch.clear();
                                    isLoading = false;
                                  });
                                });
                              },
                              child: Text(
                                "Search By Plate",
                                style: TextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : scaffoldColorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        width: 250,
                      ),
                      width: 250,
                      height: 250,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: 220,
                      color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                      child: SfDateRangePicker(
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          textStyle: TextStyle(
                            color: appStore.isDarkMode
                                ? Colors.white
                                : scaffoldColorDark,
                          ),
                        ),
                        yearCellStyle: DateRangePickerYearCellStyle(
                            textStyle: TextStyle(
                          color:
                              appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                        )),
                        headerStyle: DateRangePickerHeaderStyle(
                            textStyle: TextStyle(
                          color:
                              appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                        )),
                        rangeTextStyle: TextStyle(
                          color:
                              appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                        ),
                        selectionTextStyle: TextStyle(color: Colors.white),
                        selectionColor:
                            appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                        backgroundColor:
                            appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                        todayHighlightColor:
                            appStore.isDarkMode ? Colors.white : scaffoldColorDark,
                        selectionMode: DateRangePickerSelectionMode.range,
                        allowViewNavigation: true,
                        showActionButtons: true,
                        controller: date,
                        onSubmit: (v) {
                          print("______driver_____$date");
                          // if (date.selectedRange != null) {
                          //   getAllDriverByDate(date.selectedRange!.startDate, date.selectedRange!.endDate);
                          // } else {
                          //   print("No Invoice data");
                          // }
                          // getAllDriverByDate(date.selectedRange!.startDate,
                          //         date.selectedRange!.endDate) .then((value);

                              getAllDriverByDate(date.selectedRange!.startDate,
                              date.selectedRange!.endDate)
                              .then((value) {
                            setState(() {});
                          });

                        },



                        onSelectionChanged: (v) {},
                        view: DateRangePickerView.month,
                        monthViewSettings:
                            DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: isLoading == false
                        ? DataTable2(
                            headingRowColor: appStore.isDarkMode
                                ? MaterialStateProperty.all(scaffoldColorDark)
                                : MaterialStateProperty.all(Colors.white),
                            dataRowColor: appStore.isDarkMode
                                ? MaterialStateProperty.all(scaffoldColorDark)
                                : MaterialStateProperty.all(Colors.white),
                            dataTextStyle: TextStyle(
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : scaffoldColorDark,
                            ),
                            headingTextStyle: TextStyle(
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : scaffoldColorDark,
                            ),
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
                            columns: [
                              DataColumn2(
                                label: Text('Year'),
                                size: ColumnSize.L,
                              ),
                              DataColumn(
                                label: Text('Month'),
                              ),
                              DataColumn(
                                label: Text('Driver Name'),
                              ),
                              DataColumn(
                                label: Text('Booking Count'),
                              ),
                              DataColumn(
                                label: Text('Vehicle Plate Number'),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('User Type'),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('Earning Amount'),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('Download PDF'),
                                numeric: true,
                              ),
                            ],
                            rows: driversList
                                .map(
                                  (e) => DataRow(
                                    cells: [
                                      DataCell(Text(e.createdAtYear!)),
                                      DataCell(Text(e.createdAtMonth!)),
                                      DataCell(Text(e.name!)),
                                      DataCell(Text(e.orderAmount!.length.toString())),
                                       DataCell(Text(e.idNo.toString())),
                                      DataCell(Text(e.userType == "delivery_man" ? "Delivery" : "User")),
                                      DataCell(Text(e.amount.toString())),
                                      DataCell(InkWell(
                                          onTap: () async {
                                            setState(() {
                                              pdf = pw.Document();
                                            });
                                            print(e.createdAtYear.toString());
                                            final headers = [
                                              'Year',
                                              'Month',
                                              'Name',
                                              'Booking',
                                              'Plate',
                                              'Type',
                                              'Earning'
                                            ];
                                            // final drivers = driversList.map((e) => Driver(year: e.createdAtYear.toString(), month: e.createdAtMonth.toString(), name: e.name.toString(), booking: e.orderAmount!.length.toString(), plate: e.idNo.toString(), type: e.userType == "delivery_man"
                                            //                 ? "Delivery"
                                            //                 : "User", earning: e.amount.toString()));
                                            final drivers = [
                                              Driver(
                                                  year: e.createdAtYear.toString(),
                                                  month: e.createdAtMonth.toString(),
                                                  name: e.name.toString(),
                                                  booking: e.orderAmount!.length
                                                      .toString(),
                                                  plate: e.idNo.toString(),
                                                  type: e.userType == "delivery_man"
                                                      ? "Delivery"
                                                      : "User",
                                                  earning:
                                                      '${e.amount.toString()} TL'),
                                            ];
                                            final data = drivers
                                                .map((driver) => [
                                                      driver.year,
                                                      driver.month,
                                                      driver.name,
                                                      driver.booking,
                                                      driver.plate,
                                                      driver.type,
                                                      driver.earning
                                                    ])
                                                .toList();

                                            pdf.addPage(pw.Page(
                                              build: (context) =>
                                                  pw.Table.fromTextArray(
                                                headers: headers,
                                                data: data,
                                              ),
                                            ));
                                            await savePDF();
                                            anchor.click();
                                          },
                                          child: Icon(Icons.picture_as_pdf)))
                                    ],
                                  ),
                                )
                                .toList())
                        : Center(child: CircularProgressIndicator()),
                  ),
                ),
              )
            ],
          ),
            ),
        ),
      );
  }
}

class Driver {
  final String year;
  final String month;
  final String name;
  final String booking;
  final String plate;
  final String type;
  final String earning;

  const Driver({
    required this.year,
    required this.month,
    required this.name,
    required this.booking,
    required this.plate,
    required this.type,
    required this.earning,
  });
}
