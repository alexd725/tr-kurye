import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/AddButtonComponent.dart';
import '../../components/Admin/AddExtraChargeDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/PaginationWidget.dart';
import '../../components/CommonConfirmationDialog.dart';
import '/../models/ExtraChragesListModel.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../main.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/text_styles.dart';

class ExtraChargesScreen extends StatefulWidget {
  static String route = '/admin/extracharges';

  @override
  ExtraChargesScreenState createState() => ExtraChargesScreenState();
}

class ExtraChargesScreenState extends State<ExtraChargesScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<ExtraChargesData> extraChargeList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(EXTRA_CHARGES_INDEX);
    getExtraChargeListApiCall();
  }

  getExtraChargeListApiCall() async {
    appStore.setLoading(true);
    await getExtraChargeList(page: currentPage, isDeleted: true, perPage: perPage).then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      extraChargeList.clear();
      extraChargeList.addAll(value.data!);
      if (currentPage != 1 && extraChargeList.isEmpty) {
        currentPage -= 1;
        getExtraChargeListApiCall();
      }
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

    Widget addChargeButton(){
      return AddButtonComponent(language.add_extra_charge, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AddExtraChargeDialog(
              onUpdate: () {
                getExtraChargeListApiCall();
              },
            );
          },
        );
      });
    }

    return Observer(builder: (context) {
      return BodyCornerWidget(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              controller: ScrollController(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveWidget.isSmallScreen(context) && appStore.isMenuExpanded
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(language.extra_charges, style: boldTextStyle(size: 20, color: primaryColor)),
                            addChargeButton(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.extra_charges, style: boldTextStyle(size: 20, color: primaryColor)),
                            addChargeButton(),
                          ],
                        ),
                  extraChargeList.isNotEmpty
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
                                          DataColumn(label: Text(language.title)),
                                          DataColumn(label: Text(language.country_name)),
                                          DataColumn(label: Text(language.city_name)),
                                          DataColumn(label: Text(language.charge)),
                                          DataColumn(label: Text(language.created)),
                                          DataColumn(label: Text(language.status)),
                                          DataColumn(label: Text(language.actions)),
                                        ],
                                        rows: extraChargeList.map((mData) {
                                          return DataRow(cells: [
                                            DataCell(Text('${mData.id}')),
                                            DataCell(Text('${mData.title ?? "-"}')),
                                            DataCell(Text('${mData.countryName ?? "-"}')),
                                            DataCell(Text('${mData.cityName ?? "-"}')),
                                            DataCell(Text('${mData.charges} ${mData.chargesType == CHARGE_TYPE_PERCENTAGE ? '%' : ''}')),
                                            DataCell(Text(printDate(mData.createdAt!))),
                                            DataCell(TextButton(
                                              child: Text(
                                                '${mData.status == 1 ? language.enable : language.disable}',
                                                style: primaryTextStyle(color: mData.status == 1 ? primaryColor : Colors.red),
                                              ),
                                              onPressed: () {
                                                mData.deletedAt == null
                                                    ? commonConfirmationDialog(context, mData.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                                        if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                          toast(language.demo_admin_msg);
                                                        } else {
                                                          Navigator.pop(context);
                                                          updateStatusApiCall(mData);
                                                        }
                                                      },
                                                        title: mData.status != 1 ? language.enable_extra_charge : language.disable_extra_charge,
                                                        subtitle: mData.status != 1 ? language.enable_extra_charge_msg : language.disable_extra_charge_msg)
                                                    : toast(language.you_cannot_update_status_record_deleted);
                                              },
                                            )),
                                            DataCell(
                                              Row(
                                                children: [
                                                  outlineActionIcon(mData.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, '${mData.deletedAt == null ? language.edit : language.restore}', () {
                                                    mData.deletedAt == null
                                                        ? showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (BuildContext dialogContext) {
                                                              return AddExtraChargeDialog(
                                                                extraChargesData: mData,
                                                                onUpdate: () {
                                                                  getExtraChargeListApiCall();
                                                                },
                                                              );
                                                            },
                                                          )
                                                        : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                                            if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                              toast(language.demo_admin_msg);
                                                            } else {
                                                              Navigator.pop(context);
                                                              restoreExtraChargeApiCall(id: mData.id, type: RESTORE);
                                                            }
                                                          }, title: language.restore_extraCharges, subtitle: language.do_you_want_to_restore_this_extra_charges);
                                                  }),
                                                  SizedBox(width: 8),
                                                  outlineActionIcon(mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, '${mData.deletedAt == null ? language.delete : language.force_delete}', () {
                                                    commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                                      if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                        toast(language.demo_admin_msg);
                                                      } else {
                                                        Navigator.pop(context);
                                                        mData.deletedAt == null ? deleteExtraChargeApiCall(mData.id!) : restoreExtraChargeApiCall(id: mData.id, type: FORCE_DELETE);
                                                      }
                                                    }, isForceDelete: mData.deletedAt != null, title: language.delete_extra_charges, subtitle: language.do_you_want_to_delete_this_extra_charges);
                                                  }),
                                                ],
                                              ),
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
                              getExtraChargeListApiCall();
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
                : extraChargeList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        ),
      );
    });
  }
}
