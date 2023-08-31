 import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import '../../models/UserModel.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../network/NetworkUtils.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class BankDetailScreen extends StatefulWidget {
  static const String route = '/bankdetails';

  final bool? isWallet;

  BankDetailScreen({this.isWallet = false});

  @override
  _BankDetailScreenState createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameCon = TextEditingController();
  TextEditingController accNumberCon = TextEditingController();
  TextEditingController nameCon = TextEditingController();
  TextEditingController ifscCCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getBankDetail();
  }

  getBankDetail() async {
    appStore.setLoading(true);
    await getUserDetail(getIntAsync(USER_ID)).then((value) {
      appStore.setLoading(false);
      if (value.userBankAccount != null) {
        bankNameCon.text = value.userBankAccount!.bankName.validate();
        accNumberCon.text = value.userBankAccount!.accountNumber.validate();
        nameCon.text = value.userBankAccount!.accountHolderName.validate();
        ifscCCon.text = value.userBankAccount!.bankCode.validate();
        setState(() { });
      }
    }).then((value) {
      appStore.setLoading(false);
    });
  }

  saveBankDetail() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
      multiPartRequest.fields['username'] = getStringAsync(USER_NAME);
      multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();

      multiPartRequest.fields['email'] = getStringAsync(USER_EMAIL);
      multiPartRequest.fields['user_bank_account[bank_name]'] = bankNameCon.text.trim();
      multiPartRequest.fields['user_bank_account[account_number]'] = accNumberCon.text.trim();
      multiPartRequest.fields['user_bank_account[account_holder_name]'] = nameCon.text.trim();
      multiPartRequest.fields['user_bank_account[bank_code]'] = ifscCCon.text.trim();
      multiPartRequest.headers.addAll(buildHeaderTokens());
      sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          toast(data['message']);
          appStore.setLoading(false);
          setState(() {});
        },
        onError: (error) {
          log(multiPartRequest.toString());
          toast(error.toString());
          appStore.setLoading(false);
        },
      ).catchError((e) {
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
    return Stack(
      children: [
        SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.bankDetails, style: boldTextStyle(color: primaryColor)),
                8.height,
                Divider(color: borderColor, height: 1, thickness: 1),
                20.height,
                AppTextField(
                  isValidationRequired: true,
                  controller: bankNameCon,
                  textFieldType: TextFieldType.NAME,
                  decoration: commonInputDecoration(hintText: language.bankName),
                ),
                16.height,
                AppTextField(
                  isValidationRequired: true,
                  controller: accNumberCon,
                  textFieldType: TextFieldType.PHONE,
                  decoration: commonInputDecoration(hintText: language.accountNumber),
                ),
                16.height,
                AppTextField(
                  isValidationRequired: true,
                  controller: nameCon,
                  textFieldType: TextFieldType.NAME,
                  decoration: commonInputDecoration(hintText: language.accountHolderName),
                ),
                16.height,
                AppTextField(
                  isValidationRequired: true,
                  controller: ifscCCon,
                  textFieldType: TextFieldType.NAME,
                  decoration: commonInputDecoration(hintText: language.ifscCode),
                ),
                22.height,
                appButton(context, title: language.saveChanges, onCall: () {
                  saveBankDetail();
                })
              ],
            ),
          ),
        ),
        Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
      ],
    );
  }
}
