import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../components/DeliveryOrderAssignComponent.dart';
import '../components/OrderWidgetComponent.dart';
import '../main.dart';
import '../models/OrderModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import '../utils/Common.dart';
import 'OrderDetailScreen.dart';

class OrderListFragment extends StatefulWidget {
  @override
  OrderListFragmentState createState() => OrderListFragmentState();
}

class OrderListFragmentState extends State<OrderListFragment> {
  TextEditingController orderIdController = TextEditingController();
  ScrollController controller = ScrollController();
  String selectedStatus = language.all;
  List<String> statusList = [
    language.all,
    ORDER_ACCEPTED,
    ORDER_ARRIVED,
    ORDER_ASSIGNED,
    ORDER_CANCELLED,
    ORDER_DELIVERED,
    ORDER_CREATED,
    ORDER_DEPARTED,
    ORDER_DRAFT,
    ORDER_PICKED_UP,
  ];

  int currentPage = 1;
  int totalPage = 1;

  List<OrderModel> orderData = [];

  DateTimeRange? picked;
  String? date;
  String? dateMin;
  String? dateMax;

  @override
  void initState() {
    super.initState();
    init();
    setState(() {});
    controller.addListener(() {
      scrollHandler();
    });
  }

  Future<void> scrollHandler() async {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      if (currentPage < totalPage) {
        currentPage++;
        setState(() {});
        getOrderListApi();
      }
    }
  }

  void init() async {
    appStore.setLoading(true);
    afterBuildCreated(() {
      getOrderListApi();
    });
  }

  getOrderListApi() async {
    appStore.setLoading(true);
    //await getAllOrder(page: currentPage, status: selectedStatus != language.all ? selectedStatus : null).then((value) {
    await getAllOrder(
            page: currentPage,
            orderStatus: selectedStatus != language.all ? selectedStatus : null,
            fromDate: dateMin,
            toDate: dateMax)
        .then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        orderData.clear();
      }
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
      currentPage = 1;
      getOrderListApi();
      toast(value.message);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteOrderApiCall(int orderId) async {
    appStore.setLoading(true);
    await deleteOrderApi(orderId).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
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
    return Observer(builder: (context) {
      return Stack(
        children: [
          SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.all(16),
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // TODO Localization
                      Text('${date ?? 'Select Date'}',
                          style: primaryTextStyle()),
                      SizedBox(width: 8),
                      InkWell(
                          child: Icon(Icons.date_range,
                              color: primaryColor, size: 20),
                          onTap: () async {
                            picked = await showDateRangePicker(
                              firstDate: DateTime(1900),
                              initialDateRange: picked,
                              context: context,
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: appStore.isDarkMode
                                      ? ThemeData.dark().copyWith(
                                          colorScheme: ColorScheme.dark(
                                              primary: primaryColor,
                                              onPrimary: Colors.white,
                                              surface: primaryColor,
                                              onSurface: Colors.white),
                                          dialogBackgroundColor:
                                              Theme.of(context).cardColor,
                                        )
                                      : ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                              primary: primaryColor,
                                              surface: primaryColor),
                                        ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 50, horizontal: 16),
                                    child: child,
                                  ),
                                );
                              },
                            );
                            if (picked != null) {
                              date =
                                  "[ ${DateFormat('dd-MM-yyyy').format(picked!.start)} to ${DateFormat('dd-MM-yyyy').format(picked!.end)} ]";
                              dateMin = DateFormat('yyyy-MM-dd')
                                  .format(picked!.start);
                              dateMax =
                                  DateFormat('yyyy-MM-dd').format(picked!.end);
                              setState(() {});
                              getOrderListApi();
                            }
                          }),
                      if (date != null)
                        Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            // TODO Localization
                            child: Text('Clear',
                                style: secondaryTextStyle(color: Colors.red)),
                            onTap: () {
                              date = null;
                              dateMin = null;
                              dateMax = null;
                              picked = null;
                              setState(() {});
                              getOrderListApi();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(language.status, style: boldTextStyle()),
                    SizedBox(width: 30),
                    Expanded(
                      child: DropdownButtonFormField(
                          isExpanded: true,
                          decoration: commonInputDecoration(),
                          dropdownColor: Theme.of(context).cardColor,
                          value: selectedStatus,
                          items:
                              statusList.map<DropdownMenuItem<String>>((mData) {
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
                    )
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(language.orderId, style: boldTextStyle()),
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
                    Spacer(),
                    GestureDetector(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(defaultRadius)),
                        child: Text(language.go,
                            style: boldTextStyle(color: Colors.white)),
                      ),
                      onTap: () async {
                        int? orderId = int.tryParse(orderIdController.text);
                        FocusScope.of(context).unfocus();
                        if (orderId != null) {
                          await orderDetail(orderId: orderId)
                              .then((value) async {
                            orderIdController.clear();
                            launchScreen(
                              context,
                              OrderDetailScreen(
                                  orderId: orderId, orderModel: value.data),
                            );
                          }).catchError((error) {
                            toast(error.toString());
                          });
                        } else {
                          toast(language.pleaseEnterOrderId);
                        }
                      },
                    ),
                  ],
                ),
                orderData.isNotEmpty
                    ? Column(
                        children: [
                          SizedBox(height: 16),
                          Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                  '* ${language.indicatesAutoAssignOrder}',
                                  style: primaryTextStyle(color: Colors.red))),
                          SizedBox(height: 8),
                          ListView.builder(
                              shrinkWrap: true,
                              primary: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: orderData.length,
                              itemBuilder: (context, i) {
                                OrderModel data = orderData[i];
                                return orderWidget(
                                  context,
                                  data,
                                  isFragment: true,
                                  assign: data.deletedAt == null
                                      //? (data.status == ORDER_COMPLETED || data.status == ORDER_CANCELLED || data.status == ORDER_DRAFT)
                                      ? (data.status == ORDER_DELIVERED ||
                                              data.status == ORDER_CANCELLED ||
                                              data.status == ORDER_DRAFT)
                                          ? SizedBox()
                                          : GestureDetector(
                                              onTap: () async {
                                                await showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return DeliveryOrderAssignComponent(
                                                      orderModel: data,
                                                      orderId: data.id!,
                                                      onUpdate: () {
                                                        currentPage = 1;
                                                        getOrderListApi();
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: primaryColor
                                                        .withOpacity(0.8),
                                                    borderRadius: radius(8)),
                                                child: Text(
                                                    data.deliveryManId == null
                                                        ? language.assign
                                                        : language.transfer,
                                                    style: primaryTextStyle(
                                                        color: Colors.white,
                                                        size: 14)),
                                              ),
                                            )
                                      : SizedBox(),
                                  restore: outlineActionIcon(
                                      context, Icons.restore, Colors.green,
                                      () async {
                                    await commonConfirmationDialog(
                                        context, DIALOG_TYPE_RESTORE, () {
                                      if (sharedPref.getString(USER_TYPE) ==
                                          DEMO_ADMIN) {
                                        toast(language.demoAdminMsg);
                                      } else {
                                        Navigator.pop(context);
                                        restoreOrderApiCall(
                                            orderId: data.id, type: RESTORE);
                                      }
                                    },
                                        title: language.restoreOrder,
                                        subtitle: language.restoreOrderMsg);
                                  }),
                                  delete: outlineActionIcon(
                                      context,
                                      data.deletedAt == null
                                          ? Icons.delete
                                          : Icons.delete_forever,
                                      Colors.red, () {
                                    commonConfirmationDialog(
                                        context, DIALOG_TYPE_DELETE, () {
                                      if (sharedPref.getString(USER_TYPE) ==
                                          DEMO_ADMIN) {
                                        toast(language.demoAdminMsg);
                                      } else {
                                        Navigator.pop(context);
                                        data.deletedAt != null
                                            ? restoreOrderApiCall(
                                                orderId: data.id,
                                                type: FORCE_DELETE)
                                            : deleteOrderApiCall(data.id!);
                                      }
                                    },
                                        isForceDelete: data.deletedAt != null,
                                        title: language.deleteOrder,
                                        subtitle: language.deleteOrderMsg);
                                  }),
                                );
                              }),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
          ),
          appStore.isLoading
              ? loaderWidget()
              : orderData.isEmpty
                  ? emptyWidget()
                  : SizedBox()
        ],
      );
    });
  }
}
