import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/CityListModel.dart';
import 'package:mightydelivery_admin_app/models/ExtraChragesListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_textfield.dart';

import '../utils/Common.dart';
import '../utils/CommonApiCall.dart';

class AddExtraChargeDialog extends StatefulWidget {
  static String tag = '/AppAddExtraChargeDialog';
  final ExtraChargesData? extraChargesData;
  final Function()? onUpdate;

  AddExtraChargeDialog({this.extraChargesData, this.onUpdate});

  @override
  AddExtraChargeDialogState createState() => AddExtraChargeDialogState();
}

class AddExtraChargeDialogState extends State<AddExtraChargeDialog> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController chargeController = TextEditingController();

  List<CityData> cityList = [];

  int? selectedCountryId;
  int? selectedCityId;
  String? chargeTypeValue;

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
    });
    await getAllCountryApiCall();
    await getCityListApiCall();
    isUpdate = widget.extraChargesData != null;
    if (isUpdate) {
      titleController.text = widget.extraChargesData!.title!;
      chargeController.text = widget.extraChargesData!.charges!.toString();
      appStore.countryList.forEach((element) {
        if (element.id == widget.extraChargesData!.countryId!) {
          selectedCountryId = widget.extraChargesData!.countryId!;
        }
      });
      cityList.forEach((element) {
        if (element.id == widget.extraChargesData!.cityId!) {
          selectedCityId = widget.extraChargesData!.cityId!;
        }
      });
      chargeTypeValue = widget.extraChargesData!.chargesType!;
    }
    appStore.setLoading(false);
    //setState(() { });
  }

  getCityListApiCall() async {
    appStore.setLoading(true);
    await getCityList(countryId: selectedCountryId).then((value) {
      appStore.setLoading(false);
      cityList.clear();
      cityList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  addExtraChargeApiCall() async {
    if (_formKey.currentState!.validate()) {
      if (chargeTypeValue == null) return toast(language.pleaseSelectChargeType);
      Navigator.pop(context);
      Map req = {
        "id": isUpdate ? widget.extraChargesData!.id : "",
        "title": titleController.text,
        "charges_type": chargeTypeValue,
        "charges": chargeController.text,
        "country_id": selectedCountryId,
        "city_id": selectedCityId,
      };
      appStore.setLoading(true);
      await addExtraCharge(req).then((value) {
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
          Text(isUpdate ? language.updateExtraCharge : language.addExtraCharge, style: boldTextStyle(color: primaryColor, size: 20)),
          IconButton(
            icon: Icon(Icons.close),
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: Observer(builder: (context) {
        return SingleChildScrollView(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.country, style: primaryTextStyle()),
                              SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                value: selectedCountryId,
                                dropdownColor: Theme.of(context).cardColor,
                                decoration: commonInputDecoration(),
                                items: appStore.countryList.map<DropdownMenuItem<int>>((item) {
                                  return DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.name!, style: primaryTextStyle()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedCountryId = value;
                                  getCityListApiCall();
                                  selectedCityId = null;
                                },
                                validator: (s) {
                                  if (selectedCountryId == null) return language.fieldRequiredMsg;
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.city, style: primaryTextStyle()),
                              SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                value: selectedCityId,
                                dropdownColor: Theme.of(context).cardColor,
                                decoration: commonInputDecoration(),
                                items: cityList.map<DropdownMenuItem<int>>((item) {
                                  return DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.name!, style: primaryTextStyle()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedCityId = value;
                                  setState(() {});
                                },
                                validator: (s) {
                                  if (selectedCityId == null) return language.fieldRequiredMsg;
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.title, style: primaryTextStyle()),
                              SizedBox(height: 8),
                              AppTextField(
                                controller: titleController,
                                textFieldType: TextFieldType.OTHER,
                                decoration: commonInputDecoration(),
                                textInputAction: TextInputAction.next,
                                validator: (s) {
                                  if (s!.trim().isEmpty) return language.fieldRequiredMsg;
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.charge, style: primaryTextStyle()),
                              SizedBox(height: 8),
                              AppTextField(
                                controller: chargeController,
                                textFieldType: TextFieldType.OTHER,
                                decoration: commonInputDecoration(),
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp('[0-9 .]')),
                                ],
                                validator: (s) {
                                  if (s!.trim().isEmpty) return language.fieldRequiredMsg;
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(language.chargeType, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: CHARGE_TYPE_FIXED,
                            title: Text(CHARGE_TYPE_FIXED, style: primaryTextStyle()),
                            groupValue: chargeTypeValue,
                            onChanged: (value) {
                              chargeTypeValue = value;
                              setState(() {});
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: CHARGE_TYPE_PERCENTAGE,
                            title: Text(CHARGE_TYPE_PERCENTAGE, style: primaryTextStyle()),
                            groupValue: chargeTypeValue,
                            onChanged: (value) {
                              chargeTypeValue = value;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
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
                          child: dialogPrimaryButton(isUpdate ? language.update : language.add, () {
                            if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                              toast(language.demoAdminMsg);
                            } else {
                              addExtraChargeApiCall();
                            }
                          }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget())),
            ],
          ),
        );
      }),
    );
  }
}
