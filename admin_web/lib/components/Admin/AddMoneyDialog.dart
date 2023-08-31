import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_delivery_admin/utils/Extensions/context_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/int_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/string_extensions.dart';
import 'package:local_delivery_admin/utils/Extensions/widget_extensions.dart';

import '../../main.dart';
import '../../network/ClientRestApi.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/text_styles.dart';

class AddMoneyDialog extends StatefulWidget {
  final int? userId;
  final Function()? onUpdate;

  AddMoneyDialog({this.userId,this.onUpdate});

  @override
  AddMoneyDialogState createState() => AddMoneyDialogState();
}

class AddMoneyDialogState extends State<AddMoneyDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController amountCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> saveWalletApi() async {
    appStore.setLoading(true);
    Map req = {
      "user_id": widget.userId,
      "type": "credit",
      "amount": amountCont.text.toDouble(),
      "transaction_type": "topup",
      "currency": appStore.currencyCode,
    };
    await saveWallet(req).then((value) {
      appStore.setLoading(false);
      widget.onUpdate?.call();
      toast(value.message);
    }).catchError((error) {
      toast(error.toString());
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(language.addMoney, style: boldTextStyle(size: 18)),
            Divider(),
            16.height,
            Text(language.amount, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: amountCont,
              textFieldType: TextFieldType.PHONE,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: commonInputDecoration(),
            ),
            30.height,
            appButton(
              context,
              title: language.add,
              onCall: () async {
                if (_formKey.currentState!.validate()) {
                  finish(context);
                  await saveWalletApi();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
