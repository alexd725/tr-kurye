import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../utils/Colors.dart';

class BodyCornerWidget extends StatelessWidget {
  final Widget child;
  final Color? color;

  BodyCornerWidget({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appStore.isDarkMode ? scaffoldSecondaryDark : colorPrimary,
      child: Container(
        color: context.scaffoldBackgroundColor,
        height: context.height(),
        width: context.width(),
        child: child,
      ).cornerRadiusWithClipRRectOnly(
        topRight: 24,
        topLeft: 24,
      ),
    );
  }
}
