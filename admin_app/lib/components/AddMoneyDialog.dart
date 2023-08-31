import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../network/RestApis.dart';
import '../utils/Extensions/app_common.dart';

class AddMoneyDialog extends StatefulWidget {
  final int? userId;
  final Function()? onUpdate;

  AddMoneyDialog({this.userId, this.onUpdate});

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
      "amount": double.parse(amountCont.text),
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
    // TODO Localization
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Money', style: boldTextStyle(size: 18)),
            Divider(),
            SizedBox(height: 16),
            Text(language.amount, style: primaryTextStyle()),
            SizedBox(height: 8),
            AppTextField(
              controller: amountCont,
              textFieldType: TextFieldType.PHONE,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: commonInputDecoration(),
            ),
            SizedBox(height: 30),
            appCommonButton(language.add, () async {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                await saveWalletApi();
              }
            }, width: MediaQuery.of(context).size.width)
          ],
        ),
      ),
    );
  }
}
