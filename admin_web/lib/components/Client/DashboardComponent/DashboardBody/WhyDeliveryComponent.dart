import 'package:flutter/material.dart';
import '../../../../utils/Extensions/string_extensions.dart';
import '../../../../utils/Extensions/context_extensions.dart';
import '../../../../utils/Extensions/int_extensions.dart';
import '../../../../utils/Extensions/widget_extensions.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../../../main.dart';
import '../../../../models/Client/BuilderResponse.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/ResponsiveWidget.dart';
import '../../../../utils/Extensions/text_styles.dart';

class WhyDeliveryComponent extends StatefulWidget {
  static String tag = '/WhyDeliveryComponent';

  @override
  WhyDeliveryComponentState createState() => WhyDeliveryComponentState();
}

class WhyDeliveryComponentState extends State<WhyDeliveryComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mWhyDeliveryDescription() {
    return Column(
      children: [
        mHeading("${language.why} ${builderResponse.appName.validate()}"),
        16.height,
        Text(
          '${builderResponse.whyChoose!.description.validate()}',
          style: secondaryTextStyle(weight: FontWeight.w500, wordSpacing: 0.5, size: 16),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget mWhyDeliveryOption() {
    return ResponsiveGridList(
      shrinkWrap: true,
      horizontalGridMargin: 16,
      verticalGridMargin: 16,
      maxItemsPerRow: 3,
      minItemsPerRow: 1,
      listViewBuilderOptions: ListViewBuilderOptions(physics: NeverScrollableScrollPhysics()),
      minItemWidth: ResponsiveWidget.isSmallScreen(context) ? context.width() / 3 : context.width() / 8,
      children: List.generate(
        builderResponse.whyChoose!.data!.length,
        (index) {
          WhyChooseData mData = builderResponse.whyChoose!.data![index];
          return Column(
            children: [
              Image.asset(mData.image.validate(), fit: BoxFit.cover, height: 280),
              16.height,
              Text(mData.title.validate(), style: boldTextStyle(size: 18, weight: FontWeight.w500)),
              4.height,
              Text(mData.subtitle.validate(), style: secondaryTextStyle(size: 12), textAlign: TextAlign.center),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(horizontal: mCommonPadding(context), vertical: 100),
      child: ResponsiveWidget.isExtraSmallScreen(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mWhyDeliveryDescription(),
                20.height,
                mWhyDeliveryOption(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mWhyDeliveryDescription().expand(flex: 1),
                50.width,
                mWhyDeliveryOption().expand(flex: 2),
              ],
            ),
    );
  }
}
