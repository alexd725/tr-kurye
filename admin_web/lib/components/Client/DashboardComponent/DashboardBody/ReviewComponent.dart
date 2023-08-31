import 'package:flutter/material.dart';
import '../../../../utils/Extensions/string_extensions.dart';
import '../../../../utils/Extensions/context_extensions.dart';
import '../../../../utils/Extensions/int_extensions.dart';
import '../../../../utils/Extensions/widget_extensions.dart';

import '../../../../main.dart';
import '../../../../models/Client/BuilderResponse.dart';
import '../../../../utils/Colors.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/ResponsiveWidget.dart';
import '../../../../utils/Extensions/constants.dart';
import '../../../../utils/Extensions/decorations.dart';
import '../../../../utils/Extensions/text_styles.dart';
import '../../../../utils/Images.dart';

class ReviewComponent extends StatefulWidget {
  static String tag = '/ReviewComponent';

  @override
  ReviewComponentState createState() => ReviewComponentState();
}

class ReviewComponentState extends State<ReviewComponent> {
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  int _selectedIndex = 0;
  PageController? _controller;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _controller = PageController(initialPage: 0, viewportFraction: 0.6);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mReviewDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mHeading(language.createReview),
        Row(
          children: [
            Icon(Icons.chevron_left, size: 30, color: _selectedIndex > 0 ? primaryColor : textSecondaryColorGlobal).onTap(() {
              _controller!.previousPage(duration: _kDuration, curve: _kCurve);
            }),
            16.width,
            Icon(Icons.chevron_right, size: 30, color: _selectedIndex < 3 ? primaryColor : textSecondaryColorGlobal).onTap(() {
              _controller!.nextPage(duration: _kDuration, curve: _kCurve);
            }),
          ],
        )
      ],
    );
  }

  Widget mReviewOption() {
    return SizedBox(
      width: ResponsiveWidget.isExtraSmallScreen(context) ? context.width() : context.width() * 0.48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(ic_quote, height: 150, width: 150).paddingOnly(top: 50, right: 20),
                Container(
                  width: ResponsiveWidget.isExtraSmallScreen(context) ? context.width() : context.width() * 0.46,
                  color: accentColor,
                  height: 450,
                ).expand(),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 130),
            height: ResponsiveWidget.isExtraSmallScreen(context) ? 300 : 240,
            child: PageView.builder(
              padEnds: false,
              controller: _controller,
              itemCount: builderResponse.clientsReview!.length,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: ResponsiveWidget.isExtraSmallScreen(context) ? Axis.vertical : Axis.horizontal,
              itemBuilder: (context, index) {
                ClientsReview mData = builderResponse.clientsReview![index];
                return Container(
                  width: ResponsiveWidget.isExtraSmallScreen(context) ? context.width() : context.width() * 0.45,
                  decoration: boxDecorationRoundedWithShadow(defaultRadius.toInt()),
                  padding: EdgeInsets.all(30),
                  margin: EdgeInsets.only(right: 16, bottom: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(mData.image.validate(), height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(40),
                          16.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mData.name.validate(), style: boldTextStyle(color: primaryColor, size: ResponsiveWidget.isExtraSmallScreen(context) ? 12 : 16)),
                              Text(mData.email.validate(), style: secondaryTextStyle(size: ResponsiveWidget.isExtraSmallScreen(context) ? 10 : 12)),
                            ],
                          ).expand()
                        ],
                      ),
                      16.height,
                      Text(mData.review.validate(), style: secondaryTextStyle(size: ResponsiveWidget.isExtraSmallScreen(context) ? 10 : 12), maxLines: 8, overflow: TextOverflow.ellipsis, textAlign: TextAlign.justify).expand(),
                    ],
                  ),
                ).center();
              },
              onPageChanged: (value) {
                _selectedIndex = value;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(horizontal: mCommonPadding(context), vertical: 100),
      color: lightPrimaryColor,
      child: ResponsiveWidget.isExtraSmallScreen(context)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                mReviewDescription(),
                16.height,
                mReviewOption(),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                mReviewDescription().paddingTop(150),
                mReviewOption().expand(),
              ],
            ),
    );
  }
}
