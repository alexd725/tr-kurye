import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  FocusNode oldPassFocus = FocusNode();
  FocusNode newPassFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

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
      Map req = {
        'old_password': oldPassController.text.trim(),
        'new_password': newPassController.text.trim(),
      };
      appStore.setLoading(true);

      await sharedPref.setString(USER_PASSWORD, newPassController.text.trim());

      await changePassword(req).then((value) {
        toast(value.message.toString());
        appStore.setLoading(false);

        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: Text(language.changePassword)),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, top: 30, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.oldPassword, style: primaryTextStyle()),
                  SizedBox(height: 8),
                  AppTextField(
                    controller: oldPassController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: oldPassFocus,
                    nextFocus: newPassFocus,
                    decoration: commonInputDecoration(),
                    errorThisFieldRequired: language.fieldRequiredMsg,
                    errorMinimumPasswordLength: language.passwordValidation,
                  ),
                  SizedBox(height: 16),
                  Text(language.newPassword, style: primaryTextStyle()),
                  SizedBox(height: 8),
                  AppTextField(
                    controller: newPassController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: newPassFocus,
                    nextFocus: confirmPassFocus,
                    decoration: commonInputDecoration(),
                    errorThisFieldRequired: language.fieldRequiredMsg,
                    errorMinimumPasswordLength: language.passwordValidation,
                  ),
                  SizedBox(height: 16),
                  Text(language.confirmPassword, style: primaryTextStyle()),
                  SizedBox(height: 8),
                  AppTextField(
                    controller: confirmPassController,
                    textFieldType: TextFieldType.PASSWORD,
                    focus: confirmPassFocus,
                    decoration: commonInputDecoration(),
                    errorThisFieldRequired: language.fieldRequiredMsg,
                    errorMinimumPasswordLength: language.passwordValidation,
                    validator: (val) {
                      if (val!.isEmpty) return language.fieldRequiredMsg;
                      if (val != newPassController.text) return language.passwordNotMatch;
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          Observer(builder: (context) => Visibility(visible: appStore.isLoading, child: loaderWidget())),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: dialogPrimaryButton(language.save, () {
          if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
            toast(language.demoAdminMsg);
          } else {
            submit();
          }
        }),
      ),
    );
  }
}
