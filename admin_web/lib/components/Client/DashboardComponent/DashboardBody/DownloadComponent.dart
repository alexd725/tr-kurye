import 'package:flutter/material.dart';
import '../../../../utils/ResponsiveWidget.dart';
import '../../../../utils/Extensions/string_extensions.dart';
import '../../../../utils/Extensions/context_extensions.dart';
import '../../../../utils/Extensions/int_extensions.dart';
import '../../../../utils/Extensions/widget_extensions.dart';
import '../../../../main.dart';
import '../../../../utils/Common.dart';
import '../../../../utils/Extensions/text_styles.dart';
import '../../../../utils/Images.dart';

class DownloadComponent extends StatefulWidget {
  static String tag = '/DownloadComponent';

  @override
  DownloadComponentState createState() => DownloadComponentState();
}

class DownloadComponentState extends State<DownloadComponent> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mDownloadInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        60.height,
        mHeading('${language.download} ${builderResponse.appName.validate()} ${language.now}.'),
        8.height,
        Text(builderResponse.downloadText.validate(), style: secondaryTextStyle()),
        16.height,
        Row(
          children: [
            InkWell(
              onTap: () {
                launchUrlWidget(builderResponse.playStoreLink.validate());
              },
              child: Image.asset(ic_play_store),
            ),
            16.width,
            InkWell(
              onTap: () {
                launchUrlWidget(builderResponse.appStoreLink.validate());
              },
              child: Image.asset(ic_app_store),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget.isExtraSmallScreen(context)
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Image.asset(builderResponse.appSsImage.validate(), height: 450, width: context.width() * 0.5, fit: BoxFit.contain).center(), 16.height, mDownloadInfo()],
          ).paddingSymmetric(horizontal: mCommonPadding(context))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(builderResponse.appSsImage.validate(), height: 450, width: context.width() * 0.35, fit: BoxFit.contain),
              16.width,
              mDownloadInfo().expand(),
            ],
          ).paddingSymmetric(horizontal: mCommonPadding(context));
  }
}
