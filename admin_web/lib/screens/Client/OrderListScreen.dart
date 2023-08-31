import 'package:flutter/material.dart';
import 'package:local_delivery_admin/components/Client/OrderComponent.dart';

class OrderListScreen extends StatefulWidget {
  @override
  OrderListScreenState createState() => OrderListScreenState();
}
class OrderListScreenState extends State<OrderListScreen> {

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
    return OrderComponent();
  }
}