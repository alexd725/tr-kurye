import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../components/BodyCornerWidget.dart';
import '../network/RestApis.dart';
import '../utils/Common.dart';
import '../utils/Widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

bool mIsDark = false;

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> submit() async {
    Map req = {
      'email': forgotEmailController.text.trim(),
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
    return Scaffold(
      appBar: AppBar(title: Text(language.forgotPassword)),
      body: BodyCornerWidget(
        child: Stack(
          children: [
            Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, top: 30, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.email, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: forgotEmailController,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      errorInvalidEmail: language.emailInvalid,
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomNavigationBar: commonButton(language.submit, () {
        if (formKey.currentState!.validate()) {
          submit();
        }
      }).paddingAll(16),
    );
  }
}
