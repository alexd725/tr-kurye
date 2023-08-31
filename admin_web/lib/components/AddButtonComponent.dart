import 'package:flutter/material.dart';
import 'package:local_delivery_admin/utils/Extensions/string_extensions.dart';

import '../utils/Colors.dart';
import '../utils/Extensions/constants.dart';
import '../utils/Extensions/text_styles.dart';

class AddButtonComponent extends StatefulWidget {
  final String? title;
  final Function()? onTap;

  AddButtonComponent(this.title, this.onTap);

  @override
  _AddButtonComponentState createState() => _AddButtonComponentState();
}

class _AddButtonComponentState extends State<AddButtonComponent> {
  bool onHover = false;

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
    return InkWell(
      onHover: (v) {
        onHover = v;
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white),
            if (onHover) SizedBox(width: 12),
            if (onHover) Text(widget.title.validate(), style: boldTextStyle(color: Colors.white)),
          ],
        ),
      ),
      onTap: widget.onTap,
    );
  }
}
