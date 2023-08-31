import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import '../../models/OrderModel.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../models/Client/PaymentModel.dart';
import '../../network/ClientRestApi.dart';
import '../../network/RestApis.dart';
import '../../screens/Client/DashboardScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/DataProvider.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class ReturnOrderComponent extends StatefulWidget {
  static String tag = '/ReturnOrderComponent';
  final OrderModel orderData;
  final Function? onUpdate;

  ReturnOrderComponent(this.orderData, {this.onUpdate});

  @override
  ReturnOrderComponentState createState() => ReturnOrderComponentState();
}

class ReturnOrderComponentState extends State<ReturnOrderComponent> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isDeliverNow = true;
  DateTime? pickDate, deliverDate;
  TimeOfDay? pickFromTime, pickToTime, deliverFromTime, deliverToTime;

  List<PaymentModel> mPaymentList = getPaymentItems();

  String paymentCollectFrom = PAYMENT_ON_PICKUP;

  TextEditingController reasonController = TextEditingController();
  String? reason;

  List<String> returnOrderReasonList = getReturnReasonList();

  int isSelected = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  createOrderApiCall() async {
    if (formKey.currentState!.validate()) {
      Duration difference = Duration();
      if (!isDeliverNow) {
        DateTime pickFromDateTime = pickDate!.add(Duration(hours: pickFromTime!.hour, minutes: pickFromTime!.minute));
        DateTime pickToDateTime = pickDate!.add(Duration(hours: pickToTime!.hour, minutes: pickToTime!.minute));
        DateTime deliverFromDateTime = deliverDate!.add(Duration(hours: deliverFromTime!.hour, minutes: deliverFromTime!.minute));
        DateTime deliverToDateTime = deliverDate!.add(Duration(hours: deliverToTime!.hour, minutes: deliverToTime!.minute));
        widget.orderData.deliveryPoint!.startTime = pickFromDateTime.toString();
        widget.orderData.deliveryPoint!.endTime = pickToDateTime.toString();
        widget.orderData.pickupPoint!.startTime = deliverFromDateTime.toString();
        widget.orderData.pickupPoint!.endTime = deliverToDateTime.toString();
        difference = pickFromDateTime.difference(deliverFromDateTime);
      } else {
        widget.orderData.pickupPoint!.startTime = DateTime.now().toString();
        widget.orderData.pickupPoint!.endTime = null;
        widget.orderData.deliveryPoint!.startTime = null;
        widget.orderData.deliveryPoint!.endTime = null;
      }
      if (difference.inMinutes > 0) return toast(language.pickup_deliver_validation_msg);
      Map req = {
        "client_id": widget.orderData.clientId!,
        "date": DateTime.now().toString(),
        "country_id": widget.orderData.countryId!,
        "city_id": widget.orderData.cityId!,
        "pickup_point": widget.orderData.deliveryPoint!,
        "delivery_point": widget.orderData.pickupPoint!,
        "extra_charges": widget.orderData.extraCharges!,
        "parcel_type": widget.orderData.parcelType!,
        "total_weight": widget.orderData.totalWeight!,
        "total_distance": widget.orderData.totalDistance!,
        "payment_collect_from": paymentCollectFrom,
        "status": ORDER_CREATED,
        "payment_type": "",
        "payment_status": "",
        "fixed_charges": widget.orderData.fixedCharges!,
        "parent_order_id": widget.orderData.id!,
        "total_amount": widget.orderData.totalAmount!,
        "reason": reason!.validate().trim() != 'Other' ? reason : reasonController.text
      };
      appStore.setLoading(true);
      await createOrder(req).then((value) {
        appStore.setLoading(false);
        toast(value.message);
        widget.onUpdate!.call();
        finish(context);
        if (isSelected == 2) {
          log("-----" + clientStore.availableBal.toString() + widget.orderData.totalAmount.toString());

          if (clientStore.availableBal > widget.orderData.totalAmount!) {
            savePaymentApiCall(paymentType: PAYMENT_TYPE_WALLET, paymentStatus: PAYMENT_PAID, totalAmount: widget.orderData.totalAmount.toString(), orderID: value.orderId.toString());
          } else {
            toast(language.lessAmountBal);
            cashConfirmDialog();
          }
        }
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }
  }

  /// Save Payment
  Future<void> savePaymentApiCall({String? paymentType, String? totalAmount, String? orderID, String? txnId, String? paymentStatus = PAYMENT_PENDING, Map? transactionDetail}) async {
    Map req = {
      "id": "",
      "order_id": orderID,
      "client_id": getIntAsync(USER_ID).toString(),
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
      "total_amount": totalAmount,
      "payment_type": paymentType,
      "txn_id": txnId,
      "payment_status": paymentStatus,
      "transaction_detail": transactionDetail ?? {}
    };

    appStore.setLoading(true);

    savePayment(req).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString());
      Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route, (route) { return true;});
    }).catchError((error) {
      appStore.setLoading(false);
      print(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        elevation: 0,
        contentPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: radius(16)),
        backgroundColor: Colors.white,
        content: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.8 : context.width() * 0.3,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.returnOrder, style: boldTextStyle(size: 20, color: primaryColor)),
                          16.width,
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      16.height,
                      Row(
                        children: [
                          clientScheduleOptionWidget(context, isDeliverNow, MaterialCommunityIcons.clock_time_five_outline,language.deliver_now).onTap(() {
                            isDeliverNow = true;
                            setState(() {});
                          }).expand(),
                          16.width,
                          clientScheduleOptionWidget(context, !isDeliverNow, AntDesign.calendar, language.schedule).onTap(() {
                            isDeliverNow = false;
                            setState(() {});
                          }).expand(),
                        ],
                      ),
                      16.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.pick_time, style: primaryTextStyle()),
                          16.height,
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor, width: 1),
                              borderRadius: BorderRadius.circular(defaultRadius),
                            ),
                            child: Column(
                              children: [
                                DateTimePicker(
                                  type: DateTimePickerType.date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2050),
                                  onChanged: (value) {
                                    pickDate = DateTime.parse(value);
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) return errorThisFieldRequired;
                                    return null;
                                  },
                                  decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                                ),
                                16.height,
                                Row(
                                  children: [
                                    Text(language.from, style: primaryTextStyle()).expand(flex: 1),
                                    8.width,
                                    DateTimePicker(
                                      type: DateTimePickerType.time,
                                      onChanged: (value) {
                                        pickFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value.validate().isEmpty) return errorThisFieldRequired;
                                        return null;
                                      },
                                      decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                    ).expand(flex: 2),
                                  ],
                                ),
                                16.height,
                                Row(
                                  children: [
                                    Text(language.to, style: primaryTextStyle()).expand(flex: 1),
                                    8.width,
                                    DateTimePicker(
                                      type: DateTimePickerType.time,
                                      onChanged: (value) {
                                        pickToTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value.validate().isEmpty) return errorThisFieldRequired;
                                        double fromTimeInHour = pickFromTime!.hour + pickFromTime!.minute / 60;
                                        double toTimeInHour = pickToTime!.hour + pickToTime!.minute / 60;
                                        double difference = toTimeInHour - fromTimeInHour;
                                        print(difference);
                                        if (difference <= 0) {
                                          return language.end_start_time_validation_msg;
                                        }
                                        return null;
                                      },
                                      decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                    ).expand(flex: 2),
                                  ],
                                )
                              ],
                            ),
                          ),
                          16.height,
                          Text(language.deliver_time, style: primaryTextStyle()),
                          16.height,
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderColor, width: 1),
                              borderRadius: BorderRadius.circular(defaultRadius),
                            ),
                            child: Column(
                              children: [
                                DateTimePicker(
                                  type: DateTimePickerType.date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2050),
                                  onChanged: (value) {
                                    deliverDate = DateTime.parse(value);
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) return errorThisFieldRequired;
                                    return null;
                                  },
                                  decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
                                ),
                                16.height,
                                Row(
                                  children: [
                                    Text(language.from, style: primaryTextStyle()).expand(flex: 1),
                                    8.width,
                                    DateTimePicker(
                                      type: DateTimePickerType.time,
                                      onChanged: (value) {
                                        deliverFromTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value.validate().isEmpty) return errorThisFieldRequired;
                                        return null;
                                      },
                                      decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                    ).expand(flex: 2),
                                  ],
                                ),
                                16.height,
                                Row(
                                  children: [
                                    Text(language.to, style: primaryTextStyle()).expand(flex: 1),
                                    8.width,
                                    DateTimePicker(
                                      type: DateTimePickerType.time,
                                      onChanged: (value) {
                                        deliverToTime = TimeOfDay.fromDateTime(DateFormat('hh:mm').parse(value));
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) return errorThisFieldRequired;
                                        double fromTimeInHour = deliverFromTime!.hour + deliverFromTime!.minute / 60;
                                        double toTimeInHour = deliverToTime!.hour + deliverToTime!.minute / 60;
                                        double difference = toTimeInHour - fromTimeInHour;
                                        if (difference < 0) {
                                          return language.end_start_time_validation_msg;
                                        }
                                        return null;
                                      },
                                      decoration: commonInputDecoration(suffixIcon: Icons.access_time),
                                    ).expand(flex: 2),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ).visible(!isDeliverNow),
                      16.height.visible(!isDeliverNow),
                      Text(language.payment, style: boldTextStyle()),
                      16.height,
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: mPaymentList.map((mData) {
                          return mData.title == PAYMENT_TYPE_WALLET && clientStore.availableBal < widget.orderData.totalAmount!
                              ? SizedBox()
                              : Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: boxDecorationWithRoundedCorners(border: Border.all(color: isSelected == mData.index ? primaryColor : borderColor), backgroundColor: context.cardColor),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ImageIcon(AssetImage(mData.image!), size: 20, color: isSelected == mData.index ? primaryColor : Colors.grey),
                                      16.width,
                                      Text(mData.title.validate().capitalizeFirstLetter(), style: boldTextStyle()),
                                    ],
                                  ),
                                ).onTap(() {
                                  isSelected = mData.index!;
                                  setState(() {});
                                });
                        }).toList(),
                      ),
                      16.height,
                      Row(
                        children: [
                          Text(language.paymentCollectFrom, style: boldTextStyle()),
                          16.width,
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: paymentCollectFrom,
                            decoration: commonInputDecoration(),
                            items: [
                              DropdownMenuItem(value: PAYMENT_ON_PICKUP, child: Text(language.pickup_location, style: primaryTextStyle(), maxLines: 1)),
                              DropdownMenuItem(value: PAYMENT_ON_DELIVERY, child: Text(language.delivery_location, style: primaryTextStyle(), maxLines: 1)),
                            ],
                            onChanged: (value) {
                              paymentCollectFrom = value!;
                              setState(() {});
                            },
                          ).expand(),
                        ],
                      ).visible(isSelected == 1),
                      16.height.visible(isSelected == 1),
                      Text(language.reason, style: boldTextStyle()),
                      8.height,
                      DropdownButtonFormField<String>(
                        value: reason,
                        isExpanded: true,
                        decoration: commonInputDecoration(),
                        items: returnOrderReasonList.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (String? val) {
                          reason = val;
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null) return language.field_required_msg;
                          return null;
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: reasonController,
                        textFieldType: TextFieldType.OTHER,
                        decoration: commonInputDecoration(hintText: language.writeHereReason),
                        maxLines: 3,
                        minLines: 3,
                        validator: (value) {
                          if (value!.isEmpty) return language.field_required_msg;
                          return null;
                        },
                      ).visible(reason.validate().trim() == 'Other'),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.total, style: boldTextStyle()),
                          16.width,
                          Text('${printAmount(widget.orderData.totalAmount ?? 0)}', style: boldTextStyle(size: 20)),
                        ],
                      ),
                      30.height,
                      appButton(context, title: language.saveChanges, onCall: () {
                        createOrderApiCall();
                      }),
                      16.height,
                    ],
                  ),
                ),
              ),
            ).paddingSymmetric(horizontal: 24, vertical: 16),
            Observer(builder: (context) => Positioned.fill(child: loaderWidget().visible(appStore.isLoading))),
          ],
        ));
  }
}
