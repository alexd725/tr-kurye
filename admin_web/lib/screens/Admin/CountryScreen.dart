import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/AddButtonComponent.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../main.dart';
import '/../models/CountryListModel.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/text_styles.dart';
import '../../components/Admin/AddCountryDialog.dart';
import '../../components/PaginationWidget.dart';

class CountryScreen extends StatefulWidget {
  static String route = '/admin/country';

  @override
  CountryScreenState createState() => CountryScreenState();
}

class CountryScreenState extends State<CountryScreen> {
  ScrollController scrollController = ScrollController();
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<CountryData> countryList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(COUNTRY_INDEX);
    getCountryListApiCall();
  }

  getCountryListApiCall() async {
    appStore.setLoading(true);
    await getCountryList(page: currentPage, isDeleted: true, perPage: perPage).then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      countryList.clear();
      countryList.addAll(value.data!);
      if (currentPage != 1 && countryList.isEmpty) {
        currentPage -= 1;
        getCountryListApiCall();
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteCountryApiCall(int id) async {
    appStore.setLoading(true);
    await deleteCountry(id).then((value) {
      appStore.setLoading(false);
      getCountryListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreCountryApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await countryAction(req).then((value) {
      appStore.setLoading(false);
      getCountryListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  updateStatusApiCall(CountryData countryData) async {
    Map req = {
      "id": countryData.id,
      "status": countryData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await addCountry(req).then((value) {
      appStore.setLoading(false);
      getCountryListApiCall();
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
    Widget addCountryButton() {
      return AddButtonComponent(language.add_country, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AddCountryDialog(onUpdate: () {
              getCountryListApiCall();
            });
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
              scrollDirection: Axis.vertical,
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
                            Text(language.country, style: boldTextStyle(size: 20, color: primaryColor)),
                            addCountryButton(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.country, style: boldTextStyle(size: 20, color: primaryColor)),
                            addCountryButton(),
                          ],
                        ),
                  countryList.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                        DataColumn(label: Text(language.country_name)),
                                        DataColumn(label: Text(language.distance_type)),
                                        DataColumn(label: Text(language.weight_type)),
                                        DataColumn(label: Text(language.created_date)),
                                        DataColumn(label: Text(language.status)),
                                        DataColumn(label: Text(language.actions)),
                                      ],
                                      rows: countryList.map((CountryData mData) {
                                        return DataRow(cells: [
                                          DataCell(Text('${mData.id}')),
                                          DataCell(Text('${mData.name ?? "-"}')),
                                          DataCell(Text('${mData.distanceType ?? "-"}')),
                                          DataCell(Text('${mData.weightType ?? "-"}')),
                                          DataCell(Text(printDate(mData.createdAt ?? ""))),
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
                                                    }, title: mData.status != 1 ? language.enable_country : language.disable_country, subtitle: mData.status != 1 ? language.enable_country_msg : language.disable_country_msg)
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
                                                          // false = user must tap button, true = tap outside dialog
                                                          builder: (BuildContext dialogContext) {
                                                            return AddCountryDialog(
                                                              countryData: mData,
                                                              onUpdate: () {
                                                                getCountryListApiCall();
                                                              },
                                                            );
                                                          },
                                                        )
                                                      : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                                          if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                            toast(language.demo_admin_msg);
                                                          } else {
                                                            Navigator.pop(context);
                                                            restoreCountryApiCall(id: mData.id, type: RESTORE);
                                                          }
                                                        }, title: language.restore_country, subtitle: language.do_you_want_to_restore_this_country);
                                                }),
                                                SizedBox(width: 8),
                                                outlineActionIcon(mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, '${mData.deletedAt == null ? language.delete : language.force_delete}', () {
                                                  commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                                    if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                      toast(language.demo_admin_msg);
                                                    } else {
                                                      Navigator.pop(context);
                                                      mData.deletedAt == null ? deleteCountryApiCall(mData.id!) : restoreCountryApiCall(id: mData.id, type: FORCE_DELETE);
                                                    }
                                                  }, isForceDelete: mData.deletedAt != null, title: language.delete_country, subtitle: language.do_you_want_to_delete_this_country);
                                                }),
                                              ],
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            paginationWidget(context, currentPage: currentPage, totalPage: totalPage, perPage: perPage, onUpdate: (currentPageVal, perPageVal) {
                              currentPage = currentPageVal;
                              perPage = perPageVal;
                              getCountryListApiCall();
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
                : countryList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        ),
      );
    });
  }
}
