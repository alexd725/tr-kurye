import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/models/ParcelTypeListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Common.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_textfield.dart';

import '../main.dart';
import '../utils/Constants.dart';

class AddParcelTypeDialog extends StatefulWidget {
  static String tag = '/AppAddParcelTypeDialog';
  final ParcelTypeData? parcelTypeData;
  final Function()? onUpdate;

  AddParcelTypeDialog({this.parcelTypeData, this.onUpdate});

  @override
  AddParcelTypeDialogState createState() => AddParcelTypeDialogState();
}

class AddParcelTypeDialogState extends State<AddParcelTypeDialog> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController labelController = TextEditingController();
  //TextEditingController valueController = TextEditingController();

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
      //valueController.text = widget.parcelTypeData!.value!;
    }
  }

  addParcelTypeApiCall() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      Map req = {
        "id": isUpdate ? widget.parcelTypeData!.id : "",
        "type": "parcel_type",
        "label": labelController.text,
        //"value": valueController.text,
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
      contentPadding: EdgeInsets.all(16),
      titlePadding: EdgeInsets.only(left: 16, right: 8, top: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isUpdate ? language.updateParcelType : language.addParcelType,
              style: boldTextStyle(color: primaryColor, size: 20)),
          IconButton(
            icon: Icon(Icons.close),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
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
                  if (s!.trim().isEmpty) return language.fieldRequiredMsg;
                  return null;
                },
              ),
              /*SizedBox(height: 16),
              Text(language.value, style: primaryTextStyle()),
              SizedBox(height: 8),
              AppTextField(
                controller: valueController,
                textFieldType: TextFieldType.NAME,
                decoration: commonInputDecoration(),
                textInputAction: TextInputAction.next,
                validator: (s) {
                  if (s!.trim().isEmpty) return language.fieldRequiredMsg;
                  return null;
                },
              ),*/
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: dialogSecondaryButton(language.cancel, () {
                      Navigator.pop(context);
                    }),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: dialogPrimaryButton(
                        isUpdate ? language.update : language.add, () {
                      if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                        toast(language.demoAdminMsg);
                      } else {
                        addParcelTypeApiCall();
                      }
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
