import '../fialogs.dart';
import '../src/dialogs/alert_dialog.dart';
import '../src/functions.dart';
import '../src/props/dialog_text_field.dart';
import '../src/props/progress_dialog_type.dart';
import '../src/res/colors.dart';
import '../src/res/styles.dart';
import '../src/widgets.dart';
import 'package:flutter/material.dart';

/// customAlertDialog function with [title] and [content] widgets
///
/// [positiveButtonText] for positive button text
/// [negativeButtonText] for negative button text
/// [neutralButtonText] for negative button text
/// [hideNeutralButton] to hide the Neutral Button default is false
/// [closeOnBackPress] to close dialog on back button default is false
/// [confirmationDialog] to make the confirmation dialog default is false
/// [confirmationMessage] confirmation message default is 'Please check this box for Confirmation!'
customAlertDialog(
  BuildContext context,
  Widget title,
  Widget content, {
  Widget? titleIcon,
  String? positiveButtonText,
  Function? positiveButtonAction,
  String? negativeButtonText,
  Function? negativeButtonAction,
  String? neutralButtonText,
  Function? neutralButtonAction,
  bool hideNeutralButton = false,
  bool closeOnBackPress = false,
  bool confirmationDialog = false,
  String? confirmationMessage,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: closeOnBackPress,
    barrierLabel: "",
    barrierColor: getBarrierColor(),
    transitionDuration: getDialogPopUpAnimationDuration(),
    transitionBuilder: (c2, a1, a2, widget) {
      return getDialogAnimation(a1, a2, widget);
    },
    pageBuilder: (c1, a1, a2) => WillPopScope(
      child: SimpleAlertDialog(
        title,
        content,
        icon: titleIcon,
        negativeButtonText: negativeButtonText,
        negativeButtonAction: negativeButtonAction,
        positiveButtonText: positiveButtonText,
        positiveButtonAction: positiveButtonAction,
        neutralButtonText: neutralButtonText,
        neutralButtonAction: neutralButtonAction,
        hideNeutralButton: hideNeutralButton,
        confirmationDialog: confirmationDialog,
        confirmationMessage: confirmationMessage,
      ),
      onWillPop: () async => closeOnBackPress,
    ),
  );
}

/// alert dialog function with [title] and [content] string
///
/// [positiveButtonText] for positive button text
/// [negativeButtonText] for negative button text
/// [neutralButtonText] for negative button text
/// [hideNeutralButton] to hide the Neutral Button default is false
/// [closeOnBackPress] to close dialog on back button default is false
/// [confirmationDialog] to make the confirmation dialog default is false
/// [confirmationMessage] confirmation message default is 'Please check this box for Confirmation!'
alertDialog(
  BuildContext context,
  String title,
  String content, {
  Widget? titleIcon,
  String? positiveButtonText,
  Function? positiveButtonAction,
  String? negativeButtonText,
  Function? negativeButtonAction,
  String? neutralButtonText,
  Function? neutralButtonAction,
  bool hideNeutralButton = false,
  bool closeOnBackPress = false,
  bool confirmationDialog = false,
  String? confirmationMessage,
}) {
  return customAlertDialog(
    context,
    Text(title, style: dialogTitleStyle(context)),
    Text(content,
        textAlign: TextAlign.justify, style: dialogContentStyle(context)),
    titleIcon: titleIcon,
    positiveButtonText: positiveButtonText,
    positiveButtonAction: positiveButtonAction,
    negativeButtonText: negativeButtonText,
    negativeButtonAction: negativeButtonAction,
    neutralButtonText: neutralButtonText,
    neutralButtonAction: neutralButtonAction,
    hideNeutralButton: hideNeutralButton,
    closeOnBackPress: closeOnBackPress,
    confirmationDialog: confirmationDialog,
    confirmationMessage: confirmationMessage,
  );
}

