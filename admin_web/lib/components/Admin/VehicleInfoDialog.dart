import 'package:flutter/material.dart';
import 'package:local_delivery_admin/models/VehicleListModel.dart';

import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';

class VehicleInfoDialog extends StatefulWidget {
  static String tag = '/CityInfoDialog';

  final VehicleData? vehicleData;

  VehicleInfoDialog({this.vehicleData});

  @override
  State<VehicleInfoDialog> createState() => _VehicleInfoDialogState();
}

class _VehicleInfoDialogState extends State<VehicleInfoDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.vehicleData!.title}', style: boldTextStyle(size: 20)),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            informationWidget(language.vehicle, '${widget.vehicleData!.id}'),
            informationWidget(language.vehicle_name, '${widget.vehicleData!.title}'),
            Divider(height: 20),
            informationWidget(language.city, widget.vehicleData!.cityText != null ? widget.vehicleData!.cityText!.values.map((e) => e).toList().toString() : language.allCity),
            informationWidget(language.vehicle_size, '${widget.vehicleData!.size}'),
            informationWidget(language.vehicle_capacity, '${widget.vehicleData!.capacity}'),
            informationWidget(language.description, '${widget.vehicleData!.description}'),
            Divider(height: 20),
            informationWidget(language.created_date, printDate(widget.vehicleData!.createdAt!)),
            informationWidget(language.updated_date, printDate(widget.vehicleData!.updatedAt!)),
          ],
        ),
      ),
    );
  }
}
