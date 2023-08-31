import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/Colors.dart';
import '../../main.dart';
import '../models/PlaceAddressModel.dart';
import '../screens/GoogleMapScreen.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class PickAddressBottomSheet extends StatefulWidget {
  final Function(PlaceAddressModel) onPick;
  final bool isPickup;

  PickAddressBottomSheet({required this.onPick, this.isPickup = true});

  @override
  PickAddressBottomSheetState createState() => PickAddressBottomSheetState();
}

class PickAddressBottomSheetState extends State<PickAddressBottomSheet> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.isPickup ? language.choosePickupAddress : language.chooseDeliveryAddress, style: boldTextStyle()),
                SizedBox(height: 8),
                Text(language.showingAllAddress, style: secondaryTextStyle()),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () async {
                PlaceAddressModel? res = await launchScreen(context, GoogleMapScreen(isPick: widget.isPickup));
                if (res != null) {
                  widget.onPick.call(res);
                  Navigator.pop(context);
                }
              },
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: primaryColor),
                  SizedBox(width: 10),
                  Text(language.addNewAddress, style: boldTextStyle(color: primaryColor)),
                ],
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: (sharedPref.getStringList(RECENT_ADDRESS_LIST) ?? []).length,
              itemBuilder: (context, index) {
                int len = (sharedPref.getStringList(RECENT_ADDRESS_LIST) ?? []).length;
                PlaceAddressModel mData = PlaceAddressModel.fromJson(jsonDecode(sharedPref.getStringList(RECENT_ADDRESS_LIST)![len - index - 1]));
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      widget.onPick.call(mData);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 10),
                        Expanded(child: Text('${mData.placeAddress}', style: primaryTextStyle(), maxLines: 2)),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            List<String> list = sharedPref.getStringList(RECENT_ADDRESS_LIST) ?? [];
                            list.removeWhere((element) => PlaceAddressModel.fromJson(jsonDecode(element)).placeId == mData.placeId);
                            sharedPref.setStringList(RECENT_ADDRESS_LIST, list);
                            setState(() {});
                          },
                          child: Icon(Icons.highlight_remove_outlined, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            ),
          ),
        ],
      ),
    );
  }
}
