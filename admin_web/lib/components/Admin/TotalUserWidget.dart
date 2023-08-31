import 'package:flutter/material.dart';
import 'package:local_delivery_admin/utils/Extensions/bool_extensions.dart';

import '../../main.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';

class TotalUserWidget extends StatefulWidget {
  final String? title;
  final int? totalCount;
  final String? image;

  TotalUserWidget({this.title, this.totalCount, this.image});

  @override
  State<TotalUserWidget> createState() => _TotalUserWidgetState();
}

class _TotalUserWidgetState extends State<TotalUserWidget> {
  bool? onHover = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (v) {
        onHover = v;
        setState(() {});
      },
      onTap: () {},
      child: Container(
        width: 248,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          boxShadow: commonBoxShadow(),
          color: onHover == true
              ? primaryColor.withOpacity(0.6)
              : appStore.isDarkMode
                  ? scaffoldColorDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.totalCount.toString(), style: boldTextStyle(size: 20, color: onHover == true ? Colors.white : textPrimaryColor)),
                  SizedBox(height: 8),
                  Text(widget.title!, style: secondaryTextStyle(size: 14, color: onHover == true ? Colors.white : textSecondaryColorGlobal), maxLines: 1),
                ],
              ),
            ),
            SizedBox(width: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultRadius),
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    Colors.pink,
                    Colors.purple,
                  ],
                ),
              ),
              child: ImageIcon(AssetImage(widget.image!), size: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