/// confirmation dialog function with [title] and [content] string
///
/// [positiveButtonText] for positive button text
/// [negativeButtonText] for negative button text
/// [neutralButtonText] for negative button text
/// [hideNeutralButton] to hide the Neutral Button default is false
/// [closeOnBackPress] to close dialog on back button default is false
/// [confirmationDialog] to make the confirmation dialog default is false
/// [confirmationMessage] confirmation message default is 'Please check this box for Confirmation!'
confirmationDialog(
  BuildContext context,
  String title,
  String content, {
  Widget? titleIcon,
  String? positiveButtonText,
  Function? positiveButtonAction,
  String? negativeButtonText,
  Function? negativeButtonAction,
  String? neutralButtonText,
  Function? neutralButtonAction,
  bool hideNeutralButton = false,
  bool closeOnBackPress = false,
  bool confirmationDialog = true,
  String? confirmationMessage,
}) {
  return customAlertDialog(
    context,
    Text(title, style: dialogTitleStyle(context)),
    Text(content,
        textAlign: TextAlign.justify, style: dialogContentStyle(context)),
    titleIcon: titleIcon ?? confirmIcon(),
    positiveButtonText: positiveButtonText,
    positiveButtonAction: positiveButtonAction,
    negativeButtonText: negativeButtonText,
    negativeButtonAction: negativeButtonAction,
    neutralButtonText: neutralButtonText,
    neutralButtonAction: neutralButtonAction,
    hideNeutralButton: hideNeutralButton,
    closeOnBackPress: closeOnBackPress,
    confirmationDialog: confirmationDialog,
    confirmationMessage: confirmationMessage,
  );
}

/// success dialog function with [title] and [content] string
///
/// [positiveButtonText] for positive button text
/// [negativeButtonText] for negative button text
/// [neutralButtonText] for negative button text
/// [hideNeutralButton] to hide the Neutral Button default is false
/// [closeOnBackPress] to close dialog on back button default is false
/// [confirmationDialog] to make the confirmation dialog default is false
/// [confirmationMessage] confirmation message default is 'Please check this box for Confirmation!'
successDialog(
  BuildContext context,
  String title,
  String content, {
  Widget? titleIcon,
  String? positiveButtonText,
  Function? positiveButtonAction,
  String? negativeButtonText,
  Function? negativeButtonAction,
  String? neutralButtonText,
  Function? neutralButtonAction,
  bool hideNeutralButton = false,
  bool closeOnBackPress = false,
  bool confirmationDialog = false,
  String? confirmationMessage,
}) {
  return customAlertDialog(
    context,
    Text(title, style: dialogTitleStyle(context)),
    Text(content,
        textAlign: TextAlign.justify, style: dialogContentStyle(context)),
    titleIcon: titleIcon ?? successIcon(),
    positiveButtonText: positiveButtonText,
    positiveButtonAction: positiveButtonAction,
    negativeButtonText: negativeButtonText,
    negativeButtonAction: negativeButtonAction,
    neutralButtonText: neutralButtonText,
    neutralButtonAction: neutralButtonAction,
    hideNeutralButton: hideNeutralButton,
    closeOnBackPress: closeOnBackPress,
    confirmationDialog: confirmationDialog,
    confirmationMessage: confirmationMessage,
  );
}

/// error dialog function with [title] and [content] string
///
/// [positiveButtonText] for positive button text
/// [negativeButtonText] for negative button text
/// [neutralButtonText] for negative button text
/// [hideNeutralButton] to hide the Neutral Button default is false
/// [closeOnBackPress] to close dialog on back button default is false
/// [confirmationDialog] to make the confirmation dialog default is false
/// [confirmationMessage] confirmation message default is 'Please check this box for Confirmation!'
errorDialog(
  BuildContext context,
  String title,
  String content, {
  Widget? titleIcon,
  String? positiveButtonText,
  Function? positiveButtonAction,
  String? negativeButtonText,
  Function? negativeButtonAction,
  String? neutralButtonText,
  Function? neutralButtonAction,
  bool hideNeutralButton = false,
  bool closeOnBackPress = false,
  bool confirmationDialog = false,
  String? confirmationMessage,
}) {
  return customAlertDialog(
    context,
    Text(title, style: dialogTitleStyle(context)),
    Text(content,
        textAlign: TextAlign.justify, style: dialogContentStyle(context)),
    titleIcon: titleIcon ?? errorIcon(),
    positiveButtonText: positiveButtonText,
    positiveButtonAction: positiveButtonAction,
    negativeButtonText: negativeButtonText,
    negativeButtonAction: negativeButtonAction,
    neutralButtonText: neutralButtonText,
    neutralButtonAction: neutralButtonAction,
    hideNeutralButton: hideNeutralButton,
    closeOnBackPress: closeOnBackPress,
    confirmationDialog: confirmationDialog,
    confirmationMessage: confirmationMessage,
  );
}

