import 'package:flutter/material.dart';
import '../../../utils/Extensions/string_extensions.dart';
import '../../../utils/Extensions/context_extensions.dart';
import '../../../utils/Extensions/int_extensions.dart';
import '../../../utils/Extensions/widget_extensions.dart';
import '../../../main.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';
import '../../../utils/DataProvider.dart';
import '../../../utils/ResponsiveWidget.dart';
import '../../../utils/Extensions/colors.dart';
import '../../../utils/Extensions/text_styles.dart';
import '../../../utils/Images.dart';

class DashboardFooterComponent extends StatefulWidget {
  static String tag = '/DashboardFooterComponent';

  final bool? isLink;

  DashboardFooterComponent({this.isLink = true});

  @override
  DashboardFooterComponentState createState() => DashboardFooterComponentState();
}

class DashboardFooterComponentState extends State<DashboardFooterComponent> {

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          color: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: mCommonPadding(context), vertical: context.height() * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(ic_app_logo_color, width: context.width() * 0.03, height: context.width() * 0.03).cornerRadiusWithClipRRect(8),
                          8.width,
                          Text(builderResponse.appName.validate(), style: boldTextStyle(color: Colors.white)),
                        ],
                      ),
                      16.height,
                      Text(builderResponse.downloadFooterContent.validate(), style: primaryTextStyle(color: Colors.white)),
                      16.height,
                      downloadWidget(),
                      16.height,
                      if (ResponsiveWidget.isSmallScreen(context))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(builderResponse.appName.validate().toUpperCase(), style: boldTextStyle(color: whiteColor, size: 18)),
                                16.height,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: footerList.map((e) {
                                    return InkWell(
                                      onTap: () {
                                        if(e.link.validate().isNotEmpty){
                                          launchUrlWidget(e.link.validate());
                                        }else {
                                          Navigator.pushNamed(context, e.widgetRoute!);
                                        }
                                      },
                                      child: Text(e.title.toString(), style: primaryTextStyle(color: whiteColor, size: 14)),
                                    ).paddingSymmetric(vertical: 8);
                                  }).toList(),
                                ),
                              ],
                            ),
                            20.height,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Contact".toUpperCase(), style: boldTextStyle(color: whiteColor, size: 18)),
                                16.height,
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: contactList.map((e) {
                                      return e.name.validate().isNotEmpty
                                          ? InkWell(
                                              onTap: () {
                                                if (e.link != null) {
                                                  if (e.ind == 1)
                                                    launchUrlWidget('mailto:${e.link}');
                                                  else if (e.ind == 2) launchUrlWidget('tel:${e.link}');
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  e.icon.validate(),
                                                  8.width,
                                                  Text(e.name.toString(), style: primaryTextStyle(color: whiteColor, size: 14)),
                                                ],
                                              ),
                                            ).paddingSymmetric(vertical: 8)
                                          : SizedBox();
                                    }).toList()),
                              ],
                            ),
                            20.height,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text(language.socialMedia.toUpperCase(), style: boldTextStyle(color: whiteColor, size: 18)), 16.height, socialWidget()],
                            ),
                          ],
                        )
                    ],
                  ),
                  24.width,
                  if (!ResponsiveWidget.isSmallScreen(context))
                    Wrap(
                      runSpacing: 24,
                      spacing: 24,
                      children: [
                        SizedBox(
                          width: context.width() * 0.15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(builderResponse.appName.validate().toUpperCase(), style: boldTextStyle(color: whiteColor, size: 18)),
                              16.height,
                              ListView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(0),
                                  children: footerList.map((e) {
                                    return InkWell(
                                      onTap: () {
                                        if(e.link.validate().isNotEmpty){
                                          launchUrlWidget(e.link.validate());
                                        }else {
                                          Navigator.pushNamed(context, e.widgetRoute!);
                                        }
                                      },
                                      child: Text(e.title.toString(), style: primaryTextStyle(color: whiteColor, size: 14)),
                                    ).paddingSymmetric(vertical: 8);
                                  }).toList())
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.width() * 0.18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.contactUs.toUpperCase(), style: boldTextStyle(color: whiteColor, size: 18)),
                              16.height,
                              ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0),
                                children: contactList.map(
                                  (e) {
                                    return e.name.validate().isNotEmpty
                                        ? InkWell(
                                            onTap: () {
                                              if (e.link != null) {
                                                if (e.ind == 1)
                                                  launchUrlWidget('mailto:${e.link}');
                                                else if (e.ind == 2) launchUrlWidget('tel:${e.link}');
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                e.icon.validate(),
                                                8.width,
                                                Text(e.name.toString(), style: primaryTextStyle(color: whiteColor, size: 14)).expand(),
                                              ],
                                            ),
                                          ).paddingSymmetric(vertical: 8)
                                        : SizedBox();
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.width() * 0.15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(language.socialMedia.toUpperCase(), style: boldTextStyle(color: whiteColor, size: 18)),
                              16.height,
                              socialWidget(),
                            ],
                          ),
                        ),
                      ],
                    ).expand(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
