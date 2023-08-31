import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../screens/Client/PrivacyPolicyScreen.dart';
import '../../screens/Client/TermAndConditionScreen.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../services/AuthServices.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../screens/Admin/AdminLoginScreen.dart';
import '../../screens/Client/DashboardScreen.dart';
import '../../screens/Admin/AdminHomeScreen.dart';
import 'ForgotPasswordComponent.dart';
import 'SignUpComponent.dart';
import 'UserCitySelectComponent.dart';

class SignInComponent extends StatefulWidget {
  static const String route = '/signIn';

  @override
  SignInComponentState createState() => SignInComponentState();
}

class SignInComponentState extends State<SignInComponent> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthServices authServices = AuthServices();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    saveFcmTokenId();
  }

  Future<void> loginApiCall(context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      if (isAcceptedTc) {
        finish(context);
        appStore.setLoading(true);

        Map req = {
          "email": emailController.text,
          "password": passController.text,
          "fcm_token": getStringAsync(FCM_TOKEN).validate(),
        };

        if (mIsCheck) {
          await setValue(REMEMBER_ME, mIsCheck);
          await setValue(USER_EMAIL, emailController.text);
          await setValue(USER_PASSWORD, passController.text);
        }
        await logInApi(req).then((v) async {
          authServices.signInWithEmailPassword(context, email: emailController.text, password: passController.text).then((value) async {
            appStore.setLoading(false);
            if (v.data!.userType != CLIENT) {
              await logout(context, isFromLogin: true);
            } else {
              if (getIntAsync(USER_STATUS) == 1) {
                if (v.data!.countryId != null && v.data!.cityId != null) {
                  await getCountryDetailApiCall(v.data!.countryId.validate(), context);
                  await getCityDetailApiCall(v.data!.cityId.validate(), context);
                } else {
                  await showDialog(
                      context: getContext,
                      builder: (_) {
                        return UserCitySelectScreen(
                          onUpdate: () {
                            Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.route, (route) {
                              return true;
                            });
                          },
                        );
                      });
                }
              } else {
                toast(language.waitYorAdmin);
              }
            }
          });
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
        });
      } else {
        toast(language.acceptTermsAndCondition);
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: radius(16)),
      backgroundColor: Colors.white,
      content: Container(
        width: ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.8 : context.width() * 0.4,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.signIn, style: boldTextStyle(size: 20, color: primaryColor)),
                  16.width,
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  )
                ],
              ),
              Text(language.signInCredential, style: secondaryTextStyle()),
              30.height,
              Text(language.email, style: primaryTextStyle(size: 14)),
              8.height,
              AppTextField(
                controller: emailController,
                textFieldType: TextFieldType.EMAIL,
                focus: emailFocus,
                nextFocus: passFocus,
                decoration: commonInputDecoration(),
                errorThisFieldRequired: language.field_required_msg,
                errorInvalidEmail: language.emailValidation,
              ),
              16.height,
              Text(language.password, style: primaryTextStyle(size: 14)),
              8.height,
              AppTextField(
                controller: passController,
                textFieldType: TextFieldType.PASSWORD,
                focus: passFocus,
                decoration: commonInputDecoration(),
                errorThisFieldRequired: language.field_required_msg,
                errorMinimumPasswordLength: language.passwordValidation,
              ),
              8.height,
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: primaryColor,
                title: Text(language.rememberMe, style: primaryTextStyle(size: 14)),
                value: mIsCheck,
                onChanged: (val) async {
                  mIsCheck = val!;
                  if (!mIsCheck) {
                    removeKey(REMEMBER_ME);
                  }
                  setState(() {});
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: primaryColor,
                title: RichText(
                    text: TextSpan(
                  children: [
                    TextSpan(text: language.agreeText + " ", style: primaryTextStyle(size: 14)),
                    TextSpan(
                      text: language.termsOfService,
                      style: boldTextStyle(color: primaryColor, size: 14),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                           Navigator.of(context).pushNamed(TermAndConditionScreen.route);
                        },
                    ),
                    TextSpan(text: ' & ', style: primaryTextStyle(size: 14)),
                    TextSpan(
                      text: language.privacyPolicy,
                      style: boldTextStyle(color: primaryColor, size: 14),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushNamed(PrivacyPolicyScreen.route);
                        },
                    ),
                  ],
                )),
                value: isAcceptedTc,
                onChanged: (val) async {
                  isAcceptedTc = val!;
                  setState(() {});
                },
              ),
              16.height,
              appButton(context, title: language.signIn, onCall: () {
                loginApiCall(context);
              }),
              8.height,
              Align(
                alignment: Alignment.topRight,
                child: Text(language.forgotPassword, style: primaryTextStyle(size: 14, color: primaryColor)).onTap(() {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) {
                        return ForgotPasswordComponent();
                      });
                }, splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent),
              ),
              22.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(language.dontHaveAcc, style: primaryTextStyle(size: 14)),
                  4.width,
                  Text(language.signUp, style: boldTextStyle(color: primaryColor, size: 14)).onTap(() {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return SignUpComponent();
                        });
                  }, splashColor: Colors.transparent, hoverColor: Colors.transparent, highlightColor: Colors.transparent),
                ],
              ),
              24.height,
              InkWell(
                onTap: () {
                  finish(context);
                  if (appStore.isLoggedIn && (getStringAsync(USER_TYPE) == ADMIN || getStringAsync(USER_TYPE) == DEMO_ADMIN)) {
                    Navigator.pushNamed(context, AdminHomeScreen.route);
                  } else {
                    Navigator.pushNamed(context, AdminLoginScreen.route);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(borderRadius: radius(defaultRadius), color: primaryColor),
                  child: Text(language.loginAsAdmin, style: boldTextStyle(color: Colors.white)),
                ),
              ).center(),
            ],
          ).paddingSymmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
