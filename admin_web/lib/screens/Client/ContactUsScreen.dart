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
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Images.dart';

class ContactUsScreen extends StatefulWidget {
  static const String route = '/contactus';

  @override
  ContactUsScreenState createState() => ContactUsScreenState();
}

class ContactUsScreenState extends State<ContactUsScreen> {
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
              child: Text(language.contactUs, style: boldTextStyle(color: whiteColor, size: 40)).center(),
            ),
            Container(
              padding: EdgeInsets.only(left: mCommonPadding(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (ResponsiveWidget.isSmallScreen(context)) 30.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(builderResponse.contactUs!.contactTitle.validate(), style: boldTextStyle(size: 40, weight: FontWeight.w800)),
                      16.height,
                      Text(builderResponse.contactUs!.contactSubtitle.validate(), style: secondaryTextStyle(size: 20)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.visitUs, style: boldTextStyle(size: 24, color: primaryColor)),
                          Divider(color: borderColor),
                          16.height,
                          Text('${builderResponse.companyName}'.toUpperCase(), style: boldTextStyle(size: 24)),
                          8.height,
                          InkWell(
                            onTap: (){
                              launchUrlWidget('https://${builderResponse.helpAndSupport.validate()}');
                            },
                            child: createRichText(
                              list: [
                                WidgetSpan(child: Icon(Icons.help, color: textSecondaryColorGlobal, size: 16).paddingRight(8)),
                                TextSpan(text: builderResponse.helpAndSupport.validate(), style: secondaryTextStyle(size: 16))
                              ],
                            ),
                          ),
                          8.height,
                          InkWell(
                            onTap: (){
                              launchUrlWidget('mailto:${builderResponse.contactEmail.validate()}');
                            },
                            child: createRichText(
                              list: [
                                WidgetSpan(child: Icon(Icons.mail, color: textSecondaryColorGlobal, size: 16).paddingRight(8)),
                                TextSpan(text: builderResponse.contactEmail.validate(), style: secondaryTextStyle(size: 16))
                              ],
                            ),
                          ),
                        ],
                      ),
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
                  if (!ResponsiveWidget.isSmallScreen(context)) Image.asset(builderResponse.contactUs!.contactUsAppSs.validate(), height: context.height() * 0.8),
                ],
              ),
            ),
            if (ResponsiveWidget.isSmallScreen(context)) 30.height,
            FooterComponent(contact: false),
          ],
        ),
      ),
    );
  }
}
