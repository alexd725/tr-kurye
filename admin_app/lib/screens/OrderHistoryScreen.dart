import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/main.dart';
import 'package:mightydelivery_admin_app/models/OrderHistoryModel.dart';
import 'package:mightydelivery_admin_app/utils/Common.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class OrderHistoryScreen extends StatefulWidget {
  final int? orderId;
  final List<OrderHistoryModel>? orderHistoryData;

  OrderHistoryScreen({required this.orderId, this.orderHistoryData});

  @override
  OrderHistoryScreenState createState() => OrderHistoryScreenState();
}

class OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderHistoryModel> orderHistory = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if(widget.orderHistoryData != null && widget.orderHistoryData!.isNotEmpty){
      orderHistory = widget.orderHistoryData!;
      setState(() { });
    }else{
      await orderDetailApiCall();
    }
  }

  messageData(OrderHistoryModel orderModel) {
    if (orderModel.historyType == ORDER_ASSIGNED) {
      return 'Your Order#${orderModel.orderId} has been assigned to ${orderModel.historyData!.deliveryManName}.';
    } else if (orderModel.historyType == ORDER_TRANSFER) {
      return 'Your Order#${orderModel.orderId} has been transfered to ${orderModel.historyData!.deliveryManName}.';
    } else {
      return '${orderModel.historyMessage}';
    }
  }

  orderDetailApiCall() async {
    appStore.setLoading(true);
    await orderDetail(orderId: widget.orderId!).then((value) async {
      appStore.setLoading(false);
      orderHistory = value.orderHistory!;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.orderHistory)),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orderHistory.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              OrderHistoryModel mData = orderHistory[index];
              return TimelineTile(
                alignment: TimelineAlign.start,
                isFirst: index == 0 ? true : false,
                isLast: index == (orderHistory.length - 1) ? true : false,
                indicatorStyle: IndicatorStyle(width: 15, color: primaryColor),
                afterLineStyle: LineStyle(color: primaryColor, thickness: 3),
                beforeLineStyle: LineStyle(color: primaryColor, thickness: 3),
                endChild: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ImageIcon(AssetImage(statusTypeIcon(type: mData.historyType)), color: primaryColor, size: 30),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${mData.historyType!.replaceAll("_", " ")}', style: boldTextStyle()),
                            SizedBox(height: 8),
                            Text(messageData(mData), style: primaryTextStyle()),
                            SizedBox(height: 8),
                            Text('${printDate('${mData.createdAt}')}', style: secondaryTextStyle()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Observer(builder: (context) => Visibility(visible:appStore.isLoading,child: loaderWidget())),
        ],
      ),
    );
  }
}
