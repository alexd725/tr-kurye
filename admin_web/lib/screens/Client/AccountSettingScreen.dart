import 'package:flutter/material.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../services/AuthServices.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class AccountSettingScreen extends StatefulWidget {
  static const String route = '/accountsetting';

  @override
  AccountSettingScreenState createState() => AccountSettingScreenState();
}

class AccountSettingScreenState extends State<AccountSettingScreen> {


  Future deleteAccount(BuildContext context) async {
    Map req = {"id": getIntAsync(USER_ID)};
    appStore.setLoading(true);
    await deleteUser(req).then((value) async {
      await userService.removeDocument(getStringAsync(UID)).then((value) async {
        await deleteUserFirebase().then((value) async {
          await logout(context, isDeleteAccount: true).then((value) async {
            appStore.setLoading(false);
            await removeKey(USER_EMAIL);
            await removeKey(USER_PASSWORD);
          });
        }).catchError((error) {
          appStore.setLoading(false);
          toast(error.toString());
        });
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.accountSettings, style: boldTextStyle(color: primaryColor)),
        8.height,
        Divider(color: borderColor, height: 1, thickness: 1),
        16.height,
        Text(language.deleteAccText, style: primaryTextStyle()),
        20.height,
        InkWell(
          onTap: () async {
            await commonConfirmationDialog(
              context,
              DIALOG_TYPE_DELETE,
              () async {
                await deleteAccount(context);
              },
              title: language.deleteAcc,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: boxDecorationWithRoundedCorners(border: Border.all(color: redColor), borderRadius: radius(8)),
            child: createRichText(
              list: [
                WidgetSpan(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, color: redColor),
                      Text(language.deleteAccount, style: boldTextStyle(color: redColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
