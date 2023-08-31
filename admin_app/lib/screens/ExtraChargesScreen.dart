import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/models/ExtraChragesListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../components/AddExtraChargeDialog.dart';
import '../main.dart';
import '../utils/Common.dart';

class ExtraChargesScreen extends StatefulWidget {
  static String tag = '/ExtraChangesComponent';

  @override
  ExtraChargesScreenState createState() => ExtraChargesScreenState();
}

class ExtraChargesScreenState extends State<ExtraChargesScreen> {
  ScrollController scrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;

  List<ExtraChargesData> extraChargeList = [];

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;
          setState(() {});
          getExtraChargeListApiCall();
        }
      }
    });
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
      getExtraChargeListApiCall();
    });
  }

  getExtraChargeListApiCall() async {
    appStore.setLoading(true);
    await getExtraChargeList(page: currentPage, isDeleted: true).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        extraChargeList.clear();
      }
      extraChargeList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteExtraChargeApiCall(int id) async {
    appStore.setLoading(true);
    await deleteExtraCharge(id).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getExtraChargeListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreExtraChargeApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await extraChargeAction(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getExtraChargeListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  updateStatusApiCall(ExtraChargesData extraChargesData) async {
    Map req = {
      "id": extraChargesData.id,
      "status": extraChargesData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await addExtraCharge(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getExtraChargeListApiCall();
      toast(value.message.toString());
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
    return Scaffold(
      appBar: AppBar(title: Text(language.extraCharges), actions: [
        addButton(language.add, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AddExtraChargeDialog(
                onUpdate: () {
                  currentPage = 1;
                  getExtraChargeListApiCall();
                },
              );
            },
          );
        }),
      ]),
      body: Observer(builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ListView.builder(
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              shrinkWrap: true,
              controller: scrollController,
              itemCount: extraChargeList.length,
              itemBuilder: (context, index) {
                ExtraChargesData mData = extraChargeList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: containerDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text('#${mData.id}', style: boldTextStyle()),
                            SizedBox(width: 8),
                            Expanded(child: Text('${mData.title ?? "-"}', style: boldTextStyle())),
                            SizedBox(width: 16),
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    border: Border.all(color: mData.status == 1 ? primaryColor.withOpacity(0.6) : Colors.red.withOpacity(0.6)),
                                    color: mData.status == 1 ? primaryColor.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(defaultRadius)),
                                child: Text(
                                  '${mData.status == 1 ? language.enable : language.disable}',
                                  style: primaryTextStyle(color: mData.status == 1 ? primaryColor : Colors.red),
                                ),
                              ),
                              onTap: () {
                                mData.deletedAt == null
                                    ? commonConfirmationDialog(context, mData.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                        if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                          toast(language.demoAdminMsg);
                                        } else {
                                          Navigator.pop(context);
                                          updateStatusApiCall(mData);
                                        }
                                      }, title: mData.status != 1 ? language.enableExtraCharge : language.disableExtraCharge, subtitle: mData.status != 1 ? language.enableExtraChargeMsg : language.disableExtraChargeMsg)
                                    : toast(language.youCannotUpdateStatusRecordDeleted);
                              },
                            ),
                            SizedBox(width: 8),
                            outlineActionIcon(context, mData.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, () {
                              mData.deletedAt == null
                                  ? showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext dialogContext) {
                                        return AddExtraChargeDialog(
                                          extraChargesData: mData,
                                          onUpdate: () {
                                            currentPage = 1;
                                            getExtraChargeListApiCall();
                                          },
                                        );
                                      },
                                    )
                                  : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                      if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                        toast(language.demoAdminMsg);
                                      } else {
                                        Navigator.pop(context);
                                        restoreExtraChargeApiCall(id: mData.id, type: RESTORE);
                                      }
                                    }, title: language.restoreExtraCharges, subtitle: language.restoreExtraChargesMsg);
                            }),
                            SizedBox(width: 8),
                            outlineActionIcon(context, mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, () {
                              commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                  toast(language.demoAdminMsg);
                                } else {
                                  Navigator.pop(context);
                                  mData.deletedAt == null ? deleteExtraChargeApiCall(mData.id!) : restoreExtraChargeApiCall(id: mData.id, type: FORCE_DELETE);
                                }
                              }, isForceDelete: mData.deletedAt != null, title: language.deleteExtraCharges, subtitle: language.deleteExtraChargesMsg);
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.countryName, style: primaryTextStyle(size: 14)),
                                Text('${mData.countryName ?? "-"}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.cityName, style: primaryTextStyle(size: 14)),
                                Text('${mData.cityName ?? "-"}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.charge, style: primaryTextStyle(size: 14)),
                                Text('${mData.charges} ${mData.chargesType == CHARGE_TYPE_PERCENTAGE ? '%' : ''}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.created, style: primaryTextStyle(size: 14)),
                                Text(printDate(mData.createdAt!), style: secondaryTextStyle(size: 15)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            appStore.isLoading
                ? loaderWidget()
                : extraChargeList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        );
      }),
    );
  }
}
