import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/Admin/AddMoneyDialog.dart';
import '../../components/Admin/AddUserDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/PaginationWidget.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/widget_extensions.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../../main.dart';
import '../../models/UserDetailModel.dart';
import '../../models/UserModel.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/text_styles.dart';
import 'DeliveryPersonDocumentScreen.dart';

class DeliveryPersonDetailScreen extends StatefulWidget {
  static String route = '/admin/users/DeliveryPersonDetailScreen';
  final int? userId;

  DeliveryPersonDetailScreen({this.userId});

  @override
  _DeliveryPersonDetailScreenState createState() => _DeliveryPersonDetailScreenState();
}

class _DeliveryPersonDetailScreenState extends State<DeliveryPersonDetailScreen> {
  ScrollController walletController = ScrollController();
  ScrollController walletHorizontalController = ScrollController();
  ScrollController earningController = ScrollController();
  ScrollController earningHorizontalController = ScrollController();

  UserDetailModel? userProfileData;
  UserModel? userData;
  WalletHistory? walletHistory;
  EarningDetail? earningDetail ;
  EarningList? earningList;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getDetail();
  }

  getDetail() async {
    appStore.setLoading(true);
    await userDetailApi(widget.userId!).then((value) {
      appStore.setLoading(false);
      userProfileData = value;
      userData = value.userDataModel;
      walletHistory = value.walletHistory;
      earningList = value.earningList;
      earningDetail = value.earningDetail;
      setState(() {});
    }).catchError((e) {
      log(e);
      appStore.setLoading(false);
    });
  }

  getWalletHistory(int currentPage) {
    walletUserByUser(currentPage, widget.userId!).then((value) {
      walletHistory = value;
      setState(() {});
    }).catchError((e) {
      log(e);
    });
  }

  getEarningHistory(int currentPage) async {
    await earningUserByUser(currentPage, widget.userId!).then((value) {
      earningList = value;
      setState(() {});
    }).catchError((e) {
      log(e);
    });
  }

  updateStatusApiCall(UserModel deliveryBoyData) async {
    Map req = {
      "id": deliveryBoyData.id,
      "status": deliveryBoyData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await updateUserStatus(req).then((value) {
      appStore.setLoading(false);
      getDetail();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreDeliveryBoyApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await userAction(req).then((value) {
      appStore.setLoading(false);
      getDetail();
      toast(value.message.toString());
      Navigator.pop(context);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteUserApiCall(int id) async {
    Map req = {"id": id};
    appStore.setLoading(true);
    await deleteUser(req).then((value) {
      appStore.setLoading(false);
      getDetail();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteDeliveryBoyApiCall(int id) async {
    Map req = {"id": id};
    appStore.setLoading(true);
    await deleteUser(req).then((value) {
      appStore.setLoading(false);
      getDetail();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreUserApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await userAction(req).then((value) {
      appStore.setLoading(false);
      getDetail();
      toast(value.message.toString());
      Navigator.pop(context);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  commonWidget({String? title, var value}) {
    return Container(
      decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(width: 0.9, color: context.dividerColor), borderRadius: radius(defaultRadius)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          Text(title!, style: primaryTextStyle()),
          8.height,
          Text(value!, style: boldTextStyle()),
        ],
      ),
    );
  }

  commonBankWidget({String? title, String? value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.validate(), style: primaryTextStyle()),
        8.height,
        Text(value.validate(), style: boldTextStyle()),
      ],
    );
  }

  commonDetailWidget({IconData? icon, String? title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        8.width,
        Text(title.validate(), style: primaryTextStyle()).expand(),
      ],
    );
  }

  actionWidget() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        backButton(context, value: true),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AddMoneyDialog(
                  userId: userData!.id,
                  onUpdate: () {
                    getDetail();
                  },
                );
              },
            );
          },
          child: Text(language.addMoney, style: boldTextStyle(color: Colors.white)),
        ),
        outlineActionIcon(userData!.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, '${userData!.deletedAt == null ? language.edit : language.restore}', () {
          userData!.deletedAt == null
              ? showDialog(
                  context: context,
                  barrierDismissible: false, // false = user must tap button, true = tap outside dialog
                  builder: (BuildContext dialogContext) {
                    return AddUserDialog(
                      userData: userData,
                      userType: userData!.userType,
                      onUpdate: () {
                        getDetail();
                      },
                    );
                  },
                )
              : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                  if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                    toast(language.demo_admin_msg);
                  } else {
                    Navigator.pop(context);
                    if (userData!.userType == CLIENT)
                      restoreUserApiCall(id: userData!.id, type: RESTORE);
                    else
                      restoreDeliveryBoyApiCall(id: userData!.id, type: RESTORE);
                  }
                }, title: userData!.userType == CLIENT ? language.restore_user : language.restore_delivery_person, subtitle: userData!.userType == CLIENT ? language.restore_user_msg : language.restore_delivery_person_msg);
        }, title: ResponsiveWidget.isLargeScreen(context) || ResponsiveWidget.isMediumScreen(context) ? '${userData!.deletedAt == null ? language.edit : language.restore}' : ''),
        outlineActionIcon(userData!.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, '${userData!.deletedAt == null ? language.delete : language.force_delete}', () {
          commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
            if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
              toast(language.demo_admin_msg);
            } else {
              Navigator.pop(context);
              if (userData!.userType == CLIENT)
                userData!.deletedAt == null ? deleteUserApiCall(userData!.id!) : restoreUserApiCall(id: userData!.id, type: FORCE_DELETE);
              else {
                userData!.deletedAt == null ? deleteDeliveryBoyApiCall(userData!.id!) : restoreDeliveryBoyApiCall(id: userData!.id, type: FORCE_DELETE);
              }
            }
          },
              isForceDelete: userData!.deletedAt != null,
              title: userData!.userType == CLIENT ? language.delete_user : language.delete_delivery_person,
              subtitle: userData!.userType == CLIENT ? language.delete_user_msg : language.delete_delivery_person_msg);
        }, title: ResponsiveWidget.isLargeScreen(context) || ResponsiveWidget.isMediumScreen(context) ? '${userData!.deletedAt == null ? language.delete : language.force_delete}' : ''),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BodyCornerWidget(
      child: Observer(builder: (context) {
        return Stack(
          children: [
            if (userProfileData != null)
              SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userData != null)
                      ResponsiveWidget.isLargeScreen(context) || ResponsiveWidget.isMediumScreen(context)
                          ? Row(
                              children: [
                                Text(userData!.userType == CLIENT ? language.viewUser : language.viewDeliveryPerson, style: boldTextStyle()).expand(),
                                16.width,
                                actionWidget(),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(userData!.userType == CLIENT ? language.viewUser : language.viewDeliveryPerson, style: boldTextStyle()),
                                16.height,
                                actionWidget(),
                              ],
                            ),
                    16.height,
                    Wrap(
                      runSpacing: 8,
                      spacing: 16,
                      children: [
                        if (userData != null)
                          Container(
                            width: getDetailWidth(context),
                            alignment: Alignment.center,
                            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(width: 0.9, color: context.dividerColor), borderRadius: radius(defaultRadius)),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                commonCachedNetworkImage(userData!.profileImage.toString().validate(), height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(40),
                                8.height,
                                Text(userData!.name.validate(), style: boldTextStyle()),
                                8.height,
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 16,
                                  children: [
                                    if (userData!.userType == DELIVERYMAN && userData!.latitude != null && userData!.longitude != null)
                                      outlineActionIcon(Icons.location_on, primaryColor, language.location, () {
                                        if (userData!.latitude != null && userData!.longitude != null) {
                                          MapsLauncher.launchCoordinates(double.parse(userData!.latitude!), double.parse(userData!.longitude!));
                                        } else {
                                          toast(language.locationNotExist);
                                        }
                                      }).paddingRight(8),
                                    OutlinedButton(
                                      child: Text(
                                        '${userData!.status == 1 ? language.enable : language.disable}',
                                        style: primaryTextStyle(color: userData!.status == 1 ? primaryColor : Colors.red),
                                      ),
                                      onPressed: () {
                                        commonConfirmationDialog(context, userData!.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                          if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                            toast(language.demo_admin_msg);
                                          } else {
                                            Navigator.pop(context);
                                            updateStatusApiCall(userData!);
                                          }
                                        },
                                            title: userData!.userType == DELIVERYMAN
                                                ? userData!.status != 1
                                                    ? language.enable_delivery_person
                                                    : language.disable_delivery_person
                                                : userData!.status != 1
                                                    ? language.enable_user
                                                    : language.disable_user,
                                            subtitle: userData!.userType == DELIVERYMAN
                                                ? userData!.status != 1
                                                    ? language.do_you_want_to_enable_this_delivery_person
                                                    : language.do_you_want_to_disable_this_delivery_person
                                                : userData!.status != 1
                                                    ? language.do_you_want_to_enable_this_user
                                                    : language.do_you_want_to_disable_this_user);
                                      },
                                    ),
                                    if (userData!.userType == DELIVERYMAN)
                                      userData!.isVerifiedDeliveryMan! == 1
                                          ? Text(language.verified, style: primaryTextStyle(color: Colors.green))
                                          : SizedBox(
                                              height: 25,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pushNamed(context, DeliveryPersonDocumentScreen.route + "?delivery_man_id=${userData!.id!}");
                                                },
                                                child: Text(language.verify),
                                              ),
                                            ),
                                  ],
                                ),
                                16.height,
                                commonDetailWidget(icon: Icons.mail, title: userData!.email),
                                16.height,
                                commonDetailWidget(icon: Icons.phone, title: userData!.contactNumber),
                                if (userData!.cityName != null || userData!.countryName != null) 16.height,
                                if (userData!.cityName != null || userData!.countryName != null) commonDetailWidget(icon: Icons.map, title: userData!.cityName.validate() + ',' + userData!.countryName.validate())
                              ],
                            ),
                          ),
                        SizedBox(
                            width: getWalletTableWidth(context),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(userData!.userType == CLIENT && earningDetail != null)
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      commonWidget(title: language.walletTotalBalance, value: printAmount(earningDetail!.walletBalance ?? 0)),
                                      commonWidget(title: language.totalWithdrawal, value: printAmount(earningDetail!.totalWithdrawn ?? 0)),
                                      commonWidget(title: language.adminCommission, value: printAmount(earningDetail!.adminCommission ?? 0)),
                                      commonWidget(title: language.commission, value: printAmount(earningDetail!.deliveryManCommission ?? 0)),
                                      commonWidget(title: language.total_order, value: earningDetail!.totalOrder.toString().validate(value: '0')),
                                      commonWidget(title: language.paidOrder, value: earningDetail!.paidOrder.toString().validate(value: '0')),
                                    ],
                                  ),

                                if (userData != null && userData!.userBankAccount != null)
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(width: 0.9, color: context.dividerColor), borderRadius: radius(defaultRadius)),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(language.bankDetails, style: boldTextStyle()),
                                        8.height,
                                        Divider(),
                                        8.height,
                                        Wrap(
                                          alignment: WrapAlignment.start,
                                          runSpacing: 16,
                                          spacing: 30,
                                          children: [
                                            commonBankWidget(title: language.bankName, value: userData!.userBankAccount!.bankName.validate()),
                                            commonBankWidget(title: language.accountHolderName, value: userData!.userBankAccount!.accountHolderName.validate()),
                                            commonBankWidget(title: language.accountNumber, value: userData!.userBankAccount!.accountNumber.validate()),
                                            commonBankWidget(title: language.ifscCode, value: userData!.userBankAccount!.bankCode.validate())
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                if (userData != null && userData!.userBankAccount != null) 16.height,
                                if (userData!.userType == DELIVERYMAN && earningDetail != null)
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      commonWidget(title: language.walletTotalBalance, value: printAmount(earningDetail!.walletBalance ?? 0)),
                                      commonWidget(title: language.totalWithdrawal, value: printAmount(earningDetail!.totalWithdrawn ?? 0)),
                                      commonWidget(title: language.adminCommission, value: printAmount(earningDetail!.adminCommission ?? 0)),
                                      commonWidget(title: language.commission, value: printAmount(earningDetail!.deliveryManCommission ?? 0)),
                                      commonWidget(title: language.total_order, value: earningDetail!.totalOrder.toString().validate(value: '0')),
                                      commonWidget(title: language.paidOrder, value: earningDetail!.paidOrder.toString().validate(value: '0')),
                                    ],
                                  ),
                                SizedBox(height: 20),
                                userData!.userType == CLIENT && walletHistory != null && walletHistory!.walletDataModel!.isNotEmpty
                                    ? Container(
                                        width: getWalletTableWidth(context),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(bottom: 16),
                                              decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(width: 0.9, color: context.dividerColor), borderRadius: radius(defaultRadius)),
                                              child: SingleChildScrollView(
                                                controller: walletController,
                                                padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    Text(language.walletHistory, style: boldTextStyle(color: primaryColor)),
                                                    SizedBox(height: 20),
                                                    RawScrollbar(
                                                      scrollbarOrientation: ScrollbarOrientation.bottom,
                                                      controller: walletHorizontalController,
                                                      thumbVisibility: true,
                                                      thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                                                      radius: Radius.circular(defaultRadius),
                                                      child: SingleChildScrollView(
                                                        controller: walletHorizontalController,
                                                        scrollDirection: Axis.horizontal,
                                                        padding: EdgeInsets.only(bottom: 16),
                                                        child: ConstrainedBox(
                                                          constraints: BoxConstraints(minWidth: getWalletTableWidth(context)),
                                                          child: DataTable(
                                                            headingTextStyle: boldTextStyle(),
                                                            dataTextStyle: primaryTextStyle(size: 15),
                                                            headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                                            showCheckboxColumn: false,
                                                            dataRowHeight: 45,
                                                            headingRowHeight: 45,
                                                            horizontalMargin: 16,
                                                            columns: [
                                                              DataColumn(label: Text(language.order_id)),
                                                              DataColumn(label: Text(language.transactionType)),
                                                              DataColumn(label: Text(language.amount)),
                                                              DataColumn(label: Text(language.date)),
                                                            ],
                                                            rows: walletHistory!.walletDataModel!.map((e) {
                                                              return DataRow(
                                                                cells: [
                                                                  DataCell(Text('${e.orderId ?? "-"}')),
                                                                  DataCell(Text(transactionType(e.transactionType.validate()))),
                                                                  DataCell(Text(printAmount(e.amount ?? 0))),
                                                                  DataCell(Text(e.datetime != null ? printDate(e.datetime!) : "-")),
                                                                ],
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (walletHistory!.pagination!.totalItems!.toInt() > walletHistory!.pagination!.perPage!.toInt())
                                              paginationWidget(context,
                                                  isPerpage: false,
                                                  currentPage: walletHistory!.pagination!.currentPage!,
                                                  totalPage: walletHistory!.pagination!.totalPages!,
                                                  perPage: walletHistory!.pagination!.perPage!, onUpdate: (currentPageVal, perPageVal) {
                                                getWalletHistory(currentPageVal);
                                                setState(() {});
                                              }),
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ))
                      ],
                    ),
                    16.height,
                    if (userData!.userType == DELIVERYMAN)
                      Wrap(
                        runSpacing: 16,
                        spacing: 16,
                        children: [
                          walletHistory != null && walletHistory!.walletDataModel!.isNotEmpty
                              ? Container(
                                  width: getTableWidth(context),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        child: SingleChildScrollView(
                                          controller: walletController,
                                          padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(language.walletHistory, style: boldTextStyle(color: primaryColor)),
                                              SizedBox(height: 20),
                                              RawScrollbar(
                                                scrollbarOrientation: ScrollbarOrientation.bottom,
                                                controller: walletHorizontalController,
                                                thumbVisibility: true,
                                                thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                                                radius: Radius.circular(defaultRadius),
                                                child: SingleChildScrollView(
                                                  controller: walletHorizontalController,
                                                  scrollDirection: Axis.horizontal,
                                                  padding: EdgeInsets.only(bottom: 16),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(minWidth: getTableWidth(context)),
                                                    child: DataTable(
                                                      headingTextStyle: boldTextStyle(),
                                                      dataTextStyle: primaryTextStyle(size: 15),
                                                      headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                                      showCheckboxColumn: false,
                                                      dataRowHeight: 45,
                                                      headingRowHeight: 45,
                                                      horizontalMargin: 16,
                                                      columns: [
                                                        DataColumn(label: Text(language.order_id)),
                                                        DataColumn(label: Text(language.transactionType)),
                                                        DataColumn(label: Text(language.amount)),
                                                        DataColumn(label: Text(language.date)),
                                                      ],
                                                      rows: walletHistory!.walletDataModel!.map((e) {
                                                        return DataRow(
                                                          cells: [
                                                            DataCell(Text('${e.orderId ?? "-"}')),
                                                            DataCell(Text(transactionType(e.transactionType.validate()))),
                                                            DataCell(Text(printAmount(e.amount ?? 0))),
                                                            DataCell(Text(e.datetime != null ? printDate(e.datetime!) : "-")),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(width: 0.9, color: context.dividerColor), borderRadius: radius(defaultRadius)),
                                      ),
                                      if (walletHistory!.pagination!.totalItems!.toInt() > walletHistory!.pagination!.perPage!.toInt())
                                        paginationWidget(context,
                                            isPerpage: false,
                                            currentPage: walletHistory!.pagination!.currentPage!,
                                            totalPage: walletHistory!.pagination!.totalPages!,
                                            perPage: walletHistory!.pagination!.perPage!, onUpdate: (currentPageVal, perPageVal) {
                                          getWalletHistory(currentPageVal);
                                          setState(() {});
                                        }),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          earningList != null && earningList!.earningDataModel!.isNotEmpty
                              ? Container(
                                  width: getTableWidth(context),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        child: SingleChildScrollView(
                                          controller: earningController,
                                          padding: EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(language.earningHistory, style: boldTextStyle(color: primaryColor)),
                                              SizedBox(height: 20),
                                              RawScrollbar(
                                                scrollbarOrientation: ScrollbarOrientation.bottom,
                                                controller: earningHorizontalController,
                                                thumbVisibility: true,
                                                thumbColor: appStore.isDarkMode ? Colors.white12 : Colors.black12,
                                                radius: Radius.circular(defaultRadius),
                                                child: SingleChildScrollView(
                                                  controller: earningHorizontalController,
                                                  padding: EdgeInsets.only(bottom: 16),
                                                  scrollDirection: Axis.horizontal,
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(minWidth: getTableWidth(context)),
                                                    child: DataTable(
                                                      headingTextStyle: boldTextStyle(),
                                                      dataTextStyle: primaryTextStyle(size: 15),
                                                      headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
                                                      showCheckboxColumn: false,
                                                      dataRowHeight: 45,
                                                      headingRowHeight: 45,
                                                      horizontalMargin: 16,
                                                      columns: [
                                                        DataColumn(label: Text(language.order_id)),
                                                        DataColumn(label: Text(language.earning)),
                                                        DataColumn(label: Text(language.adminCommission)),
                                                        DataColumn(label: Text(language.payment_type)),
                                                        DataColumn(label: Text(language.date)),
                                                      ],
                                                      rows: earningList!.earningDataModel!.map((e) {
                                                        return DataRow(
                                                          cells: [
                                                            DataCell(Text('${e.orderId ?? "-"}')),
                                                            DataCell(Text(printAmount(e.deliveryManCommission ?? 0))),
                                                            DataCell(Text(printAmount(e.adminCommission ?? 0))),
                                                            DataCell(Text(paymentType(e.paymentType.validate()))),
                                                            DataCell(Text(e.datetime != null ? printDate(e.datetime!) : "-")),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, border: Border.all(width: 0.9, color: context.dividerColor), borderRadius: radius(defaultRadius)),
                                      ),
                                      if (earningList!.pagination!.totalItems!.toInt() > earningList!.pagination!.perPage!.toInt())
                                        paginationWidget(context, isPerpage: false, currentPage: earningList!.pagination!.currentPage!, totalPage: earningList!.pagination!.totalPages!, perPage: earningList!.pagination!.perPage!,
                                            onUpdate: (currentPageVal, perPageVal) {
                                          getEarningHistory(currentPageVal);
                                          setState(() {});
                                        }),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    16.height,



                  ],
                ),
              ),
            if (appStore.isLoading) loaderWidget(),
          ],
        );
      }),
    );
  }
}
