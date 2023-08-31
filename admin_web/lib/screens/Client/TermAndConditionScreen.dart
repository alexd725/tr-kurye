import 'package:flutter/material.dart';
import 'package:local_delivery_admin/utils/Extensions/string_extensions.dart';
import '../../../main.dart';
import '../../../utils/Extensions/context_extensions.dart';
import '../../../utils/Extensions/int_extensions.dart';
import '../../../utils/Extensions/widget_extensions.dart';
import '../../../components/Client/FooterComponent.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';
import '../../../utils/Extensions/colors.dart';
import '../../../utils/Extensions/constants.dart';
import '../../../utils/Extensions/text_styles.dart';

class TermAndConditionScreen extends StatefulWidget {
  static const String route = '/termofservice';

  @override
  TermAndConditionScreenState createState() => TermAndConditionScreenState();
}

class TermAndConditionScreenState extends State<TermAndConditionScreen> {
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
              height: context.height() * 0.3,
              child: Text(language.termsOfService, style: boldTextStyle(color: whiteColor, size: 40)).center(),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: context.height() * 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  50.height,
                  Text(builderResponse.termAndCondition.validate(), style: primaryTextStyle(color: textSecondaryColorGlobal)).paddingSymmetric(horizontal: mCommonPadding(context)),
                  50.height,
                ],
              ),
            ),
            FooterComponent(privacyPolicy: false),
          ],
        ),
      ),
    );
  }
}