/// warning dialog function with [title] and [content] string
///
/// [positiveButtonText] for positive button text
/// [negativeButtonText] for negative button text
/// [neutralButtonText] for negative button text
/// [hideNeutralButton] to hide the Neutral Button default is false
/// [closeOnBackPress] to close dialog on back button default is false
/// [confirmationDialog] to make the confirmation dialog default is false
/// [confirmationMessage] confirmation message default is 'Please check this box for Confirmation!'
warningDialog(
  BuildContext context,
  String title,
  String content, {
  Widget? titleIcon,
  String? positiveButtonText,
  Function? positiveButtonAction,
  String? negativeButtonText,
  Function? negativeButtonAction,
  String? neutralButtonText,
  Function? neutralButtonAction,
  bool hideNeutralButton = false,
  bool closeOnBackPress = false,
  bool confirmationDialog = false,
  String? confirmationMessage,
}) {
  return customAlertDialog(
    context,
    Text(title, style: dialogTitleStyle(context)),
    Text(content,
        textAlign: TextAlign.justify, style: dialogContentStyle(context)),
    titleIcon: titleIcon ?? warningIcon(),
    positiveButtonText: positiveButtonText,
    positiveButtonAction: positiveButtonAction,
    negativeButtonText: negativeButtonText,
    negativeButtonAction: negativeButtonAction,
    neutralButtonText: neutralButtonText,
    neutralButtonAction: neutralButtonAction,
    hideNeutralButton: hideNeutralButton,
    closeOnBackPress: closeOnBackPress,
    confirmationDialog: confirmationDialog,
    confirmationMessage: confirmationMessage,
  );
}

/// info dialog function with [title] and [content] string
///
/// [positiveButtonText] for positive button text
/// [negativeButtonText] for negative button text
/// [neutralButtonText] for negative button text
/// [hideNeutralButton] to hide the Neutral Button default is false
/// [closeOnBackPress] to close dialog on back button default is false
/// [confirmationDialog] to make the confirmation dialog default is false
/// [confirmationMessage] confirmation message default is 'Please check this box for Confirmation!'
infoDialog(
  BuildContext context,
  String title,
  String content, {
  Widget? titleIcon,
  String? positiveButtonText,
  Function? positiveButtonAction,
  String? negativeButtonText,
  Function? negativeButtonAction,
  String? neutralButtonText,
  Function? neutralButtonAction,
  bool hideNeutralButton = false,
  bool closeOnBackPress = false,
  bool confirmationDialog = false,
  String? confirmationMessage,
}) {
  return customAlertDialog(
    context,
    Text(title, style: dialogTitleStyle(context)),
    Text(content,
        textAlign: TextAlign.justify, style: dialogContentStyle(context)),
    titleIcon: titleIcon ?? infoIcon(),
    positiveButtonText: positiveButtonText,
    positiveButtonAction: positiveButtonAction,
    negativeButtonText: negativeButtonText,
    negativeButtonAction: negativeButtonAction,
    neutralButtonText: neutralButtonText,
    neutralButtonAction: neutralButtonAction,
    hideNeutralButton: hideNeutralButton,
    closeOnBackPress: closeOnBackPress,
    confirmationDialog: confirmationDialog,
    confirmationMessage: confirmationMessage,
  );
}
