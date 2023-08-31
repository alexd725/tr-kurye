import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../models/LDBaseResponse.dart';
import '../../models/PaymentGatewayListModel.dart';
import '../../network/NetworkUtils.dart';
import '../../network/RestApis.dart';
import 'PaymentSetupScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';

import '../../main.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';

class PaymentGatewayScreen extends StatefulWidget {
  static String route = '/admin/paymentgateway';

  @override
  PaymentGatewayScreenState createState() => PaymentGatewayScreenState();
}

class PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentIndex = 0;
  int currentPage = 1;

  List<PaymentGatewayData> paymentGatewayList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setSelectedMenuIndex(PAYMENT_GATEWAY_INDEX);
    getPaymentGatewayListApiCall();
  }

  getPaymentGatewayListApiCall() async {
    appStore.setLoading(true);
    await getPaymentGatewayList().then((value) {
      appStore.setLoading(false);
      paymentGatewayList.clear();
      paymentGatewayList.addAll(value.data!);
      setValue(PAYMENT_GATEWAY_LIST,
          value.data!.map((e) => jsonEncode(e.toJson())).toList());
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deletePaymentGatewayListApiCall(var cardId) async {
    appStore.setLoading(true);
    print(cardId);
    await deleteCreditCard(cardId).then((value) {
      appStore.setLoading(false);
      paymentGatewayList.clear();
      paymentGatewayList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      // toast(error.toString());
    });
  }

  /// Update Payment Status
  Future<void> updateStatusApiCall(
      PaymentGatewayData paymentGatewayData) async {
    appStore.setLoading(true);
    MultipartRequest multiPartRequest =
        await getMultiPartRequest('paymentgateway-save');

    multiPartRequest.fields['id'] = paymentGatewayData.id!.toString();
    multiPartRequest.fields['status'] =
        paymentGatewayData.status == 1 ? "0" : "1";
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          LDBaseResponse res = LDBaseResponse.fromJson(data);
          toast(res.message.toString());
          getPaymentGatewayListApiCall();
        }
      },
      onError: (error) {
        appStore.setLoading(false);
        toast(error.toString());
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget addPaymentButton() {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(defaultRadius)),
          child:
              Text(language.setup, style: boldTextStyle(color: Colors.white)),
        ),
        onTap: () async {
          var res =
              await Navigator.pushNamed(context, PaymentSetupScreen.route);
          if (res != null) {
            getPaymentGatewayListApiCall();
          }
        },
      );
    }

    return Observer(builder: (context) {
      return BodyCornerWidget(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveWidget.isSmallScreen(context) &&
                          appStore.isMenuExpanded
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(language.payment_gateway,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            addPaymentButton(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.payment_gateway,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            addPaymentButton(),
                          ],
                        ),
                  SizedBox(height: 16),
                  paymentGatewayList.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RawScrollbar(
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              thumbColor: appStore.isDarkMode
                                  ? Colors.white12
                                  : Colors.black12,
                              radius: Radius.circular(defaultRadius),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: appStore.isDarkMode
                                        ? scaffoldColorDark
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    boxShadow: commonBoxShadow()),
                                child: SingleChildScrollView(
                                  controller: horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(16),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: getBodyWidth(context) - 48),
                                    child: DataTable(
                                      dataRowHeight: 60,
                                      headingRowHeight: 45,
                                      horizontalMargin: 16,
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => primaryColor
                                                  .withOpacity(0.1)),
                                      showCheckboxColumn: false,
                                      dataTextStyle: primaryTextStyle(size: 14),
                                      headingTextStyle: boldTextStyle(),
                                      columns: [
                                        DataColumn(label: Text(language.id)),
                                        DataColumn(
                                            label:
                                                Text(language.payment_method)),
                                        DataColumn(label: Text(language.image)),
                                        DataColumn(label: Text(language.mode)),
                                        DataColumn(
                                            label: Text(language.status)),
                                        DataColumn(
                                            label: Text(language.actions)),
                                      ],
                                      rows: paymentGatewayList.map((mData) {
                                        return DataRow(cells: [
                                          DataCell(Text('${mData.id ?? ""}')),
                                          DataCell(
                                              Text('${mData.title ?? ""}')),
                                          DataCell(
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: commonCachedNetworkImage(
                                                  '${mData.gatewayLogo!}',
                                                  fit: BoxFit.fitHeight,
                                                  height: 60,
                                                  width: 60),
                                            ),
                                          ),
                                          DataCell(Text(mData.isTest == 1
                                              ? language.test
                                              : language.live)),
                                          DataCell(
                                            TextButton(
                                              child: Text(
                                                '${mData.status == 1 ? language.enable : language.disable}',
                                                style: primaryTextStyle(
                                                    color: mData.status == 1
                                                        ? primaryColor
                                                        : Colors.red),
                                              ),
                                              onPressed: () {
                                                commonConfirmationDialog(
                                                    context,
                                                    mData.status == 1
                                                        ? DIALOG_TYPE_DISABLE
                                                        : DIALOG_TYPE_ENABLE,
                                                    () {
                                                  if (getStringAsync(
                                                          USER_TYPE) ==
                                                      DEMO_ADMIN) {
                                                    toast(language
                                                        .demo_admin_msg);
                                                  } else {
                                                    Navigator.pop(context);
                                                    updateStatusApiCall(mData);
                                                  }
                                                },
                                                    title: mData.status != 1
                                                        ? language
                                                            .enable_payment
                                                        : language
                                                            .disable_payment,
                                                    subtitle: mData.status != 1
                                                        ? language
                                                            .do_you_want_to_enable_this_payment
                                                        : language
                                                            .do_you_want_to_disable_this_payment);
                                              },
                                            ),
                                          ),
                                          DataCell(Row(
                                            children: [
                                              outlineActionIcon(
                                                  Icons.edit,
                                                  Colors.green,
                                                  language.edit, () async {
                                                var res = await Navigator.pushNamed(
                                                    context,
                                                    PaymentSetupScreen.route +
                                                        "?payment_type=${mData.type}");
                                                if (res != null) {
                                                  getPaymentGatewayListApiCall();
                                                }
                                              }),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              outlineActionIcon(
                                                  Icons.delete,
                                                  Colors.red,
                                                  'Delete', () async {
                                                showAlertDialog(
                                                    context, mData.id);
                                              }),
                                            ],
                                          )),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 80),
                          ],
                        )
                      : SizedBox(),
                ],
              ),
            ),
            appStore.isLoading
                ? loaderWidget()
                : paymentGatewayList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        ),
      );
    });
  }

  showAlertDialog(BuildContext context, var id) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        deletePaymentGatewayListApiCall(id);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Alert"),
      content: Text("Are you sure ?"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
