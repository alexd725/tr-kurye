import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '/../main.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Extensions/app_textfield.dart';
import '/../utils/Constants.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/text_styles.dart';

class ForgotPasswordDialog extends StatefulWidget {
  static String tag = '/ForgotPasswordDialog';

  @override
  ForgotPasswordDialogState createState() => ForgotPasswordDialogState();
}

class ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);
      Map req = {
        'email': forgotEmailController.text.trim(),
      };
      appStore.setLoading(true);

      await forgotPassword(req).then((value) {
        toast(value.message);

        appStore.setLoading(false);
      }).catchError((error) {
        appStore.setLoading(false);

        toast(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.all(16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(language.forgotPassword, style: boldTextStyle(color: primaryColor, size: 20)),
          IconButton(
            icon: Icon(Icons.close),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: Observer(builder: (context) {
        return SingleChildScrollView(
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.email, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: forgotEmailController,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: commonInputDecoration(),
                    ),
                  ],
                ),
              ),
              Visibility(visible: appStore.isLoading, child: loaderWidget()),
            ],
          ),
        );
      }),
      actions: <Widget>[
        dialogSecondaryButton(language.cancel, () {
          Navigator.pop(context);
        }),
        SizedBox(width: 4),
        dialogPrimaryButton(language.submit, () {
          if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
            toast(language.demo_admin_msg);
          }else {
            submit();
          }
        }),
      ],
    );
  }
}
