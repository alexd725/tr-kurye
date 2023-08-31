import '../../utils/Common.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import 'package:flutter/material.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePassword';

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

  init() async {
    //
  }

  Future<void> submit() async {
    Map req = {
      'old_password': oldPassController.text.trim(),
      'new_password': newPassController.text.trim(),
    };
    appStore.setLoading(true);

    await setValue(USER_PASSWORD, newPassController.text.trim());

    await changePassword(req).then((value) {
      toast(value.message.toString());
      oldPassController.clear();
      newPassController.clear();
      confirmPassController.clear();
      appStore.setLoading(false);
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
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.changePassword, style: boldTextStyle(color: primaryColor)),
            8.height,
            Divider(color: borderColor, height: 1, thickness: 1),
            20.height,
            Text(language.oldPassword, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: oldPassController,
              textFieldType: TextFieldType.PASSWORD,
              focus: oldPassFocus,
              nextFocus: newPassFocus,
              decoration: commonInputDecoration(),
            ),
            16.height,
            Text(language.newPassword, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: newPassController,
              textFieldType: TextFieldType.PASSWORD,
              focus: newPassFocus,
              nextFocus: confirmPassFocus,
              decoration: commonInputDecoration(),
            ),
            16.height,
            Text(language.confirmPassword, style: primaryTextStyle()),
            8.height,
            AppTextField(
              controller: confirmPassController,
              textFieldType: TextFieldType.PASSWORD,
              focus: confirmPassFocus,
              decoration: commonInputDecoration(),
              validator: (val) {
                if (val!.isEmpty) return language.field_required_msg;
                if (val.trim().length < 6) return language.passwordValidation;
                if (val != newPassController.text) return language.passwordNotMatch;
                return null;
              },
            ),
            22.height,
            appButton(context, title: language.saveChanges, onCall: () {
              if (formKey.currentState!.validate()) {
                submit();
              }
            })
          ],
        ),
      ),
    );
  }
}
