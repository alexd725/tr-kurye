import 'package:flutter/material.dart';
import '../../../../utils/Extensions/context_extensions.dart';
import '../../../../utils/Extensions/int_extensions.dart';
import '../../../../utils/Extensions/string_extensions.dart';
import '../../../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../network/ClientRestApi.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/DataProvider.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/text_styles.dart';

class CancelOrderComponent extends StatefulWidget {
  static String tag = '/CancelOrderComponent';
  final int orderId;
  final Function? onUpdate;

  CancelOrderComponent({required this.orderId, this.onUpdate});

  @override
  CancelOrderComponentState createState() => CancelOrderComponentState();
}

class CancelOrderComponentState extends State<CancelOrderComponent> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController reasonController = TextEditingController();
  String? reason;

  List<String> cancelOrderReasonList = getCancelReasonList();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  updateOrderApiCall() async {
    finish(context);
    appStore.setLoading(true);
    await updateOrder(
      orderId: widget.orderId,
      reason: reason!.validate().trim() != 'Other' ? reason : reasonController.text,
      orderStatus: ORDER_CANCELLED,
    ).then((value) {
      appStore.setLoading(false);
      widget.onUpdate!.call();
      toast(language.orderCancelSuccessfully);
    }).catchError((error) {
      appStore.setLoading(false);

      log(error);
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
        content: SingleChildScrollView(
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
                      Text(language.cancelOrder, style: boldTextStyle(size: 20, color: primaryColor)),
                      16.width,
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  Text(language.selectReason, style: secondaryTextStyle()),
                  16.height,
                  DropdownButtonFormField<String>(
                    value: reason,
                    isExpanded: true,
                    decoration: commonInputDecoration(),
                    items: cancelOrderReasonList.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
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
                    decoration: commonInputDecoration(hintText: language.writeMsg),
                    maxLines: 3,
                    minLines: 3,
                    validator: (value) {
                      if (value!.isEmpty) return language.field_required_msg;
                      return null;
                    },
                  ).visible(reason.validate().trim() == 'Other'),
                  30.height,
                  appButton(context, title: language.saveChanges, onCall: () {
                    if (formKey.currentState!.validate()) {
                      updateOrderApiCall();
                    }
                  }),
                  16.height,
                ],
              ),
            ),
          ),
        ).paddingSymmetric(horizontal: 24, vertical: 16));
  }
}
