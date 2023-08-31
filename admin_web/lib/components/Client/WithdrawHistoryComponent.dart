import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import 'WithdrawMoneyDialog.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../models/WithdrawModel.dart';
import '../../network/ClientRestApi.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';

class WithDrawHistoryScreen extends StatefulWidget {
  static String tag = '/withdrawHistory';

  @override
  WithDrawHistoryScreenState createState() => WithDrawHistoryScreenState();
}

class WithDrawHistoryScreenState extends State<WithDrawHistoryScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;

  UserBankAccount? userBankAccount;

  List<WithDrawModel> withDrawData = [];

  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
    getBankDetail();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {
    await getClientWithDrawList(page: currentPage).then((value) {
      appStore.setLoading(false);
      print("value" + value.toJson().toString());
      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      if (value.walletBalance != null) {
        clientStore.availableBal = value.walletBalance!.totalAmount;
      }
      if (currentPage == 1) {
        withDrawData.clear();
      }
      withDrawData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  getBankDetail() async {
    await getUserDetail(getIntAsync(USER_ID)).then((value) {
      userBankAccount = value.userBankAccount;
    }).then((value) {
      log(value);
    });
  }

  String printStatus(String status) {
    String text = "";
    if (status == DECLINE) {
      text = language.declined;
    } else if (status == REQUESTED) {
      text = language.requested;
    } else if (status == APPROVED) {
      text = language.approved;
    }
    return text;
  }

  Color withdrawStatusColor(String status) {
    Color color = primaryColor;
    if (status == DECLINE) {
      color = Colors.red;
    } else if (status == REQUESTED) {
      color = primaryColor;
    } else if (status == APPROVED) {
      color = Colors.green;
    }
    return color;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Form(
        key: formKey,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.withdraw, style: boldTextStyle(color: primaryColor)),
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
                      if (clientStore.availableBal != 0)
                        appButton(context, title: language.withdraw, onCall: () {
                          if (userBankAccount != null) {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return WithdrawMoneyDialog(
                                  onUpdate: () {
                                    currentPage = 1;
                                    init();
                                  },
                                );
                              },
                            );
                          } else {
                            toast(language.bankNotFound);
                            clientStore.isCurrentIndex = BANK_DETAIL_INDEX;
                          }
                        }, color: Colors.white, textColor: primaryColor)
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  padding: EdgeInsets.all(0),
                  controller: scrollController,
                  itemCount: withDrawData.length,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    WithDrawModel data = withDrawData[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.4)), borderRadius: BorderRadius.circular(defaultRadius)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(printStatus(data.status!), style: boldTextStyle(color: withdrawStatusColor(data.status!))),
                                SizedBox(height: 8),
                                Text(printDate(data.createdAt!), style: secondaryTextStyle()),
                              ],
                            ),
                          ),
                          Text('${printAmount(data.amount!.toDouble())}', style: primaryTextStyle()),
                        ],
                      ),
                    );
                  },
                ).expand()
              ],
            ),
            Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            ),
            !appStore.isLoading && withDrawData.isEmpty ? emptyWidget() : SizedBox(),
          ],
        ),
      );
    });
  }
}
