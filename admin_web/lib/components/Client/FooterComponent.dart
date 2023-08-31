import 'package:flutter/material.dart';
import '../../../../utils/Extensions/context_extensions.dart';
import '../../../../utils/Extensions/int_extensions.dart';
import '../../../../utils/Extensions/string_extensions.dart';

import '../../main.dart';
import '../../screens/Client/AboutUsScreen.dart';
import '../../screens/Client/ContactUsScreen.dart';
import '../../screens/Client/PrivacyPolicyScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';

class FooterComponent extends StatefulWidget {
  static String tag = '/FooterComponent1';

  final bool? about;
  final bool? contact;
  final bool? privacyPolicy;

  FooterComponent({this.about = true, this.contact = true, this.privacyPolicy = true});

  @override
  FooterComponentState createState() => FooterComponentState();
}

class FooterComponentState extends State<FooterComponent> {
  bool? isHover = false;

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

  Widget mValue(String value, Function onCall) {
    return InkWell(
      child: Text(value, style: boldTextStyle(color: textSecondaryColorGlobal)),
      onTap: () {
        onCall.call();
      },
    );
  }

  Widget mLinkData() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        if (widget.about == true)
          mValue(language.about, () {
            Navigator.of(context).pushNamed(AboutUsScreen.route);
          }),
        if (widget.contact == true)
          mValue(language.contact, () {
            Navigator.of(context).pushNamed(ContactUsScreen.route);
          }),
        if (widget.privacyPolicy == true)
          mValue(language.privacyPolicy, () {
            Navigator.of(context).pushNamed(PrivacyPolicyScreen.route);
          }),
      ],
    );
  }

  Widget mLinkOption(String value, IconData icon) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: textSecondaryColorGlobal),
      ),
      onTap: () {
        launchUrlWidget(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(thickness: 2, color: Colors.grey.withOpacity(0.3), height: 0),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.height() * 0.2),
          child: Container(
            width: context.width(),
            color: backgroundColor,
            padding: EdgeInsets.symmetric(horizontal: ResponsiveWidget.isLessMediumScreen(context) ? context.width() * 0.02 : context.height() * 0.1, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [mLinkData(), 16.height, socialWidget(isAbout: true)],
            ),
          ),
        ),
      ],
    );
  }
}
