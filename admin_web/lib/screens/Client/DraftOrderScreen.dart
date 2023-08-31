import 'package:flutter/material.dart';
import 'package:local_delivery_admin/components/Client/OrderComponent.dart';

class DraftOrderScreen extends StatefulWidget {

  @override
  DraftOrderScreenState createState() => DraftOrderScreenState();
}
class DraftOrderScreenState extends State<DraftOrderScreen> {

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
    return OrderComponent(isDraft: true);
  }
}