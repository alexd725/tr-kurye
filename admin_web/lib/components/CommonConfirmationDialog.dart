import 'package:flutter/material.dart';
import 'package:local_delivery_admin/utils/Extensions/string_extensions.dart';
import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/text_styles.dart';

commonConfirmationDialog(BuildContext context, String dialogType, Function() onSuccess, {bool isForceDelete = false, String? title, String? subtitle}) {
  IconData? icon;
  Color? color;
  if (dialogType == DIALOG_TYPE_DELETE) {
    icon = isForceDelete ? Icons.delete_forever : Icons.delete;
    color = Colors.red;
  } else if (dialogType == DIALOG_TYPE_RESTORE) {
    icon = Icons.restore;
    color = Colors.green;
  } else if (dialogType == DIALOG_TYPE_ENABLE) {
    color = primaryColor;
  } else if (dialogType == DIALOG_TYPE_DISABLE) {
    color = Colors.red;
  }
  showDialog<void>(
    context: context,
    barrierDismissible: false, // false = user must tap button, true = tap outside dialog
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        actionsPadding: EdgeInsets.all(16),
        content: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon != null
                  ? Container(
                      decoration: BoxDecoration(color: color!.withOpacity(0.2), shape: BoxShape.circle),
                      padding: EdgeInsets.all(16),
                      child: Icon(icon, color: color),
                    )
                  : SizedBox(),
              SizedBox(height: 30),
              Text(title.validate(), style: primaryTextStyle(size: 24), textAlign: TextAlign.center),
              SizedBox(height: 16),
              Text(subtitle.validate(), style: secondaryTextStyle(), textAlign: TextAlign.center),
              SizedBox(height: 8),
              if (isForceDelete) Text(language.you_delete_this_recover_it, style: secondaryTextStyle(), textAlign: TextAlign.center),
            ],
          ),
        ),
        actions: <Widget>[
          dialogSecondaryButton(language.no, () {
            Navigator.pop(context);
          }),
          dialogPrimaryButton(language.yes, () {
            onSuccess.call();
          }, color: color),
        ],
      );
    },
  );
}
