import 'package:flutter/material.dart';
import '/../models/ParcelTypeListModel.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Extensions/app_textfield.dart';
import '/../main.dart';
import '/../utils/Constants.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/text_styles.dart';

class AddParcelTypeDialog extends StatefulWidget {
  static String tag = '/AddParcelTypeDialog';
  final ParcelTypeData? parcelTypeData;
  final Function()? onUpdate;

  AddParcelTypeDialog({this.parcelTypeData, this.onUpdate});

  @override
  AddParcelTypeDialogState createState() => AddParcelTypeDialogState();
}

class AddParcelTypeDialogState extends State<AddParcelTypeDialog> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController labelController = TextEditingController();

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.parcelTypeData != null;
    if (isUpdate) {
      labelController.text = widget.parcelTypeData!.label!;
    }
  }

  AddParcelTypeApiCall() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      Map req = {
        "id": isUpdate ? widget.parcelTypeData!.id : "",
        "type": "parcel_type",
        "label": labelController.text,
      };
      appStore.setLoading(true);
      await addParcelType(req).then((value) {
        appStore.setLoading(false);
        toast(value.message.toString());
        widget.onUpdate!.call();
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
    return AlertDialog(
      actionsPadding: EdgeInsets.only(right: 16, bottom: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isUpdate ? language.update_parcel_type : language.add_parcel_type, style: boldTextStyle(color: primaryColor, size: 20)),
          IconButton(
            icon: Icon(Icons.close),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.label, style: primaryTextStyle()),
                SizedBox(height: 8),
                AppTextField(
                  controller: labelController,
                  textFieldType: TextFieldType.NAME,
                  decoration: commonInputDecoration(),
                  textInputAction: TextInputAction.next,
                  validator: (s) {
                    if (s!.trim().isEmpty) return language.field_required_msg;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        dialogSecondaryButton(language.cancel, () {
          Navigator.pop(context);
        }),
        SizedBox(width: 4),
        dialogPrimaryButton(isUpdate ? language.update : language.add, () {
          if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
            toast(language.demo_admin_msg);
          } else {
            AddParcelTypeApiCall();
          }
        }),
      ],
    );
  }
}
