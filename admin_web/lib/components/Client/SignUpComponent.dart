import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../network/RestApis.dart';
import '../../screens/Client/DashboardScreen.dart';
import '../../screens/Client/PrivacyPolicyScreen.dart';
import '../../screens/Client/TermAndConditionScreen.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../services/AuthServices.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';
import 'SignInComponent.dart';
import 'UserCitySelectComponent.dart';

class SignUpComponent extends StatefulWidget {
  static String tag = '/signUp';

  @override
  SignUpComponentState createState() => SignUpComponentState();
}

class SignUpComponentState extends State<SignUpComponent> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthServices authService = AuthServices();
  String countryCode = '+91';

  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool isAcceptedTc = false;

  Future<void> registerApiCall() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isAcceptedTc) {
        finish(context);
        appStore.setLoading(true);
        var request = {
          "name": nameController.text,
          "username": userNameController.text,
          "user_type": CLIENT,
          "contact_number": '$countryCode ${phoneController.text.trim()}',
          "email": emailController.text.trim(),
          "password": passController.text.trim(),
          "player_id": getStringAsync(USER_PLAYER_ID).validate(),
        };
        await signUpApi(request).then((res) async {
          authService
              .signUpWithEmailPassword(getContext,
                  lName: res.data!.name,
                  userName: res.data!.username,
                  name: res.data!.name,
                  email: res.data!.email,
                  password: passController.text.trim(),
                  mobileNumber: res.data!.contactNumber,
                  userType: res.data!.userType,userData:res)
              .then((res) async {
            appStore.setLoading(false);
          }).catchError((e) {
            appStore.setLoading(false);
            log(e.toString());
            toast(e.toString());
          });
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
          log(e.toString());
          return;
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
        content: SingleChildScrollView(
          child: Container(
            width: ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.8 : context.width() * 0.4,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.signUp, style: boldTextStyle(size: 20, color: primaryColor)),
                      16.width,
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  8.height,
                  Text(language.signUpYourAcc, style: secondaryTextStyle()),
                  30.height,
                  Text(language.name, style: primaryTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    controller: nameController,
                    textFieldType: TextFieldType.NAME,
                    focus: nameFocus,
                    nextFocus: userNameFocus,
                    decoration: commonInputDecoration(),
                    errorThisFieldRequired: language.field_required_msg,
                  ),
                  16.height,
                  Text(language.username, style: primaryTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    controller: userNameController,
                    textFieldType: TextFieldType.USERNAME,
                    focus: userNameFocus,
                    nextFocus: emailFocus,
                    decoration: commonInputDecoration(),
                    errorThisFieldRequired: language.field_required_msg,
                    errorInvalidUsername: language.usernameErrorText,
                  ),
                  16.height,
                  Text(language.email, style: primaryTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    focus: emailFocus,
                    nextFocus: phoneFocus,
                    decoration: commonInputDecoration(),
                    errorThisFieldRequired: language.field_required_msg,
                    errorInvalidEmail: language.emailValidation,
                  ),
                  16.height,
                  Text(language.contactNumber, style: primaryTextStyle(size: 14)),
                  8.height,
                  AppTextField(
                    controller: phoneController,
                    textFieldType: TextFieldType.PHONE,
                    focus: phoneFocus,
                    nextFocus: passFocus,
                    decoration: commonInputDecoration(
                      prefixIcon: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CountryCodePicker(
                              initialSelection: countryCode,
                              showCountryOnly: false,
                              dialogSize: Size(context.width() - 60, context.height() * 0.6),
                              showFlag: true,
                              showFlagDialog: true,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: primaryTextStyle(),
                              dialogBackgroundColor: Theme.of(context).cardColor,
                              barrierColor: Colors.black12,
                              dialogTextStyle: primaryTextStyle(),
                              searchDecoration: InputDecoration(
                                iconColor: Theme.of(context).dividerColor,
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                              ),
                              searchStyle: primaryTextStyle(),
                              onInit: (c) {
                                countryCode = c!.dialCode!;
                              },
                              onChanged: (c) {
                                countryCode = c.dialCode!;
                              },
                            ),
                            VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.trim().isEmpty) return language.field_required_msg;
                      if (value.trim().length < minContactLength || value.trim().length > maxContactLength) return language.contact_length_validation;
                      return null;
                    },
                  ),
                  16.height,
                  Text(language.password, style: primaryTextStyle()),
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
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: language.agreeText, style: primaryTextStyle(size: 14)),
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
                      ),
                    ),
                    value: isAcceptedTc,
                    onChanged: (val) async {
                      isAcceptedTc = val!;
                      if (!isAcceptedTc) {
                        removeKey(REMEMBER_ME);
                      }
                      setState(() {});
                    },
                  ),
                  30.height,
                  appButton(context, title: language.signUp, onCall: () {
                    registerApiCall();
                  }),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(language.alreadyAcc, style: primaryTextStyle(size: 14)),
                      4.width,
                      Text(language.signIn, style: boldTextStyle(color: primaryColor, size: 14)).onTap(() {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (_) {
                              return SignInComponent();
                            });
                      }),
                    ],
                  ),
                  16.height,
                ],
              ),
            ),
          ),
        ).paddingSymmetric(horizontal: 24, vertical: 16));
  }
}
