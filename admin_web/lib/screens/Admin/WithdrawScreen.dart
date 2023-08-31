import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '/../models/WithdrawModel.dart';
import '/../main.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/text_styles.dart';
import '../../components/Admin/BankDetailInfoWidget.dart';
import '../../components/PaginationWidget.dart';

class WithdrawScreen extends StatefulWidget {
  static String route = '/admin/withdraw';

  @override
  WithdrawScreenState createState() => WithdrawScreenState();
}

class WithdrawScreenState extends State<WithdrawScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<WithDrawModel> withdrawList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(WITHDRAW_INDEX);
    getWithdrawListApiCall();
  }

  // Document List
  getWithdrawListApiCall() async {
    appStore.setLoading(true);
    await getWithdrawList(page: currentPage, perPage: perPage).then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      withdrawList.clear();
      withdrawList.addAll(value.data!);
      if (currentPage != 1 && withdrawList.isEmpty) {
        currentPage -= 1;
        getWithdrawListApiCall();
      }
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
    return Observer(builder: (context) {
      return BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: ScrollController(),
              padding: EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(language.withdrawReqList, style: boldTextStyle(size: 20, color: primaryColor)),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 16),
                  withdrawList.isNotEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 16),
                            RawScrollbar(
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                              radius: Radius.circular(defaultRadius),
                              child: Container(
                                decoration: BoxDecoration(color: appStore.isDarkMode ? scaffoldColorDark : Colors.white, borderRadius: BorderRadius.circular(defaultRadius), boxShadow: commonBoxShadow()),
                                child: SingleChildScrollView(
                                  controller: horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.all(16),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: getBodyWidth(context) - 48),
                                    child: DataTable(
                                        dataRowHeight: 45,
                                        headingRowHeight: 45,
                                        horizontalMargin: 16,
                                        headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                        showCheckboxColumn: false,
                                        dataTextStyle: primaryTextStyle(size: 14),
                                        headingTextStyle: boldTextStyle(),
                                        columns: [
                                          DataColumn(label: Text(language.id)),
                                          DataColumn(label: Text(language.name)),
                                          DataColumn(label: Text(language.amount)),
                                          DataColumn(label: Text(language.availableBalance)),
                                          DataColumn(label: Text(language.created)),
                                          DataColumn(label: Text(language.status)),
                                          DataColumn(label: Text(language.actions)),
                                          DataColumn(label: Text(language.bankDetails)),
                                        ],
                                        rows: withdrawList.map((mData) {
                                          return DataRow(cells: [
                                            DataCell(Text('${mData.id}')),
                                            DataCell(Text('${mData.userName ?? "-"}')),
                                            DataCell(Text('${mData.amount.toString()}')),
                                            DataCell(mData.status! == REQUESTED ? Text('${mData.walletBalance.toString()}') : Text("-", style: primaryTextStyle())),
                                            DataCell(Text(printDate(mData.createdAt!))),
                                            DataCell(Text(
                                              '${withdrawStatus(mData.status!)}',
                                              style: primaryTextStyle(color: withdrawStatusColor(mData.status!)),
                                            )),
                                            DataCell(
                                              mData.status!.toString() != DECLINE && mData.status!.toString() != APPROVED
                                                  ? Row(
                                                      children: [
                                                        outlineActionIcon(Icons.check, Colors.green, language.accept, () {
                                                          commonConfirmationDialog(context, DIALOG_TYPE_ENABLE, () {
                                                            if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                              toast(language.demo_admin_msg);
                                                            } else {
                                                              Navigator.pop(context);
                                                              approveWithdrawApiCall(mData.id!);
                                                            }
                                                          }, title: language.withdrawRequest, subtitle: language.acceptConfirmation);
                                                        }),
                                                        SizedBox(width: 8),
                                                        outlineActionIcon(Icons.close, Colors.red, 'Delete', () {
                                                          commonConfirmationDialog(context, DIALOG_TYPE_DISABLE, () {
                                                            if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                              toast(language.demo_admin_msg);
                                                            } else {
                                                              Navigator.pop(context);
                                                              deleteWithdrawApiCall(mData.id!);
                                                            }
                                                          }, title: language.withdrawRequest, subtitle: language.declinedConfirmation);
                                                        }),
                                                      ],
                                                    )
                                                  : Text("-", style: primaryTextStyle()),
                                            ),
                                            DataCell(
                                              mData.status! == REQUESTED
                                                  ? outlineActionIcon(Icons.visibility, primaryColor, language.view, () {
                                                      showBankDetail(mData.userId!, mData.userName!);
                                                    })
                                                  : Text("-", style: primaryTextStyle()),
                                            ),
                                          ]);
                                        }).toList()),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            paginationWidget(context, currentPage: currentPage, totalPage: totalPage, perPage: perPage, onUpdate: (currentPageVal, perPageVal) {
                              currentPage = currentPageVal;
                              perPage = perPageVal;
                              getWithdrawListApiCall();
                              setState(() {});
                            }),
                            SizedBox(height: 80),
                          ],
                        )
                      : SizedBox(),
                ],
              ),
            ),
            appStore.isLoading
                ? loaderWidget()
                : withdrawList.isEmpty
                    ? emptyWidget()
                    : SizedBox()
          ],
        ),
      );
    });
  }
}
