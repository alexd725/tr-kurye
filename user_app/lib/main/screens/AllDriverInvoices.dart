import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../models/UserModel.dart';
import '../network/RestApis.dart';
import 'PdfReader.dart';

class AllDriverInvoices extends StatefulWidget {
  const AllDriverInvoices({Key? key}) : super(key: key);

  @override
  State<AllDriverInvoices> createState() => _AllDriverInvoicesState();
}

class _AllDriverInvoicesState extends State<AllDriverInvoices> {
  bool isLoading = true;
  TextEditingController textSearch = TextEditingController();

  List<Order> _searchResult = [];

  @override
  void initState() {
    getAllDriverOrder().then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
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
    order.clear();
    super.dispose();
  }

  bool loading = false;

  createPdf(String name, String amount) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Row(children: [
              pw.Text(name),
              pw.Text(amount),
            ]),
          ); // Center
        })); // Page
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.document.save());
  }

  DateRangePickerController date = DateRangePickerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("All Invoices"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          CupertinoButton(
            child: Text("Generate All Invoices"),
            onPressed: () async {
              createPdf("test", "test");
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  child: Column(
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
                          setState(() {
                            isLoading = true;
                          });
                          searchDriverOrders(textSearch.text).then((value) {
                            setState(() {
                              isLoading = false;
                            });
                          });
                        },
                        child: Text("Search"),
                      ),
                    ],
                  ),
                  width: 250,
                ),
                Container(
                  child: SfDateRangePicker(
                    controller: date,
                    selectionMode: DateRangePickerSelectionMode.range,
                    allowViewNavigation: true,
                    showActionButtons: true,
                    onCancel: () {},
                    onSubmit: (v) {
                      setState(() {
                        isLoading = true;
                      });
                      getAllDriverByDate(date.selectedRange!.startDate,
                              date.selectedRange!.endDate)
                          .then((value) {
                        setState(() {
                          isLoading = false;
                        });
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
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.all(16),
                child: isLoading == false
                    ? DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 600,
                        columns: [
                          DataColumn2(
                            label: Text('id'),
                          ),
                          DataColumn(
                            label: Text('Month'),
                          ),
                          DataColumn(
                            label: Text('Fixed Charge'),
                          ),
                          DataColumn(
                            label: Text('Total Amount'),
                            numeric: true,
                          ),
                          DataColumn(
                            label: Text('Pdf Export'),
                            numeric: true,
                          ),
                        ],
                        rows: order
                            .map(
                              (e) => DataRow(
                                cells: [
                                  DataCell(Text(e.id.toString())),
                                  DataCell(Text(e.month.toString())),
                                  DataCell(Text(e.fixedCharge!)),
                                  DataCell(Text(e.totalAmount!)),
                                  DataCell(InkWell(
                                      onTap: () async {
                                        //
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
