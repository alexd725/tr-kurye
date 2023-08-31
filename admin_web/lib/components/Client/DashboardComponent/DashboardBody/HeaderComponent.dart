import 'package:flutter/material.dart';
import '../../../../../../utils/Extensions/string_extensions.dart';
import '../../../../../../utils/Extensions/context_extensions.dart';
import '../../../../../../utils/Extensions/int_extensions.dart';
import '../../../../../../utils/Extensions/widget_extensions.dart';
import '../../../../main.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/ResponsiveWidget.dart';
import '../../../../utils/Extensions/constants.dart';
import '../../../../utils/Images.dart';
import '../../GradientText.dart';
import '../../HeaderContent.dart';

class HeaderComponent extends StatefulWidget {

  @override
  HeaderComponentState createState() => HeaderComponentState();
}

class HeaderComponentState extends State<HeaderComponent> {

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      color: accentColor,
      padding: EdgeInsets.only(bottom: ResponsiveWidget.isExtraSmallScreen(context) ? 80 : 100),
      child: Stack(
        children: [
          FittedBox(
            child: GradientText(
              builderResponse.appName.validate(),
              style: TextStyle(color: textPrimaryColorGlobal, decorationStyle: TextDecorationStyle.dashed, decorationThickness: 1, letterSpacing: 2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineGradient1.withOpacity(0.2),
                  lineGradient2.withOpacity(0.08),
                ],
              ),
            ).paddingSymmetric(horizontal: mCommonPadding(context)),
          ),
          ResponsiveWidget.isExtraSmallScreen(context)
              ? Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(left: 0, right: 0, bottom: -100, child: Image.asset(ic_road_pattern, height: 150, width: context.width(), fit: BoxFit.fill)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HeaderContent(),
                        Image.asset(builderResponse.deliveryManImage.validate()).paddingTop(80),
                      ],
                    ).paddingSymmetric(horizontal: mCommonPadding(context)),
                  ],
                ).paddingTop(context.height() * 0.1)
              : Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(left: 0, right: 0, bottom: -100, child: Image.asset(ic_road_pattern, width: context.width(), fit: BoxFit.fill)),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HeaderContent().expand(),
                        100.width,
                        Image.asset(builderResponse.deliveryManImage.validate()).paddingTop(70).expand(),
                      ],
                    ).paddingSymmetric(horizontal: mCommonPadding(context)),
                  ],
                ).paddingTop(context.height() * 0.19),
        ],
      ),
    );
  }
}
