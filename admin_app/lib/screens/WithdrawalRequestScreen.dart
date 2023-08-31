import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../components/BankDetailInfoWidget.dart';
import '../main.dart';
import '../models/WithdrawModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  @override
  _WithdrawalRequestScreenState createState() => _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  ScrollController horizontalScrollController = ScrollController();
  ScrollController controller = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<WithdrawResponse> withdrawalList = [];

  @override
  void initState() {
    super.initState();
    init();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;
          setState(() {});
          getWithdrawListApiCall();
        }
      }
    });
  }

  Future<void> init() async {
    getWithdrawListApiCall();
  }

  // Document List
  getWithdrawListApiCall() async {
    appStore.setLoading(true);
    await getWithdrawList(page: currentPage, perPage: perPage).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        withdrawalList.clear();
      }
      withdrawalList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
      toast(error.toString());
    });
  }

  // Force
  deleteWithdrawApiCall(int id) async {
    appStore.setLoading(true);
    Map req = {"id": id};
    await deleteWithdraw(req).then((value) {
      appStore.setLoading(false);
      getWithdrawListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  approveWithdrawApiCall(int id) async {
    appStore.setLoading(true);
    Map req = {"id": id};
    await approveWithdraw(req).then((value) {
      appStore.setLoading(false);
      getWithdrawListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  showBankDetail(int id, String name) async {
    appStore.setLoading(true);
    await getUserDetail(id).then((value) {
      appStore.setLoading(false);
      showDialog(context: context, builder: (context) => BankDetailInfoWidget(cityData: value.userBankAccount, userName: name));
    }).catchError((e) {
      appStore.setLoading(false);

      log(e);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(language.withdrawRequest)),
        body: Observer(
          builder: (_) => Stack(
            children: [
              ListView.builder(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                  controller: controller,
                  itemCount: withdrawalList.length,
                  itemBuilder: (context, i) {
                    WithdrawResponse mData = withdrawalList[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: containerDecoration(),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Text('#${mData.id ?? "-"}', style: boldTextStyle(color: primaryColor)),
                                Spacer(),
                                if (mData.status!.toString() != DECLINE && mData.status!.toString() != APPROVED)
                                  Row(
                                    children: [
                                      outlineActionIcon(context, Icons.check, Colors.green, () {
                                        commonConfirmationDialog(context, DIALOG_TYPE_ENABLE, () {
                                          if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                            toast(language.demoAdminMsg);
                                          } else {
                                            Navigator.pop(context);
                                            approveWithdrawApiCall(mData.id!);
                                          }
                                        }, title: language.withdrawRequest, subtitle: language.acceptConfirmation);
                                      }),
                                      SizedBox(width: 8),
                                      outlineActionIcon(context, Icons.delete, Colors.red, () {
                                        commonConfirmationDialog(context, DIALOG_TYPE_DISABLE, () {
                                          if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                            toast(language.demoAdminMsg);
                                          } else {
                                            Navigator.pop(context);
                                            deleteWithdrawApiCall(mData.id!);
                                          }
                                        }, title: language.withdrawRequest, subtitle: language.declinedConfirmation);
                                      }, title: ''),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.name, style: primaryTextStyle(size: 14)),
                                              Text('${mData.userName ?? ""}', style: boldTextStyle(size: 15)),
                                            ],
                                          ),
                                          Divider(thickness: 0.9, height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.amount, style: primaryTextStyle(size: 14)),
                                              Text('${mData.amount ?? ""}', style: boldTextStyle(size: 15)),
                                            ],
                                          ),
                                          Divider(thickness: 0.9, height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.availableBalance, style: primaryTextStyle(size: 14)),
                                              mData.status! == REQUESTED
                                                  ? Text(mData.walletBalance.toString(), style: boldTextStyle(size: 15))
                                                  : Text('-', style: boldTextStyle(size: 15)),
                                            ],
                                          ),
                                          Divider(thickness: 0.9, height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.status, style: primaryTextStyle(size: 14)),
                                              Text(withdrawStatus(mData.status!), style: boldTextStyle(size: 15, color: withdrawStatusColor(mData.status!))),
                                            ],
                                          ),
                                          Divider(thickness: 0.9, height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.created, style: primaryTextStyle(size: 14)),
                                              Text(printDate(mData.createdAt!), style: secondaryTextStyle()),
                                            ],
                                          ),
                                          Divider(thickness: 0.9, height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language.bankDetails, style: primaryTextStyle(size: 14)),
                                              mData.status! == REQUESTED
                                                  ? outlineActionIcon(context, Icons.visibility, primaryColor, () {
                                                      showBankDetail(mData.userId!, mData.userName!);
                                                    })
                                                  : Text("-", style: boldTextStyle(size: 15)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              appStore.isLoading
                  ? loaderWidget()
                  : withdrawalList.isEmpty
                      ? emptyWidget()
                      : SizedBox()
            ],
          ),
        ));
  }
}
