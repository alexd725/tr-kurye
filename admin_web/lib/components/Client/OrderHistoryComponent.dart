import 'package:flutter/material.dart';
import '../../models/OrderHistoryModel.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../main.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/text_styles.dart';

class OrderHistoryComponent extends StatefulWidget {
  static String tag = '/OrderHistoryComponent';

  final List<OrderHistoryModel> orderHistory;

  OrderHistoryComponent({required this.orderHistory});

  @override
  OrderHistoryComponentState createState() => OrderHistoryComponentState();
}

class OrderHistoryComponentState extends State<OrderHistoryComponent> {
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
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: widget.orderHistory.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        OrderHistoryModel mData = widget.orderHistory[index];
        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0 ? true : false,
          isLast: index == (widget.orderHistory.length - 1) ? true : false,
          indicatorStyle: IndicatorStyle(
            color: primaryColor,
            indicatorXY: 0.1,
            width: 50,
            height: 50,
            indicator: Container(
              padding: EdgeInsets.all(10),
              child: ImageIcon(AssetImage(statusTypeIcon(type: mData.history_type)), color: Colors.white),
              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            ),
          ),
          afterLineStyle: LineStyle(color: primaryColor, thickness: 3),
          beforeLineStyle: LineStyle(color: primaryColor, thickness: 3),
          endChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${mData.history_type!.replaceAll("_", " ").capitalizeFirstLetter()}', style: boldTextStyle()),
              SizedBox(height: 8),
              Text(messageData(mData)),
              SizedBox(height: 8),
              Text('${printDate('${mData.created_at}')}', style: secondaryTextStyle()),
            ],
          ).paddingSymmetric(vertical: 8, horizontal: 16),
        );
      },
    );
  }
}

messageData(OrderHistoryModel orderData) {
    if (orderData.history_type == ORDER_ASSIGNED) {
      return '${language.yourOrder}#${orderData.order_id} ${language.assignTo} ${orderData.history_data!.deliveryManName}.';
    }else if (orderData.history_type == ORDER_TRANSFER) {
      return '${language.yourOrder} #${orderData.order_id} ${language.transferTo} ${orderData.history_data!.deliveryManName}.';
    }else {
      return '${orderData.history_message}';
    }
}

