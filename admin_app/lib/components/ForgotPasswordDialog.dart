import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Common.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_textfield.dart';

import '../utils/Constants.dart';

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
      contentPadding: EdgeInsets.all(16),
      titlePadding: EdgeInsets.only(left: 16, right: 8, top: 8),
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
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: dialogSecondaryButton(language.cancel, () {
                            Navigator.pop(context);
                          }),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: dialogPrimaryButton(language.submit, () {
                            if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                              toast(language.demoAdminMsg);
                            }else {
                              submit();
                            }
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(visible: appStore.isLoading, child: loaderWidget()),
            ],
          ),
        );
      }),
    );
  }
}
