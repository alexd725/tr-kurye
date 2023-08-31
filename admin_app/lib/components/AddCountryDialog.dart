import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/models/CountryListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:mightydelivery_admin_app/utils/country_list.dart';

import '../main.dart';
import '../utils/Common.dart';

class AddCountryDialog extends StatefulWidget {
  static String tag = '/AppAddCountryDialog';
  final CountryData? countryData;
  final Function()? onUpdate;

  AddCountryDialog({this.countryData, this.onUpdate});

  @override
  AddCountryDialogState createState() => AddCountryDialogState();
}

class AddCountryDialogState extends State<AddCountryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> distanceTypeList = ['km', 'miles'];
  List<String> weightTypeList = ['kg', 'pound'];
  String? selectedDistanceType;
  String? selectedWeightType;
  bool isUpdate = false;

  CountryCode? countryCode = CountryCode.fromJson(country_list.first);

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.countryData != null;
    if (isUpdate) {
      country_list.forEach((element) {
        if (CountryCode.fromJson(element).code == widget.countryData!.code) {
          countryCode = CountryCode.fromJson(element);
        }
      });
      if (distanceTypeList.contains(widget.countryData!.distanceType)) {
        selectedDistanceType = widget.countryData!.distanceType;
      }
      if (weightTypeList.contains(widget.countryData!.weightType)) {
        selectedWeightType = widget.countryData!.weightType;
      }
    }
  }

  addCountryApiCall() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      Map req = {
        "id": isUpdate ? widget.countryData!.id : "",
        "name": countryCode!.name,
        "distance_type": selectedDistanceType ?? "",
        "weight_type": selectedWeightType ?? "",
        "code": countryCode!.code,
      };
      appStore.setLoading(true);
      await addCountry(req).then((value) {
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
          Text(isUpdate ? language.updateCountry : language.addCountry, style: boldTextStyle(color: primaryColor, size: 20)),
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
        return Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(language.countryName, style: primaryTextStyle()),
                    SizedBox(height: 8),
                    Container(
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      child: CountryCodePicker(
                        padding: EdgeInsets.only(left: 12,right: 12),
                        initialSelection: countryCode!.code,
                        showCountryOnly: true,
                        showFlag: true,
                        showFlagDialog: true,
                        showOnlyCountryWhenClosed: true,
                        countryList: country_list,
                        showDropDownButton: true,
                        alignLeft: false,
                        dialogSize: Size(MediaQuery.of(context).size.width - 60, MediaQuery.of(context).size.height * 0.6),
                        backgroundColor: Colors.grey.withOpacity(0.15),
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
                        onChanged: (c) {
                          countryCode = c;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.distanceType, style: primaryTextStyle()),
                              SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Theme.of(context).cardColor,
                                value: selectedDistanceType,
                                decoration: commonInputDecoration(),
                                items: distanceTypeList.map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item, style: primaryTextStyle()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedDistanceType = value;
                                  setState(() {});
                                },
                                validator: (s) {
                                  if (selectedDistanceType == null) return language.fieldRequiredMsg;
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
                              Text(language.weightType, style: primaryTextStyle()),
                              SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                dropdownColor: Theme.of(context).cardColor,
                                value: selectedWeightType,
                                decoration: commonInputDecoration(),
                                items: weightTypeList.map<DropdownMenuItem<String>>((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item, style: primaryTextStyle()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  selectedWeightType = value;
                                  setState(() {});
                                },
                                validator: (s) {
                                  if (selectedWeightType == null) return language.fieldRequiredMsg;
                                  return null;
                                },
                              ),
                            ],
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
                              addCountryApiCall();
                            }
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(visible: appStore.isLoading, child: Positioned.fill(child: loaderWidget())),
          ],
        );
      }),
    );
  }
}
