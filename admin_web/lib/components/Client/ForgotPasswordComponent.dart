import 'package:flutter/material.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/text_styles.dart';

class ForgotPasswordComponent extends StatefulWidget {
  static String tag = '/forgotPassword';

  @override
  ForgotPasswordComponentState createState() => ForgotPasswordComponentState();
}

class ForgotPasswordComponentState extends State<ForgotPasswordComponent> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async{
    //
  }

  Future<void> submit() async {
    Map req = {
      'email': emailController.text.trim(),
    };
    appStore.setLoading(true);

    await forgotPassword(req).then((value) {
      toast(value.message.validate());

      appStore.setLoading(false);

      finish(context);
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
    return AlertDialog(
      elevation: 0,
      contentPadding: EdgeInsets.all(30),
      shape: RoundedRectangleBorder(borderRadius: radius(16)),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Container(
          width: ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.8:context.width() * 0.4,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.forgotPassword, style: boldTextStyle(size: 20, color: primaryColor)),
                    16.width,
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close))
                  ],
                ),
                Text(language.forgotPassText, style: secondaryTextStyle()),
                30.height,
                Text(language.email, style: primaryTextStyle(size: 14)),
                8.height,
                AppTextField(
                  controller: emailController,
                  textFieldType: TextFieldType.EMAIL,
                  decoration: commonInputDecoration(),
                ),
                16.height,
                appButton(context, title: language.submit,onCall: (){
                  if (formKey.currentState!.validate()) {
                    submit();
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}