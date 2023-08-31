import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../main.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import 'package:flutter/material.dart';
import '../../utils/Common.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/colors.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/editProfile';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String countryCode = defaultPhoneCode;

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  XFile? imageProfile;
  Uint8List? image;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    String phoneNum = getStringAsync(USER_CONTACT_NUMBER);
    emailController.text = getStringAsync(USER_EMAIL);
    usernameController.text = getStringAsync(USER_NAME);
    nameController.text = getStringAsync(NAME);
    if (phoneNum.split(" ").length == 1) {
      contactNumberController.text = phoneNum.split(" ").last;
    } else {
      countryCode = phoneNum.split(" ").first;
      contactNumberController.text = phoneNum.split(" ").last;
    }
    addressController.text = getStringAsync(USER_ADDRESS).validate();
  }

  Widget profileImage() {
    if (image != null) {
      return ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.memory(image!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  alignment: Alignment.center))
          .center();
    } else {
      if (appStore.userProfile.isNotEmpty) {
        return ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: commonCachedNetworkImage(appStore.userProfile,
                    fit: BoxFit.cover, height: 100, width: 100))
            .center();
      } else {
        return Padding(
          padding: EdgeInsets.only(right: 4, bottom: 4),
          child: ClipRRect(
                  child: commonCachedNetworkImage('assets/profile.png',
                      height: 90, width: 90))
              .center(),
        );
      }
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    image = await imageProfile!.readAsBytes();
    setState(() {});
  }

  Future<void> save() async {
    await updateProfile(
      image: image,
      fileName: imageProfile != null
          ? imageProfile!.path.split('/').last
          : getStringAsync(USER_PROFILE_PHOTO).split('/').last,
      name: nameController.text.validate(),
      userName: usernameController.text.validate(),
      userEmail: emailController.text.validate(),
      address: addressController.text.validate(),
      contactNumber: '$countryCode ${contactNumberController.text.trim()}',
    ).then((value) {
      finish(context);
      appStore.setLoading(false);
      toast(language.updateSuccessfully);
    }).catchError((error) {
      log(error);
      appStore.setLoading(false);
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
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: radius(16)),
      backgroundColor: Colors.white,
      content: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: ResponsiveWidget.isSmallScreen(context)
                  ? context.width() * 0.8
                  : context.width() * 0.4,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.editProfile,
                            style:
                                boldTextStyle(size: 20, color: primaryColor)),
                        16.width,
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                        )
                      ],
                    ),
                    16.height,
                    Stack(
                      children: [
                        profileImage(),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(top: 60, left: 80),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: primaryColor),
                            child: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon:
                                  Icon(Icons.edit, color: whiteColor, size: 20),
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ),
                          ),
                        )
                      ],
                    ),
                    20.height,
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.email, style: primaryTextStyle()),
                            8.height,
                            AppTextField(
                              readOnly: true,
                              controller: emailController,
                              textFieldType: TextFieldType.EMAIL,
                              focus: emailFocus,
                              nextFocus: usernameFocus,
                              decoration: commonInputDecoration(),
                              onTap: () {
                                toast(language.youCannotChangeEmailId);
                              },
                            ),
                          ],
                        ).expand(),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.username, style: primaryTextStyle()),
                            8.height,
                            AppTextField(
                              readOnly: true,
                              controller: usernameController,
                              textFieldType: TextFieldType.USERNAME,
                              focus: usernameFocus,
                              nextFocus: nameFocus,
                              decoration: commonInputDecoration(),
                              onTap: () {
                                toast(language.youCannotChangeUsername);
                              },
                            ),
                          ],
                        ).expand(),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.name, style: primaryTextStyle()),
                            8.height,
                            AppTextField(
                              controller: nameController,
                              textFieldType: TextFieldType.NAME,
                              focus: nameFocus,
                              nextFocus: addressFocus,
                              decoration: commonInputDecoration(),
                            ),
                          ],
                        ).expand(),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.address, style: primaryTextStyle()),
                            8.height,
                            AppTextField(
                              controller: addressController,
                              textFieldType: TextFieldType.ADDRESS,
                              focus: addressFocus,
                              decoration: commonInputDecoration(),
                            ),
                          ],
                        ).expand(),
                      ],
                    ),
                    16.height,
                    Text(language.contactNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: contactNumberController,
                      textFieldType: TextFieldType.PHONE,
                      focus: contactFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(
                        prefixIcon: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CountryCodePicker(
                                initialSelection: countryCode,
                                showCountryOnly: false,
                                dialogSize: Size(context.width() - 60,
                                    context.height() * 0.6),
                                showFlag: true,
                                showFlagDialog: true,
                                showOnlyCountryWhenClosed: false,
                                alignLeft: false,
                                textStyle: primaryTextStyle(),
                                dialogBackgroundColor:
                                    Theme.of(context).cardColor,
                                barrierColor: Colors.black12,
                                dialogTextStyle: primaryTextStyle(),
                                searchDecoration: InputDecoration(
                                  iconColor: Theme.of(context).dividerColor,
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).dividerColor)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: primaryColor)),
                                ),
                                searchStyle: primaryTextStyle(),
                                onInit: (c) {
                                  countryCode = c!.dialCode!;
                                },
                                onChanged: (c) {
                                  countryCode = c.dialCode!;
                                },
                              ),
                              VerticalDivider(
                                  color: Colors.grey.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.trim().isEmpty)
                          return language.field_required_msg;
                        if (value.trim().length < minContactLength ||
                            value.trim().length > maxContactLength)
                          return 'Contact number length must be of 10 to 14 digit.';
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    30.height,
                    appButton(context, title: language.saveChanges, onCall: () {
                      if (_formKey.currentState!.validate()) {
                        appStore.setLoading(true);
                        save();
                      }
                    }),
                    16.height,
                  ],
                ),
              ),
            ),
          ).paddingSymmetric(horizontal: 24, vertical: 16),
          appStore.isLoading ? loaderWidget() : SizedBox(),
        ],
      ),
    );
  }
}
