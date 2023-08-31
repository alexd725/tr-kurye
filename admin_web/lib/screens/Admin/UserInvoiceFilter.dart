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
import 'package:local_delivery_admin/network/RestApis.dart';

class UsersInvoices extends StatefulWidget {
  static String route = '/admin/UsersInvoice';
  const UsersInvoices({Key? key}) : super(key: key);

  @override
  State<UsersInvoices> createState() => _UsersInvoicesState();
}

class _UsersInvoicesState extends State<UsersInvoices> {
  bool isLoading = true;
  List<UserModel> _searchResult = [];
  TextEditingController textSearch = TextEditingController();
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

      usersList.forEach((userDetail) {
        if (userDetail.name!.contains(textSearch.text) ||
            userDetail.userType!.contains(textSearch.text)) {
          _searchResult.add(userDetail);
        }
      });
    }).then((value) {
      setState(() {
        isLoading = false;
        usersList = _searchResult;
      });
    });
  }

  @override
  void initState() {
    getAllUsers().then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  final pdf = pw.Document();
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

  Future<void> allPdfInvoices() async {
    usersList.forEach((i) {
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
    usersList.clear();

    super.dispose();
  }

  bool loading = false;

  DateRangePickerController date = DateRangePickerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SafeArea(
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
                      await allPdfInvoices();
                      anchor.click();
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
                                    searchUsersrByName(textSearch.text).then((value) {
                                      print("here is nameeeee ${textSearch.text}");
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
                              ],
                            ),
                            width: 250,
                          ),
                          width: 250,
                          height: 180,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: 220,
                          color: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
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
                            controller: date,
                            selectionMode: DateRangePickerSelectionMode.range,
                            allowViewNavigation: true,
                            showActionButtons: true,
                            onSubmit: (v) {
                              print("_________userrrr__________$date");
                              getAllUsersrByDate(date.selectedRange!.startDate,
                                      date.selectedRange!.endDate)
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            onSelectionChanged: (v) {},
                            view: DateRangePickerView.month,
                            rangeSelectionColor: appStore.isDarkMode
                                ? Color.fromARGB(255, 199, 129, 211)
                                : Color.fromARGB(255, 199, 129, 211),
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
                                rows: usersList
                                    .map(
                                      (e) => DataRow(
                                        cells: [
                                          DataCell(Text(e.createdAtYear!)),
                                          DataCell(Text(e.createdAtMonth!)),
                                          DataCell(Text(e.name!)),
                                          DataCell(
                                              Text(e.orderAmount!.length.toString())),
                                          DataCell(Text(e.idNo.toString())),
                                          DataCell(Text(e.userType == "delivery_man"
                                              ? "Delivery"
                                              : "User")),
                                          DataCell(Text("1000 Da")),
                                          DataCell(InkWell(
                                              onTap: () async {
                                                pdf.addPage(
                                                  pw.Page(
                                                    pageFormat: PdfPageFormat.a4,
                                                    build: (pw.Context context) {
                                                      return pw.Center(
                                                        child: pw.Column(children: [
                                                          pw.Text(e.createdAtYear!),
                                                          pw.Text(e.createdAtMonth!),
                                                          pw.Text(e.name!),
                                                          pw.Text(
                                                            e.orderAmount!.length
                                                                .toString(),
                                                          ),
                                                          pw.Text(e.idNo!),
                                                        ]),
                                                      ); // Center
                                                    },
                                                  ),
                                                );
                                                //

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
      ),
    );
  }
}
