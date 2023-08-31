import 'package:flutter/material.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../components/Client/FooterComponent.dart';
import '../../components/Client/HeaderWidget.dart';
import '../../main.dart';
import '../../models/Client/BuilderResponse.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/text_styles.dart';

class DeliveryPartnerScreen extends StatefulWidget {
  static const String route = '/deliverypartner';

  @override
  DeliveryPartnerScreenState createState() => DeliveryPartnerScreenState();
}

class DeliveryPartnerScreenState extends State<DeliveryPartnerScreen> {
  double elevation = 4.0;
  double scale = 1.0;
  Offset translate = Offset(0, 0);



  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWidget(isPartner: true),
            Container(
              color: backgroundColor,
              height: ResponsiveWidget.isSmallScreen(context) ? context.height() * 0.8 : context.height() * 0.65,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        builderResponse.deliveryPartner!.title.validate(),
                        style: boldTextStyle(
                          weight: FontWeight.w700,
                          size: ResponsiveWidget.isSmallScreen(context)
                              ? 30
                              : ResponsiveWidget.isMediumScreen(context)
                                  ? 35
                                  : 40,
                        ),
                      ),
                      ResponsiveWidget.isMediumScreen(context) ? 20.height : 10.height,
                      Text('With ${builderResponse.appName.validate()}, ${builderResponse.deliveryPartner!.subtitle.validate()}', style: secondaryTextStyle(size: 16)),
                      ResponsiveWidget.isMediumScreen(context) ? 50.height : 40.height,
                      SizedBox(
                        width: !ResponsiveWidget.isSmallScreen(context) ? context.width() * 0.23 : context.width(),
                        child: appButton(context, title: 'Become a  ${builderResponse.appName.validate()} Partner'.toUpperCase(), onCall: () {
                          launchUrlWidget(builderResponse.playStoreLink.validate());
                        }),
                      ),
                    ],
                  ).paddingOnly(left: mCommonPadding(context), top: 40).expand(),
                  Visibility(
                    visible: !ResponsiveWidget.isSmallScreen(context),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Container(width: context.width() * 0.37, height: context.height() * 0.8, color: Colors.grey.withOpacity(0.3)),
                        Image.asset(builderResponse.deliveryPartner!.image.validate(), width: context.width() * 0.45),
                      ],
                    ),
                  ).paddingOnly(right: mCommonPadding(context)),
                ],
              ),
            ),
            ResponsiveGridList(
                shrinkWrap: true,
                horizontalGridMargin: 30,
                verticalGridMargin: 50,
                maxItemsPerRow: 3,
                listViewBuilderOptions: ListViewBuilderOptions(physics: NeverScrollableScrollPhysics()),
                minItemsPerRow: 1,
                minItemWidth: ResponsiveWidget.isSmallScreen(context) ? context.width() / 3 : context.width() / 6,
                children: List.generate(
                  builderResponse.deliveryPartner!.benefits!.length,
                  (index) {
                    Benefit mData = builderResponse.deliveryPartner!.benefits![index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(mData.image.validate(), height: 150, width: 150, fit: BoxFit.cover).cornerRadiusWithClipRRect(200),
                        16.height,
                        Text(mData.title.validate(), style: boldTextStyle(size: 18), textAlign: TextAlign.center),
                        Text(mData.subtitle.validate(), style: secondaryTextStyle(), textAlign: TextAlign.center),
                      ],
                    ).paddingOnly(bottom: 16);
                  },
                )).paddingSymmetric(horizontal: mCommonPadding(context), vertical: 40),
            40.height,
            FooterComponent()
          ],
        ),
      ),
    );
  }
}
