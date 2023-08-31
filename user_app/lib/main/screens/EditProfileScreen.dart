import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../components/BodyCornerWidget.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Widgets.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String countryCode = defaultPhoneCode;
  //String countryCode = '+91';
  String carOrMotorEdit = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController idNoController = TextEditingController();
  TextEditingController taxOfficeController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();

  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController plateNumberController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode contactFocus = FocusNode();
  FocusNode addressFocus = FocusNode();

  XFile? imageProfile;

  @override
  void initState() {
    super.initState();
    setState(() {});
    getUser().then((value) {
      init();
    });
  }

  getInitialPage() {
    if (getStringAsync(USER_TYPE) == "delivery_man") {
      return Column(
        children: [
          16.height,
          Row(
            children: [
              Text("Id Number", style: primaryTextStyle()),
            ],
          ),
          8.height,
          AppTextField(
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[1-9]'))
            ],
            controller: idNoController,
            validator: (v) {
              if (v!.length > 11 || v!.length < 11) {
                return "Kimlik numarası 11 karakter olmalıdır!";
              } else {
                return null;
              }
            },
            textFieldType: TextFieldType.NUMBER,
            decoration: commonInputDecoration(),
          ),
          16.height,
          Row(
            children: [
              Text("Choose your truck", style: primaryTextStyle()),
            ],
          ),
          8.height,
          Container(
            height: 80,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: carOrMotorEdit.isEmpty ? "Car" : carOrMotorEdit,
                  items: <String>["Car", "Motor"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      carOrMotorEdit = v!;
                    });
                    print(carOrMotorEdit);
                  },
                ),
                Container(
                  height: 100,
                  width: 140,
                  child: Column(
                    children: [
                      Text("Plate Number", style: primaryTextStyle()),
                      AppTextField(
                        controller: plateNumberController,
                        textFieldType: TextFieldType.NAME,
                        decoration: commonInputDecoration(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      );
    } else if (getStringAsync(USER_TYPE) == "corporate") {
      return Column(
        children: [
          16.height,
          Row(
            children: [
              Text("Tax Office", style: primaryTextStyle()),
            ],
          ),
          8.height,
          AppTextField(
            controller: taxOfficeController,
            textFieldType: TextFieldType.NAME,
            decoration: commonInputDecoration(),
          ),
          16.height,
          Row(
            children: [
              Text("Tax Number", style: primaryTextStyle()),
            ],
          ),
          8.height,
          AppTextField(
            controller: taxNumberController,
            textFieldType: TextFieldType.NUMBER,
            decoration: commonInputDecoration(),
          ),
          16.height,
        ],
      );
    } else {
      return Container();
    }
  }

  Future<void> init() async {
    String phoneNum = getStringAsync(USER_CONTACT_NUMBER);
    emailController.text = getStringAsync(USER_EMAIL);
    usernameController.text = getStringAsync(USER_NAME);
    nameController.text = getStringAsync(NAME);
    taxNumberController.text = taxNumber;
    taxOfficeController.text = officeNumber;
    idNoController.text = id_no;
    setState(() {
      carOrMotorEdit = carOrMotorPage;
    });
    plateNumberController.text = plateNumber;
    if (phoneNum.split(" ").length == 1) {
      contactNumberController.text = phoneNum.split(" ").last;
    } else {
      countryCode = phoneNum.split(" ").first;
      contactNumberController.text = phoneNum.split(" ").last;
    }
    addressController.text = getStringAsync(USER_ADDRESS).validate();
  }

  Widget profileImage() {
    if (imageProfile != null) {
      return Image.file(File(imageProfile!.path),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              alignment: Alignment.center)
          .cornerRadiusWithClipRRect(100)
          .center();
    } else {
      if (getStringAsync(USER_PROFILE_PHOTO).isNotEmpty) {
        return commonCachedNetworkImage(
                getStringAsync(USER_PROFILE_PHOTO).validate(),
                fit: BoxFit.cover,
                height: 100,
                width: 100)
            .cornerRadiusWithClipRRect(100)
            .center();
      } else {
        return commonCachedNetworkImage('assets/profile.png',
                height: 90, width: 90)
            .cornerRadiusWithClipRRect(50)
            .paddingOnly(right: 4, bottom: 4)
            .center();
      }
    }
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
  }

  Future<void> save() async {
    appStore.setLoading(true);
    await updateProfile(
      file: imageProfile != null ? File(imageProfile!.path.validate()) : null,
      name: nameController.text.validate(),
      userName: usernameController.text.validate(),
      userEmail: emailController.text.validate(),
      address: addressController.text.validate(),
      contactNumber: '$countryCode ${contactNumberController.text.trim()}',
      idNo: getStringAsync(USER_TYPE) == "delivery_man"
          ? idNoController.text.validate()
          : "123456",
      carOrPlate: getStringAsync(USER_TYPE) == "delivery_man"
          ? carOrMotorEdit.validate()
          : "User Account",
      taxNumber: taxNumberController.text.validate(),
      officeNumber: taxOfficeController.text.validate(),
      plateNumber: plateNumberController.text.validate(),
    ).then((value) {
      finish(context);
      appStore.setLoading(false);
      toast(language.profileUpdateMsg);
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
    return Scaffold(
      appBar: AppBar(title: Text(language.editProfile)),
      body: BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding:
                  EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        profileImage(),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 60, left: 80),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: colorPrimary),
                            child: IconButton(
                              onPressed: () {
                                getImage();
                              },
                              icon: Icon(
                                Icons.edit,
                                color: white,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    16.height,
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
                        toast(language.notChangeEmail);
                      },
                    ),
                    16.height,
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
                        toast(language.notChangeUsername);
                      },
                    ),
                    getInitialPage(),
                    Text(language.name, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: nameController,
                      textFieldType: TextFieldType.NAME,
                      focus: nameFocus,
                      nextFocus: addressFocus,
                      decoration: commonInputDecoration(),
                      errorThisFieldRequired: language.fieldRequiredMsg,
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
                                          BorderSide(color: colorPrimary)),
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
                          return language.fieldRequiredMsg;
                        if (value.trim().length < minContactLength ||
                            value.trim().length > maxContactLength)
                          return language.contactLength;
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      /*validator: (s) {
                        if (s!.trim().isEmpty) return language.fieldRequiredMsg;
                        if (s.trim().length > 15)
                          return language.contactNumberValidation;
                        return null;
                      },*/
                    ),
                    16.height,
                    Text(language.address, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      controller: addressController,
                      textFieldType: TextFieldType.MULTILINE,
                      focus: addressFocus,
                      decoration: commonInputDecoration(),
                    ),
                    16.height,
                  ],
                ),
              ),
            ),
            Observer(
                builder: (_) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(language.saveChanges, () {
          if (_formKey.currentState!.validate()) {
            save();
          }
        }),
      ),
    );
  }
}
