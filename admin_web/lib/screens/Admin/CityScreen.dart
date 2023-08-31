import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/AddButtonComponent.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '/../utils/Extensions/shared_pref.dart';
import '../../components/Admin/CityInfoDialog.dart';
import '/../models/CityListModel.dart';
import '/../network/RestApis.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../main.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/text_styles.dart';
import '../../components/Admin/AddCityDialog.dart';
import '../../components/PaginationWidget.dart';
//import 'package:local_delivery_admin/utils/Extensions/app_common.dart';

class CityScreen extends StatefulWidget {
  static String route = '/admin/city';

  @override
  CityScreenState createState() => CityScreenState();
}

class CityScreenState extends State<CityScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<CityData> cityList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(CITY_INDEX);
    getCityListApiCall();
  }

  getCityListApiCall() async {
    appStore.setLoading(true);
    await getCityList(page: currentPage, isDeleted: true, perPage: perPage)
        .then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      cityList.clear();
      cityList.addAll(value.data!);
      if (currentPage != 1 && cityList.isEmpty) {
        currentPage -= 1;
        getCityListApiCall();
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteCityApiCall(int id) async {
    appStore.setLoading(true);
    await deleteCity(id).then((value) {
      appStore.setLoading(false);
      getCityListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreCityApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await cityAction(req).then((value) {
      appStore.setLoading(false);
      getCityListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  updateStatusApiCall(CityData cityData) async {
    Map req = {
      "id": cityData.id,
      "status": cityData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await addCity(req).then((value) {
      appStore.setLoading(false);
      getCityListApiCall();
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
    Widget addCityButton() {
      return AddButtonComponent(language.add_city, () {
        showDialog(
          context: context,
          barrierDismissible:
              false, // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return AddCityDialog(
              onUpdate: () {
                getCityListApiCall();
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
              padding: EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              controller: ScrollController(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveWidget.isSmallScreen(context) &&
                          appStore.isMenuExpanded
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(language.city,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            addCityButton(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.city,
                                style: boldTextStyle(
                                    size: 20, color: primaryColor)),
                            addCityButton(),
                          ],
                        ),
                  cityList.isNotEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 16),
                            RawScrollbar(
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              thumbColor: appStore.isDarkMode
                                  ? Colors.white12
                                  : Colors.black12,
                              radius: Radius.circular(defaultRadius),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: appStore.isDarkMode
                                        ? scaffoldColorDark
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    boxShadow: commonBoxShadow()),
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(16),
                                  scrollDirection: Axis.horizontal,
                                  controller: horizontalScrollController,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: getBodyWidth(context) - 48),
                                    child: DataTable(
                                      dataRowHeight: 45,
                                      headingRowHeight: 45,
                                      horizontalMargin: 16,
                                      headingRowColor:
                                          MaterialStateColor.resolveWith(
                                              (states) => primaryColor
                                                  .withOpacity(0.1)),
                                      showCheckboxColumn: false,
                                      dataTextStyle: primaryTextStyle(size: 14),
                                      headingTextStyle: boldTextStyle(),
                                      columns: [
                                        DataColumn(label: Text(language.id)),
                                        DataColumn(
                                            label: Text(language.city_name)),
                                        DataColumn(
                                            label: Text(language.country_name)),
                                        DataColumn(label: Text("Vehicle Type")),
                                        DataColumn(
                                            label: Text("Delivery Type")),
                                        DataColumn(
                                            label: Text(language.created_date)),
                                        DataColumn(
                                            label: Text(language.status)),
                                        DataColumn(
                                            label: Text(language.actions)),
                                      ],
                                      rows: cityList.map((mData) {
                                        return DataRow(cells: [
                                          DataCell(Text('${mData.id}')),
                                          DataCell(
                                              Text('${mData.name ?? "-"}')),
                                          DataCell(Text(
                                              '${mData.countryName ?? "-"}')),
                                          DataCell(Text(
                                              '${mData.vehicle_type ?? "-"}')),
                                          DataCell(Text(
                                              '${mData.order_type ?? "-"}')),
                                          DataCell(Text(printDate(
                                              mData.createdAt ?? ""))),
                                          DataCell(TextButton(
                                            child: Text(
                                              '${mData.status == 1 ? language.enable : language.disable}',
                                              style: primaryTextStyle(
                                                  color: mData.status == 1
                                                      ? primaryColor
                                                      : Colors.red),
                                            ),
                                            onPressed: () {
                                              mData.deletedAt == null
                                                  ? commonConfirmationDialog(
                                                      context,
                                                      mData.status == 1
                                                          ? DIALOG_TYPE_DISABLE
                                                          : DIALOG_TYPE_ENABLE,
                                                      () {
                                                      if (getStringAsync(
                                                              USER_TYPE) ==
                                                          DEMO_ADMIN) {
                                                        toast(language
                                                            .demo_admin_msg);
                                                      } else {
                                                        Navigator.pop(context);
                                                        updateStatusApiCall(
                                                            mData);
                                                      }
                                                    },
                                                      title: mData.status != 1
                                                          ? language.enable_city
                                                          : language
                                                              .disable_city,
                                                      subtitle: mData.status !=
                                                              1
                                                          ? language
                                                              .enable_city_msg
                                                          : language
                                                              .disable_city_msg)
                                                  : toast(language
                                                      .you_cannot_update_status_record_deleted);
                                            },
                                          )),
                                          DataCell(
                                            Row(
                                              children: [
                                                outlineActionIcon(
                                                    mData.deletedAt == null
                                                        ? Icons.edit
                                                        : Icons.restore,
                                                    Colors.green,
                                                    '${mData.deletedAt == null ? language.edit : language.restore}',
                                                    () {
                                                  mData.deletedAt == null
                                                      ? showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false, // false = user must tap button, true = tap outside dialog
                                                          builder: (BuildContext
                                                              dialogContext) {
                                                            return AddCityDialog(
                                                              cityData: mData,
                                                              onUpdate: () {
                                                                getCityListApiCall();
                                                              },
                                                            );
                                                          },
                                                        )
                                                      : commonConfirmationDialog(
                                                          context,
                                                          DIALOG_TYPE_RESTORE,
                                                          () {
                                                          if (getStringAsync(
                                                                  USER_TYPE) ==
                                                              DEMO_ADMIN) {
                                                            toast(language
                                                                .demo_admin_msg);
                                                          } else {
                                                            Navigator.pop(
                                                                context);
                                                            restoreCityApiCall(
                                                                id: mData.id,
                                                                type: RESTORE);
                                                          }
                                                        },
                                                          title: language
                                                              .restore_city,
                                                          subtitle: language
                                                              .do_you_want_to_restore_this_city);
                                                }),
                                                SizedBox(width: 8),
                                                outlineActionIcon(
                                                    mData.deletedAt == null
                                                        ? Icons.delete
                                                        : Icons.delete_forever,
                                                    Colors.red,
                                                    '${mData.deletedAt == null ? language.delete : language.force_delete}',
                                                    () {
                                                  commonConfirmationDialog(
                                                      context,
                                                      DIALOG_TYPE_DELETE, () {
                                                    if (getStringAsync(
                                                            USER_TYPE) ==
                                                        DEMO_ADMIN) {
                                                      toast(language
                                                          .demo_admin_msg);
                                                    } else {
                                                      Navigator.pop(context);
                                                      mData.deletedAt == null
                                                          ? deleteCityApiCall(
                                                              mData.id!)
                                                          : restoreCityApiCall(
                                                              id: mData.id,
                                                              type:
                                                                  FORCE_DELETE);
                                                    }
                                                  },
                                                      isForceDelete:
                                                          mData.deletedAt !=
                                                              null,
                                                      title:
                                                          language.delete_city,
                                                      subtitle: language
                                                          .do_you_want_to_delete_this_city);
                                                }),
                                                SizedBox(width: 8),
                                                outlineActionIcon(
                                                    Icons.visibility,
                                                    primaryColor,
                                                    language.view, () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          CityInfoDialog(
                                                              cityData: mData));
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
                            paginationWidget(context,
                                currentPage: currentPage,
                                totalPage: totalPage,
                                perPage: perPage,
                                onUpdate: (currentPageVal, perPageVal) {
                              currentPage = currentPageVal;
                              perPage = perPageVal;
                              getCityListApiCall();
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
                : cityList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        ),
      );
    });
  }
}
