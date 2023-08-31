import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:local_delivery_admin/models/VehicleListModel.dart';
import 'package:local_delivery_admin/utils/Constants.dart';

import '../../components/AddButtonComponent.dart';
import '../../components/Admin/AddVehicleDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/Admin/VehicleInfoDialog.dart';
import '../../components/CommonConfirmationDialog.dart';
import '../../components/PaginationWidget.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/common.dart';
import '../../utils/Extensions/constants.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/ResponsiveWidget.dart';

class VehicleScreen extends StatefulWidget {
  static String route = '/admin/vehicle';

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  var perPage = 10;

  List<VehicleData> vehicleList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(VEHICLE_INDEX);
    getVehicleListApiCall();
  }

  getVehicleListApiCall() async {
    appStore.setLoading(true);
    await getVehicleList(page: currentPage, perPage: perPage, totalPage: totalPage, isDeleted: true).then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      vehicleList.clear();
      vehicleList.addAll(value.data!);
      if (currentPage != 1 && vehicleList.isEmpty) {
        currentPage -= 1;
        getVehicleListApiCall();
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
      toast(error.toString());
    });
  }

  deleteVehicleApi(int id) async {
    appStore.setLoading(true);
    await deleteVehicle(id).then((value) {
      appStore.setLoading(false);
      getVehicleListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  restoreVehicleApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await vehicleAction(req).then((value) {
      appStore.setLoading(false);
      getVehicleListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  updateStatusApiCall(VehicleData vehicleData) async {
    appStore.setLoading(true);
    await addVehicle(
      id: vehicleData.id,
      status: vehicleData.status == 1 ? 0 : 1,
      size: vehicleData.size,
      vehicleImage: vehicleData.vehicleImage,
      title: vehicleData.title,
      capacity: vehicleData.capacity,
      description: vehicleData.description,
      type: vehicleData.type,
      //cityId: vehicleData.cityIds!.map((e) => e.toString()).toList(),
    ).then((value) {
      appStore.setLoading(false);
      getVehicleListApiCall();
      log('${value.message.toString()}');
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      log('${error.toString()}');
    });
  }


  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget addVehicleButton() {
      return AddButtonComponent(language.add_vehicle, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          // false = user must tap button, true = tap outside dialog
          builder: (BuildContext dialogContext) {
            return AddVehicleDialog(
              onUpdate: () {
                getVehicleListApiCall();
              },
            );
          },
        );
      });
    }

    return Observer(
      builder: (context) {
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
                    ResponsiveWidget.isSmallScreen(context) && appStore.isMenuExpanded
                        ? Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(language.vehicle, style: boldTextStyle(size: 20, color: primaryColor)),
                              addVehicleButton(),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(language.vehicle, style: boldTextStyle(size: 20, color: primaryColor)),
                              addVehicleButton(),
                            ],
                          ),
                    Column(
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
                              padding: EdgeInsets.all(16),
                              scrollDirection: Axis.horizontal,
                              controller: horizontalScrollController,
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
                                    DataColumn(label: Text(language.vehicle_name)),
                                    DataColumn(label: Text(language.vehicle_size)),
                                    DataColumn(label: Text(language.vehicle_capacity)),
                                    DataColumn(label: Text(language.description)),
                                    DataColumn(label: Text(language.status)),
                                    DataColumn(label: Text(language.vehicle_image)),
                                    DataColumn(label: Text(language.actions)),
                                  ],
                                  rows: vehicleList.map((mData) {
                                    return DataRow(cells: [
                                      DataCell(Text('${mData.id}')),
                                      DataCell(Text('${mData.title ?? "-"}')),
                                      DataCell(Text('${mData.size ?? "-"}')),
                                      DataCell(Text('${mData.capacity ?? "-"}')),
                                      DataCell(Text('${mData.description ?? "-"}')),
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
                                                }, title: mData.status != 1 ? language.enable_vehicle : language.disable_vehicle, subtitle: mData.status != 1 ? language.enable_vehicle_msg : language.disable_vehicle_msg)
                                              : toast(language.you_cannot_update_status_record_deleted);
                                        },
                                      )),
                                      DataCell(
                                        // Text('${mData.vehicleImage ?? "-"}')
                                        Container(
                                          margin: EdgeInsets.all(10),
                                          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: commonCachedNetworkImage(mData.vehicleImage, fit: BoxFit.fill, height: 70, width: 50)),
                                        ),
                                      ),
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
                                                        return AddVehicleDialog(
                                                          vehicleData: mData,
                                                          onUpdate: () {
                                                            getVehicleListApiCall();
                                                          },
                                                        );
                                                      },
                                                    )
                                                  : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                                      if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                        toast(language.demo_admin_msg);
                                                      } else {
                                                        Navigator.pop(context);
                                                        restoreVehicleApiCall(id: mData.id, type: RESTORE);
                                                      }
                                                    }, title: language.restore_city, subtitle: language.do_you_want_to_restore_this_city);
                                            }),
                                            SizedBox(width: 8),
                                            outlineActionIcon(mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, '${mData.deletedAt == null ? language.delete : language.force_delete}', () {
                                              commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                                if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                  toast(language.demo_admin_msg);
                                                } else {
                                                  Navigator.pop(context);
                                                  mData.deletedAt == null ? deleteVehicleApi(mData.id!) : restoreVehicleApiCall(id: mData.id, type: FORCE_DELETE);
                                                }
                                              }, isForceDelete: mData.deletedAt != null, title: language.delete_vehicle, subtitle: language.do_you_want_to_delete_this_vehicle);
                                            }),
                                            SizedBox(width: 8),
                                            outlineActionIcon(Icons.visibility, primaryColor, language.view, () {
                                              showDialog(context: context, builder: (context) => VehicleInfoDialog(vehicleData: mData));
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
                          getVehicleListApiCall();
                          setState(() {});
                        }),
                        SizedBox(height: 80),
                      ],
                    )
                  ],
                ),
              ),
              appStore.isLoading
                  ? loaderWidget()
                  : vehicleList.isEmpty
                      ? emptyWidget()
                      : SizedBox(),
            ],
          ),
        );
      }
    );
  }
}
