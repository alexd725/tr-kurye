import 'package:flutter/material.dart';
import '../main.dart';
import '../models/UserModel.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class BankDetailInfoWidget extends StatefulWidget {
  static String tag = '/BankDetailInfoWidget';

  final UserBankAccount? cityData;
  final String? userName;

  BankDetailInfoWidget({this.cityData, this.userName});

  @override
  BankDetailInfoWidgetState createState() => BankDetailInfoWidgetState();
}

class BankDetailInfoWidgetState extends State<BankDetailInfoWidget> {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.userName}', style: boldTextStyle(size: 20)),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            // informationWidget(language.city_id, '${widget.cityData!.id}'),
            informationWidget(language.bankName, '${widget.cityData!.bankName}'),
            Divider(height: 20),
            informationWidget(language.accountHolderName, '${widget.cityData!.accountHolderName}'),
            Divider(height: 20),
            informationWidget(language.accountNumber, '${widget.cityData!.accountNumber}'),
            Divider(height: 20),
            informationWidget(language.ifscCode, '${widget.cityData!.bankCode}'),
          ],
        ),
      ),
    );
  }
}
