import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../network/ClientRestApi.dart';
import '../../../screens/Client/OrderDetailScreen.dart';
import '../../../utils/Extensions/int_extensions.dart';
import '../../../utils/Extensions/string_extensions.dart';
import '../../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../models/OrderModel.dart';
import '../../network/RestApis.dart';
import '../../screens/Client/SendPackageFragment.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/DataProvider.dart';
import '../../utils/Extensions/live_stream.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';
import '../Admin/GenerateInvoice.dart';
import '../PaginationWidget.dart';

class OrderComponent extends StatefulWidget {
  static String tag = '/OrderComponent';
  final bool isDraft;

  OrderComponent({this.isDraft = false});

  @override
  OrderComponentState createState() => OrderComponentState();
}

class OrderComponentState extends State<OrderComponent> {
  List<OrderModel> orderList = [];
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    getOrderListApiCall();
    await getAppSetting().then((value) {
      appStore.setCurrencyCode(value.currencyCode ?? defaultCurrencyCode);
      appStore.setCurrencySymbol(value.currency ?? defaultCurrencySymbol);
      appStore.setCurrencyPosition(value.currencyPosition ?? CURRENCY_POSITION_LEFT);
    }).catchError((error) {
      log(error.toString());
    });
    LiveStream().on('UpdateOrderData', (p0) {
      currentPage = 1;
      getOrderListApiCall();
      setState(() {});
    });
  }

  getOrderListApiCall() async {
    appStore.setLoading(true);
    FilterAttributeModel filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
    await getClientOrderList(page: currentPage, perPage: perPage, orderStatus: widget.isDraft ? ORDER_DRAFT : filterData.orderStatus, fromDate: filterData.fromDate, toDate: filterData.toDate).then((value) {
      appStore.setLoading(false);
      appStore.setAllUnreadCount(value.allUnreadCount.validate());

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      orderList.clear();
      orderList.addAll(value.data!);

      if(value.walletData!=null){
        clientStore.availableBal = value.walletData!.totalAmount;
      }

      setState(() {});
    }).catchError((e) {
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
    return Observer(
      builder: (context) {
        return Stack(
          children: [
            if(orderList.isNotEmpty) SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: radius(16)),
                  child: Column(
                    children: [
                      RawScrollbar(
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        controller: horizontalScrollController,
                        thumbVisibility: true,
                        thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                        radius: Radius.circular(defaultRadius),
                        child: SingleChildScrollView(
                          controller: horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(bottom: 16),
                          child: DataTable(
                            headingTextStyle: boldTextStyle(),
                            decoration: boxDecorationWithRoundedCorners(borderRadius: radius(8)),
                            dataTextStyle: primaryTextStyle(size: 15),
                            headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                            showCheckboxColumn: false,
                            dataRowHeight: 45,
                            headingRowHeight: 45,
                            horizontalMargin: 16,
                            columns: [
                              DataColumn(label: Text(language.order_id)),
                              DataColumn(label: Text(language.deliveryMan)),
                              DataColumn(label: Text(language.pickup_date)),
                              DataColumn(label: Text(language.pickup_address)),
                              DataColumn(label: Text(language.created_date)),
                              DataColumn(label: Text(language.status)),
                              DataColumn(label: Text(language.actions)),
                            ],
                            rows: orderList.map((e) {
                              return DataRow(
                                cells: [
                                  DataCell(Text('#${e.id ?? '-'}')),
                                  DataCell(Text(
                                      '${e.deliveryManName != null ? e.deliveryManName : (e.status != ORDER_CREATED && e.status != ORDER_CANCELLED && e.status != ORDER_DRAFT) ? language.delivery_person_deleted : '-'}',
                                      style: primaryTextStyle(color: e.deliveryManName == null && (e.status != ORDER_CREATED && e.status != ORDER_CANCELLED && e.status != ORDER_DRAFT) ? Colors.red : null))),
                                  DataCell(Text(e.pickupPoint!.startTime != null ? printDate(e.pickupPoint!.startTime!) : '-')),
                                  DataCell(e.pickupPoint!.address != null
                                      ? SizedBox(
                                          width: 250,
                                          child: Text('${e.pickupPoint!.address ?? '-'}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                        )
                                      : Text('-')),
                                  DataCell(Text(printDate(e.date ?? ''))),
                                  DataCell(
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                      decoration: BoxDecoration(color: statusColor(e.status ?? "").withOpacity(0.15), borderRadius: BorderRadius.circular(defaultRadius)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text((orderStatus(e.status.validate())), style: boldTextStyle(color: statusColor(e.status ?? ""), size: 14)),
                                          Text('${e.autoAssign == 1 ? ' *' : ''}', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        outlineActionIcon(Icons.edit, primaryColor, language.edit, () {
                                          Navigator.pushNamed(context,SendPackageFragment.route+"?order_Id=${e.id}");
                                        }).paddingRight(8).visible(e.status == ORDER_DRAFT),
                                        outlineActionIcon(Icons.visibility, primaryColor, language.view, () {
                                          Navigator.pushNamed(context,OrderDetailScreen.route+"?order_Id=${e.id}");
                                        }).paddingRight(8).visible(e.status != ORDER_DRAFT),
                                        outlineActionIcon(Icons.download_rounded, primaryColor, language.invoiceCapital, () {
                                          generateInvoiceCall(e);
                                        }).paddingRight(8).visible(e.status != ORDER_DRAFT && e.status != ORDER_CANCELLED),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      16.height,
                      paginationWidget(
                        context,
                        currentPage: currentPage,
                        totalPage: totalPage,
                        perPage: perPage,
                        onUpdate: (currentPageVal, perPageVal) {
                          currentPage = currentPageVal;
                          perPage = perPageVal;
                          getOrderListApiCall();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            appStore.isLoading
                ? loaderWidget()
                : orderList.isEmpty
                ? emptyWidget()
                : SizedBox()
          ],
        );
      }
    );
  }
}
