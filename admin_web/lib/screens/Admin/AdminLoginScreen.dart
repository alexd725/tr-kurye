import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'AdminHomeScreen.dart';
import '../../components/Admin/ForgotPasswordDialog.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../main.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class AdminLoginScreen extends StatefulWidget {
  static String route = '/admin/login';

  @override
  AdminLoginScreenState createState() => AdminLoginScreenState();
}

class AdminLoginScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String fcmToken = '';

  TextEditingController emailController =
      TextEditingController(text: 'admin@admin.com');
  TextEditingController passwordController =
      TextEditingController(text: '12345678');

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await saveFcmTokenId().then((value) {});
  }

  Future<void> logInApiCall() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      appStore.setLoading(true);

      Map req = {
        "email": emailController.text,
        "password": passwordController.text,
        "fcm_token": getStringAsync(FCM_TOKEN).validate(),
      };

      await logInApi(req).then((value) async {
        appStore.setLoading(false);
        if (value.data!.userType != ADMIN &&
            value.data!.userType != DEMO_ADMIN) {
          await logout(context, isFromLogin: true);
        } else {
          Navigator.pushNamed(context, AdminHomeScreen.route);
        }
      }).catchError((e) {
        appStore.setLoading(false);

        toast(e.toString());
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
      body: Row(
        children: [
          if (!ResponsiveWidget.isSmallScreen(context))
            Expanded(
              child: Container(
                color: primaryColor,
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            child: Image.asset('assets/app_logo_primary.png'),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                          ),
                          SizedBox(height: 30),
                          Text(language.app_name,
                              style:
                                  boldTextStyle(color: Colors.white, size: 20)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Container(
              padding:
                  EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 16),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(language.admin_sign_in,
                              style: boldTextStyle(size: 30)),
                          SizedBox(height: 16),
                          Text(language.sign_in_your_account,
                              style: secondaryTextStyle(size: 16)),
                          SizedBox(height: 50),
                          Text(language.email, style: primaryTextStyle()),
                          SizedBox(height: 8),
                          AppTextField(
                            controller: emailController,
                            textFieldType: TextFieldType.EMAIL,
                            decoration: commonInputDecoration(),
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16),
                          Text(language.password, style: primaryTextStyle()),
                          SizedBox(height: 8),
                          AppTextField(
                            controller: passwordController,
                            textFieldType: TextFieldType.PASSWORD,
                            decoration: commonInputDecoration(),
                          ),
                          SizedBox(height: 30),
                          Align(
                            alignment: Alignment.centerRight,
                            child: commonButton(language.login, () {
                              logInApiCall();
                            }, width: 200),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Observer(
                      builder: (context) =>
                          appStore.isLoading ? loaderWidget() : SizedBox()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext dialogContext) {
                              return ForgotPasswordDialog();
                            },
                          );
                        },
                        child: Text(language.forgotPassword,
                            style: primaryTextStyle(color: primaryColor))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
