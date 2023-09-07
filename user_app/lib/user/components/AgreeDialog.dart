import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/utils/Widgets.dart';

class AgreeDialog extends StatefulWidget {
  static String tag = '/AgreeDialog';
  final Function() onAgree;

  AgreeDialog({required this.onAgree});

  @override
  AgreeDialogState createState() => AgreeDialogState();
}

class AgreeDialogState extends State<AgreeDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'I have read and agree to the contract \nand terms of use.',
              style: primaryTextStyle(size: 16),
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        10.height,
        textButton(
            language.termOfService, () => {commonLaunchUrl(mTermAndCondition)}),
        textButton(
            language.privacyPolicy, () => {commonLaunchUrl(mPrivacyPolicy)}),
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            roundButton('AGREE', widget.onAgree),
          ],
        ),
      ],
    );
  }
}
