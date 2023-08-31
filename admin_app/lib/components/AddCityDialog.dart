import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../utils/Extensions/StringExtensions.dart';
import 'package:mightydelivery_admin_app/models/CityListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_textfield.dart';

import '../main.dart';
import '../utils/CommonApiCall.dart';
import '../utils/Constants.dart';
import '../utils/Common.dart';

class AddCityDialog extends StatefulWidget {
  static String tag = '/AppAddCityDialog';
  final CityData? cityData;
  final Function()? onUpdate;

  AddCityDialog({this.cityData, this.onUpdate});

  @override
  AddCityDialogState createState() => AddCityDialogState();
}

class AddCityDialogState extends State<AddCityDialog> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isBike = true;
  String vehicle = 'Bike';
  String delivery = 'In-Day Delivery';
  String delivery1 = 'Express Delivery';
  TextEditingController cityNameController = TextEditingController();
  TextEditingController fixedChargeController = TextEditingController();
  TextEditingController cancelChargeController = TextEditingController();
  TextEditingController minDistanceController = TextEditingController();
  TextEditingController minWeightController = TextEditingController();
  TextEditingController perDistanceChargeController = TextEditingController();
  TextEditingController perWeightChargeChargeController =
      TextEditingController();
  TextEditingController commissionController = TextEditingController();
  TextEditingController chargePerAddressController = TextEditingController();
  TextEditingController maxDistanceController = TextEditingController();
  TextEditingController maxWeightController = TextEditingController();
  int? selectedCountryId;
  String distanceType = '';
  String weightType = '';

  String commissionType = 'fixed';

  List<String> commissionTypeList = ['fixed', 'percentage'];

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
    isUpdate = widget.cityData != null;
    if (isUpdate) {
      cityNameController.text = widget.cityData!.name!;
      fixedChargeController.text = widget.cityData!.fixedCharges.toString();
      cancelChargeController.text = widget.cityData!.cancelCharges.toString();
      minDistanceController.text = widget.cityData!.minDistance.toString();
      minWeightController.text = widget.cityData!.minWeight.toString();
      perDistanceChargeController.text =
          widget.cityData!.perDistanceCharges.toString();
      perWeightChargeChargeController.text =
          widget.cityData!.perWeightCharges.toString();
      maxWeightController.text = widget.cityData!.maxWeight.toString();
      maxDistanceController.text = widget.cityData!.maxDistance.toString();
      if (widget.cityData!.chargePerAddress != null) {
        chargePerAddressController.text =
            widget.cityData!.maxDistance.toString();
      }
      if (widget.cityData!.vehicle_type.toString() != null) {
        vehicle = widget.cityData!.vehicle_type.toString();
        delivery = widget.cityData!.order_type.toString();
        delivery1 = widget.cityData!.order_type.toString();
      }
      appStore.countryList.forEach((element) {
        if (element.id == widget.cityData!.countryId) {
          selectedCountryId = widget.cityData!.countryId;
        }
      });
      commissionType = widget.cityData!.commissionType.isEmptyOrNull
          ? 'fixed'
          : widget.cityData!.commissionType.toString();
      commissionController.text = widget.cityData!.adminCommission.toString();
      getDistanceAndWeightType();
      setState(() {});
    }
    appStore.setLoading(false);
  }

  getDistanceAndWeightType() {
    appStore.countryList.forEach((e) {
      if (e.id == selectedCountryId) {
        distanceType = e.distanceType!;
        weightType = e.weightType!;
      }
    });
  }

  addCityApiCall() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      Map req = {
        "id": isUpdate ? widget.cityData!.id : "",
        "country_id": selectedCountryId,
        "name": cityNameController.text,
        "fixed_charges": fixedChargeController.text,
        "cancel_charges": cancelChargeController.text,
        "min_distance": minDistanceController.text,
        "min_weight": minWeightController.text,
        "per_distance_charges": perDistanceChargeController.text,
        "per_weight_charges": perWeightChargeChargeController.text,
        "vehicle_type": vehicle,
        "order_type": isBike ? delivery : delivery1,
        "max_distance": maxDistanceController.text,
        "max_weight": maxWeightController.text,
        "charge_per_address": chargePerAddressController.text,
        "commission_type": commissionType,
        "admin_commission": commissionController.text.trim()
      };
      appStore.setLoading(true);
      await addCity(req).then((value) {
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
          Text(isUpdate ? language.updateCity : language.addCity,
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
      content: Observer(
        builder: (_) {
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
                                Text(language.cityName,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: cityNameController,
                                  textFieldType: TextFieldType.NAME,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.selectCountry,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  dropdownColor: Theme.of(context).cardColor,
                                  value: selectedCountryId,
                                  decoration: commonInputDecoration(),
                                  items: appStore.countryList
                                      .map<DropdownMenuItem<int>>((item) {
                                    return DropdownMenuItem(
                                      value: item.id,
                                      child: Text(item.name!,
                                          style: primaryTextStyle()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    selectedCountryId = value;
                                    getDistanceAndWeightType();
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (selectedCountryId == null)
                                      return language.fieldRequiredMsg;
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ////////////// SHEIKH ////////////////
                      ///////////////SHEIKH////////////////
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(height: 4),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.33,
                            height: 55,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: vehicle,
                              dropdownColor: Theme.of(context).cardColor,
                              style: primaryTextStyle(),
                              decoration: commonInputDecoration(),
                              items: [
                                DropdownMenuItem(
                                    value: "Bike",
                                    child: Text("Bike",
                                        style: primaryTextStyle(),
                                        maxLines: 1)),
                                DropdownMenuItem(
                                    value: "Car",
                                    child: Text("Car",
                                        style: primaryTextStyle(),
                                        maxLines: 1)),
                              ],
                              onChanged: (value) {
                                vehicle = value!;
                                print(vehicle);
                                setState(() {
                                  if (vehicle == "Bike") {
                                    isBike = true;
                                  } else {
                                    isBike = false;
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          isBike
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                  height: 55,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: delivery,
                                    dropdownColor: Theme.of(context).cardColor,
                                    style: primaryTextStyle(),
                                    decoration: commonInputDecoration(),
                                    items: [
                                      DropdownMenuItem(
                                          value: "In-Day Delivery",
                                          child: Text("In-Day Delivery",
                                              style: primaryTextStyle(),
                                              maxLines: 1)),
                                      DropdownMenuItem(
                                          value: "Express Delivery",
                                          child: Text("Express Delivery",
                                              style: primaryTextStyle(),
                                              maxLines: 1)),
                                      DropdownMenuItem(
                                          value: "Vip Delivery",
                                          child: Text("Vip Delivery",
                                              style: primaryTextStyle(),
                                              maxLines: 1)),
                                    ],
                                    onChanged: (value) {
                                      delivery = value!;
                                      setState(() {});
                                    },
                                  ),
                                )
                              : SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.33,
                                  height: 55,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: delivery1,
                                    dropdownColor: Theme.of(context).cardColor,
                                    style: primaryTextStyle(),
                                    decoration: commonInputDecoration(),
                                    items: [
                                      DropdownMenuItem(
                                          value: "Express Delivery",
                                          child: Text("Express Delivery",
                                              style: primaryTextStyle(),
                                              maxLines: 1)),
                                      DropdownMenuItem(
                                          value: "Vip Delivery",
                                          child: Text("Vip Delivery",
                                              style: primaryTextStyle(),
                                              maxLines: 1)),
                                    ],
                                    onChanged: (value) {
                                      delivery1 = value!;
                                      setState(() {});
                                    },
                                  ),
                                ),
                        ],
                      ),
                      ////////////SHEIKH////////////////
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.fixedCharge,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: fixedChargeController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(),
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  textInputAction: TextInputAction.next,
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
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
                                Text(language.cancelCharge,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: cancelChargeController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${language.minimumDistance} ${distanceType.isNotEmpty ? '($distanceType)' : ''}',
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: minDistanceController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
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
                                Text('Maximum Distance',
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: maxDistanceController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${language.minimumWeight} ${weightType.isNotEmpty ? '($weightType)' : ''}',
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: minWeightController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
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
                                Text('Maximum Weight',
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: maxWeightController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.perDistanceCharge,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: perDistanceChargeController,
                                  textFieldType: TextFieldType.OTHER,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
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
                                Text(language.perWeightCharge,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: perWeightChargeChargeController,
                                  textFieldType: TextFieldType.PHONE,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
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
                                Text(language.commissionType,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Theme.of(context).cardColor,
                                  value: commissionType,
                                  decoration: commonInputDecoration(),
                                  items: commissionTypeList
                                      .map<DropdownMenuItem<String>>((item) {
                                    return DropdownMenuItem(
                                        value: item,
                                        child: Text(item,
                                            style: primaryTextStyle()));
                                  }).toList(),
                                  onChanged: (value) {
                                    commissionType = value.validate();
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (commissionType.isEmptyOrNull)
                                      return language.fieldRequiredMsg;
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
                                Text(language.adminCommission,
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: commissionController,
                                  textFieldType: TextFieldType.NAME,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Charge per Address",
                                    style: primaryTextStyle()),
                                SizedBox(height: 8),
                                AppTextField(
                                  controller: chargePerAddressController,
                                  textFieldType: TextFieldType.PHONE,
                                  decoration: commonInputDecoration(),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  errorThisFieldRequired:
                                      language.fieldRequiredMsg,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9 .]')),
                                  ],
                                  validator: (s) {
                                    if (s!.trim().isEmpty)
                                      return language.fieldRequiredMsg;
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
                            child: dialogPrimaryButton(
                                isUpdate ? language.update : language.add, () {
                              if (sharedPref.getString(USER_TYPE) ==
                                  DEMO_ADMIN) {
                                toast(language.demoAdminMsg);
                              } else {
                                addCityApiCall();
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: appStore.isLoading,
                    child: Positioned.fill(child: loaderWidget())),
              ],
            ),
          );
        },
      ),
    );
  }
}
