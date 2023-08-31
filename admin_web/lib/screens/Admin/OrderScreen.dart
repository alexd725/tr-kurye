import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_delivery_admin/utils/Extensions/int_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/widget_extensions.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/Admin/DeliveryOrderAssignWidget.dart';
import '/../main.dart';
import '/../models/OrderModel.dart';
import '/../network/RestApis.dart';
import '/../screens/Admin/AdminOrderDetailScreen.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../utils/Extensions/string_extensions.dart';
import '/../utils/Extensions/app_textfield.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/text_styles.dart';
import '../../components/PaginationWidget.dart';

class OrderScreen extends StatefulWidget {
  static String route = '/admin/orders';

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  ScrollController horizontalScrollController = ScrollController();
  TextEditingController orderIdController = TextEditingController();

  String selectedStatus = language.all;
  List<String> statusList = [
    ORDER_DRAFT,
    ORDER_DEPARTED,
    ORDER_ACCEPTED,
    ORDER_CANCELLED,
    ORDER_ASSIGNED,
    ORDER_ARRIVED,
    ORDER_PICKED_UP,
    ORDER_DELIVERED,
    ORDER_CREATED,
    language.all
  ];

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<OrderModel> orderData = [];

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  DateTime? fromDate, toDate;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setSelectedMenuIndex(ORDER_INDEX);
    getOrderListApi();
  }

  getOrderListApi() async {
    appStore.setLoading(true);
    await getAllOrder(
            page: currentPage,
            perPage: perPage,
            orderStatus: selectedStatus != language.all ? selectedStatus : null,
            fromDate: fromDate.toString(),
            toDate: toDate.toString())
        .then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      orderData.clear();
      orderData.addAll(value.data!);

      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
  }

  restoreOrderApiCall({int? orderId, String? type}) async {
    appStore.setLoading(true);
    Map req = {'id': orderId, 'type': type};
    await getRestoreOrderApi(req).then((value) {
      appStore.setLoading(false);
      getOrderListApi();
      toast(value.message);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteOrderApiCall(int OrderId) async {
    appStore.setLoading(true);
    await deleteOrderApi(OrderId).then((value) {
      appStore.setLoading(false);
      getOrderListApi();
      toast(value.message);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    searchOrderWidget() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.order_id, style: boldTextStyle()),
          SizedBox(width: 16),
          SizedBox(
            width: 100,
            height: 35,
            child: AppTextField(
              controller: orderIdController,
              textFieldType: TextFieldType.OTHER,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: commonInputDecoration(),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 16),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(defaultRadius)),
              child:
                  Text(language.go, style: boldTextStyle(color: Colors.white)),
            ),
            onTap: () async {
              int? orderId = int.tryParse(orderIdController.text);
              if (orderId != null) {
                await orderDetail(orderId: orderId).then((value) async {
                  orderIdController.clear();
                  Navigator.pushNamed(context,
                      AdminOrderDetailScreen.route + "?order_Id=$orderId");
                }).catchError((error) {
                  toast(error.toString());
                });
              } else {
                toast(language.pleaseEnterOrderId);
              }
            },
          ),
        ],
      );
    }

    dateSelectionWidget() {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(language.date, style: boldTextStyle()),
          SizedBox(
            width: 170,
            child: DateTimePicker(
              controller: fromDateController,
              type: DateTimePickerType.date,
              lastDate: DateTime.now(),
              firstDate: DateTime(2010),
              onChanged: (value) {
                fromDate = DateTime.parse(value);
                fromDateController.text = value;
                setState(() {});
              },
              decoration: commonInputDecoration(
                  suffixIcon: Icons.calendar_today, hintText: language.from),
            ),
          ),
          SizedBox(
            width: 170,
            child: DateTimePicker(
              controller: toDateController,
              type: DateTimePickerType.date,
              lastDate: DateTime.now(),
              firstDate: fromDate ?? DateTime(2010),
              onChanged: (value) {
                toDate = DateTime.parse(value);
                toDateController.text = value;
                setState(() {});
              },
              decoration: commonInputDecoration(
                  suffixIcon: Icons.calendar_today, hintText: language.to),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red)
                  .onTap(() {
                    fromDate = null;
                    toDate = null;
                    fromDateController.clear();
                    toDateController.clear();
                    getOrderListApi();
                  })
                  .paddingRight(8)
                  .visible(fromDate != null || toDate != null),
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(defaultRadius)),
                  child: Text(language.apply,
                      style: boldTextStyle(color: Colors.white)),
                ),
                onTap: () async {
                  log('$fromDate $toDate');
                  if (fromDate == null) {
                    return toast(language.selectFromDate);
                  } else if (toDate == null) {
                    return toast(language.selectToDate);
                  } else {
                    Duration difference = fromDate!.difference(toDate!);
                    if (difference.inDays >= 0) {
                      return toast(language.toDateMustBeAfterFromDate);
                    } else {
                      getOrderListApi();
                    }
                  }
                },
              ),
            ],
          ),
        ],
      );
    }

    Widget selectStatusWidget() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(language.status, style: boldTextStyle()),
          SizedBox(width: 16),
          SizedBox(
            width: 170,
            child: DropdownButtonFormField(
                isExpanded: true,
                decoration: commonInputDecoration(),
                dropdownColor: Theme.of(context).cardColor,
                value: selectedStatus,
                items: statusList.map<DropdownMenuItem<String>>((mData) {
                  return DropdownMenuItem(
                      value: mData,
                      child: Text(
                          mData != language.all
                              ? orderStatus(mData)
                              : language.all,
                          style: primaryTextStyle()));
                }).toList(),
                onChanged: (String? value) {
                  selectedStatus = value!;
                  currentPage = 1;
                  getOrderListApi();
                  setState(() {});
                }),
          ),
        ],
      );
    }

    return Observer(builder: (context) {
      return BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: ScrollController(),
              padding: EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveWidget.isSmallScreen(context)
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(language.orders,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            searchOrderWidget(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.orders,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            searchOrderWidget(),
                          ],
                        ),
                  SizedBox(height: 16),
                  ResponsiveWidget.isLargeScreen(context)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            selectStatusWidget(),
                            dateSelectionWidget(),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            selectStatusWidget(),
                            16.height,
                            dateSelectionWidget(),
                          ],
                        ),
                  SizedBox(height: 16),
                  Text('* ${language.indicatesAutoAssignOrder}',
                      style: primaryTextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                  orderData.isNotEmpty
                      ? Column(
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
                                      headingTextStyle: boldTextStyle(),
                                      dataTextStyle: primaryTextStyle(size: 15),
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => primaryColor
                                                  .withOpacity(0.1)),
                                      showCheckboxColumn: false,
                                      dataRowHeight: 45,
                                      headingRowHeight: 45,
                                      horizontalMargin: 16,
                                      columns: [
                                        DataColumn(
                                            label: Text(language.order_id)),
                                        DataColumn(
                                            label:
                                                Text(language.customer_name)),
                                        DataColumn(
                                            label:
                                                Text(language.delivery_person)),
                                        DataColumn(label: Text("Vehicle Type")),
                                        DataColumn(
                                            label: Text("Delivery Type")),
                                        DataColumn(
                                            label: Text(language.pickup_date)),
                                        DataColumn(
                                            label:
                                                Text(language.pickup_address)),
                                        DataColumn(
                                            label: Text(
                                                language.delivery_address)),
                                        DataColumn(
                                            label: Text(language.created_date)),
                                        DataColumn(
                                            label: Text(language.status)),
                                        DataColumn(
                                            label: Text(language.assign)),
                                        DataColumn(
                                            label: Text(language.actions)),
                                      ],
                                      rows: orderData.map((e) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                '#${e.id ?? '-'}',
                                                style: primaryTextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  size: 15,
                                                ),
                                              ).onTap(() {
                                                Navigator.pushNamed(
                                                    context,
                                                    AdminOrderDetailScreen
                                                            .route +
                                                        "?order_Id=${e.id!}");
                                              }),
                                            ),
                                            DataCell(Text(
                                                '${e.clientName ?? language.user_deleted}',
                                                style: primaryTextStyle(
                                                    color: e.clientName == null
                                                        ? Colors.red
                                                        : null))),
                                            DataCell(Text(
                                                '${e.deliveryManName != null ? e.deliveryManName : (e.status != ORDER_CREATED && e.status != ORDER_CANCELLED && e.status != ORDER_DRAFT) ? language.delivery_person_deleted : '-'}',
                                                style: primaryTextStyle(
                                                    color: e.deliveryManName ==
                                                                null &&
                                                            (e.status !=
                                                                    ORDER_CREATED &&
                                                                e.status !=
                                                                    ORDER_CANCELLED &&
                                                                e.status !=
                                                                    ORDER_DRAFT)
                                                        ? Colors.red
                                                        : null))),
                                            DataCell(
                                                Text(e.vehicle_type ?? '-')),
                                            DataCell(Text(e.order_type ?? '-')),
                                            DataCell(Text(e.pickupPoint!
                                                        .startTime !=
                                                    null
                                                ? printDate(
                                                    e.pickupPoint!.startTime!)
                                                : '-')),
                                            DataCell(
                                                e.pickupPoint!.address != null
                                                    ? SizedBox(
                                                        width: 250,
                                                        child: Text(
                                                            '${e.pickupPoint!.address ?? '-'}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1),
                                                      )
                                                    : Text('-')),
                                            DataCell(
                                                e.deliveryPoint!.address != null
                                                    ? SizedBox(
                                                        width: 250,
                                                        child: Text(
                                                            '${e.deliveryPoint!.address ?? '-'}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1),
                                                      )
                                                    : Text('-')),
                                            DataCell(
                                                Text(printDate(e.date ?? ''))),
                                            DataCell(
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 12),
                                                decoration: BoxDecoration(
                                                    color: statusColor(
                                                            e.status ?? "")
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            defaultRadius)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                        (orderStatus(
                                                            e
                                                                .status
                                                                .validate())),
                                                        style: boldTextStyle(
                                                            color: statusColor(
                                                                e.status ?? ""),
                                                            size: 14)),
                                                    Text(
                                                        '${e.autoAssign == 1 ? ' *' : ''}',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              e.deletedAt == null
                                                  ? (e.status ==
                                                              ORDER_DELIVERED ||
                                                          e.status ==
                                                              ORDER_CANCELLED ||
                                                          e.status ==
                                                              ORDER_DRAFT)
                                                      ? Text(
                                                          '${language.order} ${orderStatus(e.status!)}',
                                                          style: primaryTextStyle(
                                                              color:
                                                                  primaryColor,
                                                              size: 15))
                                                      : SizedBox(
                                                          height: 25,
                                                          child: ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              await showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) {
                                                                  return Dialog(
                                                                    child:
                                                                        DeliveryOrderAssignWidget(
                                                                      orderModel:
                                                                          e,
                                                                      OrderId:
                                                                          e.id!,
                                                                      onUpdate:
                                                                          () {
                                                                        getOrderListApi();
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Text(
                                                                (e.status ==
                                                                            ORDER_CREATED ||
                                                                        e.deliveryManName ==
                                                                            null)
                                                                    ? language
                                                                        .assign
                                                                    : language
                                                                        .transfer,
                                                                style: primaryTextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    size: 14)),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              defaultRadius)),
                                                            ),
                                                          ),
                                                        )
                                                  : Text(language.order_deleted,
                                                      style: primaryTextStyle(
                                                          color: Colors.red,
                                                          size: 15)),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  if (e.status != ORDER_DRAFT)
                                                    outlineActionIcon(
                                                        Icons.visibility,
                                                        primaryColor,
                                                        language.view, () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          AdminOrderDetailScreen
                                                                  .route +
                                                              "?order_Id=${e.id!}");
                                                    }),
                                                  if (e.status != ORDER_DRAFT)
                                                    SizedBox(width: 8),
                                                  if (e.deletedAt != null &&
                                                      e.clientName != null)
                                                    outlineActionIcon(
                                                        Icons.restore,
                                                        primaryColor,
                                                        language.restore,
                                                        () async {
                                                      await commonConfirmationDialog(
                                                          context,
                                                          DIALOG_TYPE_RESTORE,
                                                          () {
                                                        if (getStringAsync(
                                                                USER_TYPE) ==
                                                            DEMO_ADMIN) {
                                                          toast(language
                                                              .demo_admin_msg);
                                                        } else {
                                                          restoreOrderApiCall(
                                                              orderId: e.id,
                                                              type: RESTORE);
                                                          getOrderListApi();
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                          title: language
                                                              .restore_order,
                                                          subtitle: language
                                                              .do_you_want_to_restore_this_order);
                                                    }),
                                                  if (e.deletedAt != null &&
                                                      e.clientName != null)
                                                    SizedBox(width: 8),
                                                  outlineActionIcon(
                                                      e.deletedAt == null
                                                          ? Icons.delete
                                                          : Icons
                                                              .delete_forever,
                                                      Colors.red,
                                                      '${e.deletedAt == null ? language.delete : language.force_delete}',
                                                      () {
                                                    commonConfirmationDialog(
                                                        context,
                                                        DIALOG_TYPE_DELETE, () {
                                                      if (getStringAsync(
                                                              USER_TYPE) ==
                                                          DEMO_ADMIN) {
                                                        toast(language
                                                            .demo_admin_msg);
                                                      } else {
                                                        e.deletedAt != null
                                                            ? restoreOrderApiCall(
                                                                orderId: e.id,
                                                                type:
                                                                    FORCE_DELETE)
                                                            : deleteOrderApiCall(
                                                                e.id!);
                                                        getOrderListApi();
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                        isForceDelete:
                                                            e.deletedAt != null,
                                                        title: language
                                                            .delete_order,
                                                        subtitle: language
                                                            .do_you_want_to_delete_this_order);
                                                  }),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            paginationWidget(
                              context,
                              currentPage: currentPage,
                              totalPage: totalPage,
                              perPage: perPage,
                              onUpdate: (currentPageVal, perPageVal) {
                                currentPage = currentPageVal;
                                perPage = perPageVal;
                                getOrderListApi();
                              },
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 80),
                ],
              ),
            ),
            appStore.isLoading
                ? loaderWidget()
                : orderData.isEmpty
                    ? emptyWidget()
                    : SizedBox()
          ],
        ),
      );
    });
  }
}
