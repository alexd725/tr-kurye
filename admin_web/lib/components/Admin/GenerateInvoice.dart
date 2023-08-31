import 'package:intl/intl.dart';
import '/../models/OrderModel.dart';
import '/../utils/Extensions/string_extensions.dart';
import '../../main.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '/../models/ExtraChargeRequestModel.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:universal_html/html.dart' as html;

generateInvoiceCall(OrderModel orderData) async {
  List<ExtraChargeRequestModel> extraList = [];
  orderData.extraCharges.forEach((e) {
    ExtraChargeRequestModel element = ExtraChargeRequestModel.fromJson(e);
    if (element.key == FIXED_CHARGES) {
      //
    } else if (element.key == MIN_DISTANCE) {
      //
    } else if (element.key == MIN_WEIGHT) {
      //
    } else if (element.key == PER_DISTANCE_CHARGE) {
      //
    } else if (element.key == PER_WEIGHT_CHARGE) {
      //
    } else {
      extraList.add(element);
    }
  });

  final invoice = Invoice(
    supplier: Supplier(name: 'Roberts Private Limited', address: 'Sarah Street 9, Beijing, Ahmedabad', contactNumber: '+91 9845345665'),
    customer: Customer(
      name: '${orderData.clientName}',
      address: '${orderData.deliveryPoint!.address}',
    ),
    info: InvoiceInfo(
      number: '${orderData.id}',
      invoiceDate: DateTime.now(),
      orderedDate: DateTime.parse(orderData.date!).toLocal(),
    ),
    items: [
      InvoiceItem(
        product:
            '${orderData.parcelType} (${orderData.totalWeight} ${appStore.countryList.isNotEmpty ? '${appStore.countryList.firstWhere((element) => element.id == orderData.countryId).weightType ?? 'kg'}' : 'kg'})',
        description: language.delivery_charges,
        price: orderData.fixedCharges!.toDouble(),
      ),
      InvoiceItem(
        product: '',
        description: language.distance_charge,
        price: orderData.distanceCharge!.toDouble(),
      ),
      InvoiceItem(
        product: '',
        description: language.weight_charge,
        price: orderData.weightCharge!.toDouble(),
      ),
    ],
    extraChargeList: extraList,
    totalAmount: orderData.totalAmount!.toDouble(),
    paymentType: paymentType(orderData.paymentType.validate(value: PAYMENT_TYPE_CASH)),
    paymentStatus: paymentStatus(orderData.paymentStatus.validate(value: PAYMENT_PENDING)),
  );
  await PdfInvoiceApi.generate(invoice);
}

class PdfInvoiceApi {
  static Future<void> generate(Invoice invoice) async {
    final pdf = Document(
      theme: ThemeData.withFont(fontFallback: [
        await PdfGoogleFonts.hindRegular(),
        await PdfGoogleFonts.iBMPlexSansArabicRegular(),
        await PdfGoogleFonts.notoSansSymbols2Regular(),
        await PdfGoogleFonts.beVietnamProRegular(),
        await PdfGoogleFonts.robotoRegular(),
        await PdfGoogleFonts.padaukRegular(),
      ]),
    );

    pdf.addPage(MultiPage(
      build: (context) => [
        buildTitle(invoice),
        SizedBox(height: 2 * PdfPageFormat.cm),
        buildHeader(invoice),
        SizedBox(height: 1 * PdfPageFormat.cm),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    /* /// Open pdf
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);*/

    /// download pdf
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = 'Invoice_${invoice.info.number}.pdf';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  static Widget buildHeader(Invoice invoice) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.customer_name, style: TextStyle(color: PdfColors.blue)),
            SizedBox(height: 4),
            Text('${invoice.customer.name}'),
            SizedBox(height: 16),
            Text(language.deliveredTo, style: TextStyle(color: PdfColors.blue)),
            SizedBox(height: 4),
            Text('${invoice.customer.address}'),
            SizedBox(height: 16),
            Text('${language.payment_type}: ${invoice.paymentType}'),
            Text('${language.payment_status}: ${invoice.paymentStatus}'),
          ],
        ),
      ),
      Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${language.invoiceNo} ${invoice.info.number}'),
        Text('${language.invoiceDate} ${Utils.formatDate(invoice.info.invoiceDate)}'),
        Text('${language.orderedDate} ${Utils.formatDate(invoice.info.orderedDate)}'),
      ]),
    ]);
  }

  static Widget buildTitle(Invoice invoice) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${language.invoiceCapital}",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: PdfColors.blue),
          ),
          pw.Text('${invoice.supplier.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
      SizedBox(height: 4),
      pw.Text('${invoice.supplier.address}', style: TextStyle(fontSize: 16)),
      SizedBox(height: 4),
      pw.Text('${invoice.supplier.contactNumber}', style: TextStyle(fontSize: 16)),
    ]);
  }

  static Widget buildInvoice(Invoice invoice) {
    final headers = [language.product, language.description, language.price];
    final data = invoice.items.map((item) {
      return [
        item.product,
        item.description,
        '${printAmount(item.price)}',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
        2: Alignment.centerRight,
      },
    );
  }

  static Widget buildTotal(Invoice invoice) {
    final subTotal = invoice.items.map((item) => item.price).reduce((item1, item2) => item1 + item2);

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (invoice.extraChargeList.length != 0)
                  Column(
                    children: [
                      buildText(
                        title: language.subTotal,
                        value: Utils.formatPrice(subTotal),
                        unite: true,
                      ),
                      SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(invoice.extraChargeList.length, (index) {
                          ExtraChargeRequestModel item = invoice.extraChargeList[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: buildText(
                              title: '${item.key!.replaceAll("_", " ")} (${item.valueType == CHARGE_TYPE_PERCENTAGE ? '${item.value}%' : '${printAmount(item.value ?? 0)}'})',
                              value: Utils.formatPrice(countExtraCharge(totalAmount: subTotal, chargesType: item.valueType!, charges: item.value!).toDouble()),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 2 * PdfPageFormat.mm),
                      Container(height: 1, color: PdfColors.grey400),
                      SizedBox(height: 0.5 * PdfPageFormat.mm),
                      Container(height: 1, color: PdfColors.grey400),
                      SizedBox(height: 2 * PdfPageFormat.mm),
                    ],
                  ),
                buildText(title: language.total, value: Utils.formatPrice(invoice.totalAmount), unite: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: language.address, value: invoice.supplier.address),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: unite ? style : null)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}

class Utils {
  static formatPrice(double price) => '${printAmount(double.parse(price.toStringAsFixed(digitAfterDecimal)))}';

  static formatDate(DateTime date) => DateFormat.yMd().format(date);
}

class Customer {
  final String name;
  final String address;

  const Customer({
    required this.name,
    required this.address,
  });
}

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;
  final List<ExtraChargeRequestModel> extraChargeList;
  final double totalAmount;
  final String paymentType;
  final String paymentStatus;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
    required this.extraChargeList,
    required this.totalAmount,
    required this.paymentType,
    required this.paymentStatus,
  });
}

class InvoiceInfo {
  final String number;
  final DateTime orderedDate;
  final DateTime invoiceDate;

  const InvoiceInfo({
    required this.number,
    required this.orderedDate,
    required this.invoiceDate,
  });
}

class InvoiceItem {
  final String product;
  final String description;
  final double price;

  const InvoiceItem({
    required this.product,
    required this.description,
    required this.price,
  });
}

class Supplier {
  final String name;
  final String address;
  final String contactNumber;

  const Supplier({
    required this.name,
    required this.address,
    required this.contactNumber,
  });
}
