import 'package:flutter/material.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/ResponsiveWidget.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../models/OrderModel.dart';
import '../screens/OrderDetailScreen.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Common.dart';

Widget orderWidget(BuildContext context, OrderModel data,
    {Widget? assign,
    Widget? restore,
    Widget? delete,
    bool? isFragment = false}) {
  return GestureDetector(
    onTap: () {
      launchScreen(
          context, OrderDetailScreen(orderId: data.id!, orderModel: data));
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 16),
      width: MediaQuery.of(context).size.width,
      decoration: containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#' + data.id.toString(),
                    style: boldTextStyle(color: primaryColor)),
                isFragment!
                    ? Expanded(
                        child: Row(
                          children: [
                            Spacer(),
                            assign.validate(),
                            SizedBox(width: 8),
                            if (data.deletedAt != null &&
                                data.clientName != null)
                              Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: restore.validate()),
                            delete.validate(),
                          ],
                        ),
                      )
                    : Text(data.readableDate.validate(),
                        style: secondaryTextStyle(size: 14)),
              ],
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.customerName,
                        style: primaryTextStyle(size: 14)),
                    Text(data.clientName.validate(),
                        style: boldTextStyle(size: 15)),
                  ],
                ),
                Divider(thickness: 0.9, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.deliveryPerson,
                        style: primaryTextStyle(size: 14)),
                    data.deliveryManName != null
                        ? Text(data.deliveryManName.toString(),
                            style: boldTextStyle(size: 15))
                        : (data.status != ORDER_CREATED &&
                                data.status != ORDER_CANCELLED &&
                                data.status != ORDER_DRAFT)
                            ? Text(language.deliveryPersonDeleted,
                                style: secondaryTextStyle(color: Colors.red))
                            : Text('-', style: primaryTextStyle()),
                  ],
                ),
                Divider(thickness: 0.9, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.city, style: primaryTextStyle(size: 14)),
                    Text(data.cityName.validate(),
                        style: primaryTextStyle(size: 15)),
                  ],
                ),
                Divider(thickness: 0.9, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Vehicle Type", style: primaryTextStyle(size: 14)),
                    Text(data.vehicle_type.validate(),
                        style: primaryTextStyle(size: 15)),
                  ],
                ),
                Divider(thickness: 0.9, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery Type", style: primaryTextStyle(size: 14)),
                    Text(data.order_type.validate(),
                        style: primaryTextStyle(size: 15)),
                  ],
                ),
                Divider(thickness: 0.9, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.pickupDate,
                        style: primaryTextStyle(size: 14)),
                    Text(
                        data.pickupPoint!.startTime != null
                            ? printDate(data.pickupPoint!.startTime ?? '')
                            : '-',
                        style: secondaryTextStyle()),
                  ],
                ),
                Divider(thickness: 0.9, height: 20),
                Row(
                  children: [
                    Text(language.status, style: primaryTextStyle(size: 14)),
                    Spacer(),
                    Text('${orderStatus(data.status.validate())}',
                        style: boldTextStyle(
                            color: statusColor(data.status ?? ""), size: 15)),
                    Text('${data.autoAssign == 1 ? '*' : ''}',
                        style: primaryTextStyle(color: Colors.red)),
                  ],
                ),
                Visibility(
                    visible: isFragment,
                    child: Divider(thickness: 0.9, height: 20)),
                Visibility(
                  visible: isFragment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(language.pickupAddress,
                              style: primaryTextStyle(size: 14))),
                      Expanded(
                          child: Text(data.pickupPoint!.address ?? '-',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: primaryTextStyle(size: 15))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
