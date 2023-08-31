import 'package:flutter/material.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../components/Client/FooterComponent.dart';
import '../../main.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/colors.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Images.dart';

class AboutUsScreen extends StatefulWidget {
  static const String route = '/aboutus';

  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.width(),
              color: primaryColor,
              height: context.height() * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(language.about_us, style: boldTextStyle(color: whiteColor, size: 40)),
                  16.height,
                  Text(builderResponse.aboutUs!.sortDes.validate(), style: primaryTextStyle(color: whiteColor)),
                ],
              ),
            ),
            Container(
              color: Colors.grey.withOpacity(0.1),
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                  builderResponse.aboutUs!.longDes.validate(),
                      style: secondaryTextStyle(size: !ResponsiveWidget.isSmallScreen(context) ? 16 : 12))
                  .paddingSymmetric(horizontal: mCommonPadding(context)),
            ),
            Container(
              padding: EdgeInsets.only(left: mCommonPadding(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ResponsiveWidget.isSmallScreen(context)) 30.height,

                      Text(builderResponse.aboutUs!.downloadTitle.validate(), style: boldTextStyle(size: !ResponsiveWidget.isSmallScreen(context) ? 40 : 20, weight: FontWeight.w800)),
                      16.height,
                      Text(builderResponse.aboutUs!.downloadSubtitle.validate(), style: secondaryTextStyle(size: !ResponsiveWidget.isSmallScreen(context) ? 20 : 16)),
                      50.height,
                      Row(
                        children: [
                          Image.asset(ic_play_store).onTap((){
                            launchUrlWidget(builderResponse.playStoreLink.validate());
                          }),
                          16.width,
                          Image.asset(ic_app_store).onTap((){
                            launchUrlWidget(builderResponse.appStoreLink.validate());
                          }),
                        ],
                      )
                    ],
                  ).expand(),
                  16.width,
                  if (!ResponsiveWidget.isSmallScreen(context)) Image.asset(builderResponse.aboutUs!.aboutUsAppSs.validate(), height: context.height() * 0.8).paddingRight(mCommonPadding(context)),
                ],
              ),
            ),
            if (ResponsiveWidget.isSmallScreen(context)) 30.height,
            FooterComponent(about: false),
          ],
        ),
      ),
    );
  }
}
