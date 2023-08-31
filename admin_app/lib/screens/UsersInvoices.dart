import 'dart:io';
import 'dart:typed_data';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../network/RestApis.dart';
import 'PdfViewer.dart';


class UsersInvoices extends StatefulWidget {
  const UsersInvoices({Key? key}) : super(key: key);

  @override
  State<UsersInvoices> createState() => _UsersInvoicesState();
}

class _UsersInvoicesState extends State<UsersInvoices> {
  bool isLoading = true;
  TextEditingController textSearch = TextEditingController();

  @override
  void initState() {
    getAllUsers().then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);

    return file;
  }


   pdfAll() async{
    final headers = ['Year', 'Month', 'Name', 'Booking', 'Plate', 'Type', 'Earning'];
    final drivers = driversList.map((e) => Driver(year: e.createdAtYear.toString(), month: e.createdAtMonth.toString(), name: e.name.toString(), booking: e.orderAmount!.length.toString(), plate: e.idNo.toString(), type: e.userType == "delivery_man"
        ? "Delivery"
        : "User", earning: "20 TL"));
    // final drivers = [
    //         Driver(year: e.createdAtYear.toString(), month: e.createdAtMonth.toString(), name: e.name.toString(), booking: e.orderAmount!.length.toString(), plate: e.idNo.toString(), type: e.userType == "delivery_man"
    //             ? "Delivery"
    //             : "User", earning: e.amount.toString()),
    // ];
    final data = drivers.map((driver) => [driver.year, driver.month, driver.name, driver.booking, driver.plate, driver.type, driver.earning]).toList();
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (context) => pw.Table.fromTextArray(
        headers: headers,
        data: data,
      ),
    ));
    final pdfFile =  await saveDocument(name: "All users PDF",pdf: pdf);
    openPdf(context, pdfFile);
  }


  void openPdf(BuildContext context, File file) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            file: file,
          ),
        ),
      );

  final pdf = pw.Document();
  var anchor;

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Users Invoices")),
      body: ListView(
        children: [
          CupertinoButton(
            child: Text(
              "Generate All Invoices",
              style: TextStyle(
                color: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
              ),
            ),
            onPressed: () async{
              await pdfAll();
              // print('f');
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        child: TextFormField(
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
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          searchUsersrByName(textSearch.text).then((value) {
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
                Container(
                  width: double.infinity,
                  height: 300,
                  color: appStore.isDarkMode ? scaffoldColorDark : Colors.white,
                  child: SfDateRangePicker(
                    rangeTextStyle: TextStyle(color: Colors.purple),
                    controller: date,
                    selectionMode: DateRangePickerSelectionMode.range,
                    allowViewNavigation: true,
                    showActionButtons: true,
                    onSubmit: (v) {
                      getAllUsersrByDate(date.selectedRange!.startDate,
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
                                  DataCell(
                                      Text(e.orderAmount!.length.toString())),
                                  DataCell(Text(e.idNo.toString())),
                                  DataCell(Text(e.userType == "delivery_man"
                                      ? "Delivery"
                                      : "User")),
                                  DataCell(Text("1000 Da")),
                                  DataCell(InkWell(
                                      onTap: () async {
                                        print(e.createdAtYear.toString());
                                        final headers = ['Year', 'Month', 'Name', 'Booking', 'Plate', 'Type', 'Earning'];
                                        // final drivers = driversList.map((e) => Driver(year: e.createdAtYear.toString(), month: e.createdAtMonth.toString(), name: e.name.toString(), booking: e.orderAmount!.length.toString(), plate: e.idNo.toString(), type: e.userType == "delivery_man"
                                        //                 ? "Delivery"
                                        //                 : "User", earning: e.amount.toString()));
                                        final drivers = [
                                          Driver(year: e.createdAtYear.toString(), month: e.createdAtMonth.toString(), name: e.name.toString(), booking: e.orderAmount!.length.toString(), plate: e.idNo.toString(), type: e.userType == "delivery_man"
                                              ? "Delivery"
                                              : "User", earning: '1 TL'),
                                        ];
                                        final data = drivers.map((driver) => [driver.year, driver.month, driver.name, driver.booking, driver.plate, driver.type, driver.earning]).toList();
                                        final pdf = pw.Document();
                                        pdf.addPage(pw.Page(
                                          build: (context) => pw.Table.fromTextArray(
                                            headers: headers,
                                            data: data,
                                          ),
                                        ));
                                        final pdfFile =  await saveDocument(name: e.id.toString(),pdf: pdf);
                                        openPdf(context, pdfFile);

                                        // anchor.click();
                                      },
                                      // onTap: () async {
                                      //   pdf.addPage(
                                      //     pw.Page(
                                      //       pageFormat: PdfPageFormat.a4,
                                      //       build: (pw.Context context) {
                                      //         return pw.Center(
                                      //           child: pw.Column(children: [
                                      //             pw.Text(e.createdAtYear!),
                                      //             pw.Text(e.createdAtMonth!),
                                      //             pw.Text(e.name!),
                                      //             pw.Text(
                                      //               e.orderAmount!.length
                                      //                   .toString(),
                                      //             ),
                                      //             pw.Text(e.idNo!),
                                      //           ]),
                                      //         ); // Center
                                      //       },
                                      //     ),
                                      //   );
                                      //   //
                                      // },
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
    required this.earning,});
}