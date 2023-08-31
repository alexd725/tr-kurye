import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/Extensions/int_extensions.dart';
import '../../../utils/Extensions/string_extensions.dart';
import '../../main.dart';
import '../../network/ClientRestApi.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/text_styles.dart';

class WithdrawMoneyDialog extends StatefulWidget {
  final Function()? onUpdate;

  WithdrawMoneyDialog({this.onUpdate});

  @override
  WithdrawMoneyDialogState createState() => WithdrawMoneyDialogState();
}

class WithdrawMoneyDialogState extends State<WithdrawMoneyDialog> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController addMoneyController = TextEditingController();

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

  Future<void> withDrawRequest() async {
    if (_formKey.currentState!.validate()) {
      appStore.setLoading(true);
      Map req = {
        "user_id": clientStore.clientUid,
        "currency": appStore.currencyCode.toLowerCase(),
        "amount": int.parse(addMoneyController.text),
        "status": REQUESTED,
      };
      await saveWithDrawRequest(req).then((value) {
        toast(value.message);
        Navigator.pop(context);
        widget.onUpdate?.call();
        appStore.setLoading(false);
      }).catchError((error) {
        Navigator.pop(context);
        toast(error.toString());
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(language.addMoney,
              style: boldTextStyle(color: primaryColor, size: 20)),
          IconButton(
            icon: Icon(Icons.close),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(language.amount, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: addMoneyController,
              textFieldType: TextFieldType.PHONE,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (a) {
                log(a);
                if (a.toInt() >= clientStore.availableBal) {
                  //var addMoneyController;
                  addMoneyController.text = clientStore.availableBal
                      .toStringAsFixed(digitAfterDecimal);
                }
              },
              decoration: commonInputDecoration(),
            ),
            16.height,
            appButton(
              context,
              title: language.withdraw,
              onCall: () async {
                await withDrawRequest();
              },
            ),
          ],
        ),
      ),
    );
  }
}
