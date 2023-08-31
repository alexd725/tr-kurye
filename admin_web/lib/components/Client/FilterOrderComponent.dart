import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../../utils/Extensions/decorations.dart';
import '../../../../utils/Extensions/int_extensions.dart';
import '../../../../utils/Extensions/widget_extensions.dart';

import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/DataProvider.dart';
import '../../utils/Extensions/live_stream.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class FilterOrderComponent extends StatefulWidget {
  static String tag = '/FilterOrderComponent';

  @override
  FilterOrderComponentState createState() => FilterOrderComponentState();
}

class FilterOrderComponentState extends State<FilterOrderComponent> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  FilterAttributeModel? filterData;

  DateTime? fromDate, toDate;
  List<String> statusList = [
    ORDER_CREATED,
    ORDER_ACCEPTED,
    ORDER_CANCELLED,
    ORDER_ASSIGNED,
    ORDER_ARRIVED,
    ORDER_PICKED_UP,
    ORDER_DELIVERED,
    ORDER_DEPARTED,
  ];
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    filterData = FilterAttributeModel.fromJson(getJSONAsync(FILTER_DATA));
    if (filterData != null) {
      selectedStatus = filterData!.orderStatus;
      if (filterData!.fromDate != null) {
        fromDate = DateTime.tryParse(filterData!.fromDate!);
        if (fromDate != null) {
          fromDateController.text = fromDate.toString();
        }
      }
      if (filterData!.toDate != null) {
        toDate = DateTime.tryParse(filterData!.toDate!);
        if (toDate != null) {
          toDateController.text = toDate.toString();
        }
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.filter, style: boldTextStyle(size: 18)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: primaryColor, border: Border.all(color: primaryColor, width: 0.2)),
                    child: Text(language.reset, style: primaryTextStyle(color: Colors.white)).onTap(() {
                      selectedStatus = null;
                      fromDate = null;
                      toDate = null;
                      fromDateController.clear();
                      toDateController.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {});
                      finish(context);
                      setValue(FILTER_DATA, FilterAttributeModel(orderStatus: selectedStatus, fromDate: fromDate.toString(), toDate: toDate.toString()).toJson());
                      clientStore.setFiltering(selectedStatus != null || fromDate != null || toDate != null);
                      LiveStream().emit("UpdateOrderData");
                    }),
                  ),
                  16.width,
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: boxDecorationWithRoundedCorners(border: Border.all(color: primaryColor, width: 0.2)),
                    child: Text(language.close, style: primaryTextStyle(color: primaryColor)).onTap(() {
                      finish(context);
                    }),
                  )
                ],
              ),
            ],
          ),
          Divider(height: 30),
          Text(language.status, style: boldTextStyle(size: 14)),
          16.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusList.map((item) {
              return Chip(
                backgroundColor: selectedStatus == item ? primaryColor : Colors.transparent,
                label: Text(orderStatus(item)),
                elevation: 0,
                labelStyle: primaryTextStyle(color: selectedStatus == item ? Colors.white : Colors.grey),
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  side: BorderSide(color: selectedStatus == item ? primaryColor : borderColor, width: 1),
                ),
              ).onTap(() {
                selectedStatus = item;
                setState(() {});
              });
            }).toList(),
          ),
          16.height,
          Text(language.date, style: boldTextStyle()),
          16.height,
          Row(
            children: [
              Text(language.from, style: primaryTextStyle(size: 14)).withWidth(50),
              16.width,
              DateTimePicker(
                controller: fromDateController,
                type: DateTimePickerType.date,
                lastDate: DateTime.now(),
                firstDate: DateTime(2010),
                onChanged: (value) {
                  fromDate = DateTime.parse(value);
                  fromDateController.text = value;
                  setState(() {});
                },
                decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
              ).expand(),
            ],
          ),
          16.height,
          Row(
            children: [
              Text(language.to, style: primaryTextStyle(size: 14)).withWidth(50),
              16.width,
              DateTimePicker(
                controller: toDateController,
                type: DateTimePickerType.date,
                lastDate: DateTime.now(),
                firstDate: DateTime(2010),
                onChanged: (value) {
                  toDate = DateTime.parse(value);
                  toDateController.text = value;
                  setState(() {});
                },
                validator: (value) {
                  if (fromDate != null && toDate != null) {
                    Duration difference = fromDate!.difference(toDate!);
                    if (difference.inDays >= 0) {
                      return language.dateAfterDate;
                    }
                  }
                  return null;
                },
                decoration: commonInputDecoration(suffixIcon: Icons.calendar_today),
              ).expand(),
            ],
          ),
          16.height,
          appButton(context, title: language.applyFilter, onCall: () {
            if (_formKey.currentState!.validate()) {
              setValue(FILTER_DATA, FilterAttributeModel(orderStatus: selectedStatus, fromDate: fromDate.toString(), toDate: toDate.toString()).toJson());
              clientStore.setFiltering(selectedStatus != null || fromDate != null || toDate != null);
              LiveStream().emit("UpdateOrderData");
              finish(context);
            }
          }),
        ],
      ),
    );
  }
}
