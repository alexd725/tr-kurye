import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import '../../main.dart';
import '../../models/Client/WalletListModel.dart';
import '../../network/ClientRestApi.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/text_styles.dart';

class WalletScreen extends StatefulWidget {
  static String tag = '/wallet';

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {
  TextEditingController amountCont = TextEditingController();

  List<WalletModel> walletData = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getWalletData();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});
          getWalletData();
        }
      }
    });
  }

  getWalletData() async {
    appStore.setLoading(true);
    await getClientWalletList(page: currentPage).then((value) {
      appStore.setLoading(false);

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      if (value.walletBalance != null) {
        clientStore.availableBal = value.walletBalance!.totalAmount;
      }
      if (currentPage == 1) {
        walletData.clear();
      }
      walletData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.wallet, style: boldTextStyle(color: primaryColor)),
            8.height,
            Divider(color: borderColor, height: 1, thickness: 1),
            20.height,
            Container(
              decoration: boxDecorationWithRoundedCorners(backgroundColor: primaryColor),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.availableBalance, style: primaryTextStyle(size: 16, color: Colors.white.withOpacity(0.7))),
                      6.height,
                      Text('${printAmount(clientStore.availableBal)}', style: boldTextStyle(size: 22, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            16.height,
            ListView.builder(
              padding: EdgeInsets.all(0),
              controller: scrollController,
              itemCount: walletData.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                WalletModel data = walletData[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.4)), borderRadius: BorderRadius.circular(defaultRadius)),
                  child: Row(
                    children: [
                      Container(
                        decoration: boxDecorationWithRoundedCorners(backgroundColor: Colors.grey.withOpacity(0.2)),
                        padding: EdgeInsets.all(6),
                        child: Icon(data.type == CREDIT ? Icons.add : Icons.remove, color: primaryColor),
                      ),
                      10.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(transactionType(data.transactionType!), style: boldTextStyle(size: 16)),
                            SizedBox(height: 4),
                            Text(printDate(data.createdAt.validate()), style: secondaryTextStyle(size: 12)),
                          ],
                        ),
                      ),
                      Text('${printAmount(data.amount??0)}', style: secondaryTextStyle(color: data.type == CREDIT ? Colors.green : Colors.red))
                    ],
                  ),
                );
              },
            ).expand(),
          ],
        ),
        Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
      ],
    );
  }
}
