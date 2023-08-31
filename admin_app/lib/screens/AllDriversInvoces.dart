import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/models/UserModel.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../network/RestApis.dart';
import 'PdfViewer.dart';

class DriversInvoices extends StatefulWidget {
  static String tag = '/ParcelTypeComponent';

  @override
  State<DriversInvoices> createState() => DriversInvoicesState();
}

class DriversInvoicesState extends State<DriversInvoices> {
  bool isLoading = true;

  @override
  void initState() {
    getAllDriver().then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  final pdf = pw.Document();
  File file = File("example.pdf");

  Future pdfGet() async {
    final dir = await getExternalStorageDirectory();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Hello World!'),
        ),
      ),
    );
    final String path = "${dir!.path}/example.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save()).then((value) {});
  }

  Future<void> allPdfInvoices() async {
    driversList.forEach((i) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [pw.Text(i.name!), pw.Text(i.createdAtYear!)]),
          ),
        ),
      );
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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

  TextEditingController textSearch = TextEditingController();
  List<UserModel> _searchResult = [];

  Future onSearchTextChanged(String text) async {
    _searchResult.clear();
    setState(() {
      isLoading = true;
    });

    getAllDriver().then((value) {
      setState(() {
        isLoading = false;
      });
    }).then((value) {
      if (text.isEmpty) {
        setState(() {});
        return;
      }

      driversList.forEach((userDetail) {
        if (userDetail.name!.contains(text) ||
            userDetail.userType!.contains(text)) {
          _searchResult.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Drivers Invoices")),
      body: ListView(
        children: [
          CupertinoButton(
            child: Text("Generate All Invoices"),
            onPressed: () async {
              await allPdfInvoices();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextFormField(
                        controller: textSearch,
                        decoration: InputDecoration(
                          labelText: "Search here",
                          fillColor: Colors.black,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onSearchTextChanged(textSearch.text);
                        },
                        child: Text("Search"),
                      ),
                    ],
                  ),
                  width: 250,
                ),
                Container(
                  width: double.infinity,
                  height: 250,
                  child: SfDateRangePicker(
                    controller: date,
                    selectionMode: DateRangePickerSelectionMode.range,
                    allowViewNavigation: true,
                    showActionButtons: true,
                    onSubmit: (v) {
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
              padding: const EdgeInsets.all(1.0),
              child: Container(
                padding: EdgeInsets.all(16),
                child: isLoading == false
                    ? DataTable2(
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
    DataCell(
         Text("")),
                                  // DataCell(
                                  //     Text(e.orderAmount.toString())),
                                  DataCell(Text(e.idNo.toString())),
                                  DataCell(Text(e.userType == "delivery_man"
                                      ? "Delivery"
                                      : "User")),
                                  DataCell(Text("0")),
                                  DataCell(InkWell(
                                      onTap: () async {
                                        //
                                        pdfGet();
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
    );
  }
}
