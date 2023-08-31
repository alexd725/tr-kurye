import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/components/AddVehicleDialog.dart';

import '../components/AddCityDialog.dart';
import '../main.dart';
import '../models/VehicleModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({Key? key}) : super(key: key);

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  ScrollController controller = ScrollController();

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
    // appStore.setSelectedMenuIndex(VEHICLE_INDEX);
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
    return Scaffold(
      appBar: AppBar(title: Text(language.vehicle), actions: [
        addButton(language.add, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AddVehicleDialog(
                onUpdate: () {
                  currentPage = 1;
                  getVehicleListApiCall();
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
              controller: controller,
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              itemCount: vehicleList.length,
              itemBuilder: (context, index) {
                VehicleData mData = vehicleList[index];
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
                            Text('#${mData.id}', style: boldTextStyle()),
                            SizedBox(width: 8),
                            Text('${mData.title ?? "-"}', style: boldTextStyle()),
                            Spacer(),
                            GestureDetector(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                margin: EdgeInsets.only(right: 8),
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
                                      }, title: mData.status != 1 ? language.enableCity : language.disable_vehicle, subtitle: mData.status != 1 ? language.enableCityMsg : language.disable_vehicle_msg)
                                    : toast(language.youCannotUpdateStatusRecordDeleted);
                              },
                            ),
                            outlineActionIcon(context, mData.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, () {
                              mData.deletedAt == null
                                  ? showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      // false = user must tap button, true = tap outside dialog
                                      builder: (BuildContext dialogContext) {
                                        return AddVehicleDialog(
                                          vehicleData: mData,
                                          onUpdate: () {
                                            currentPage = 1;
                                            getVehicleListApiCall();
                                          },
                                        );
                                      },
                                    )
                                  : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                      if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                        toast(language.demoAdminMsg);
                                      } else {
                                        Navigator.pop(context);
                                        restoreVehicleApiCall(id: mData.id, type: RESTORE);
                                      }
                                    }, title: language.restoreVehicle, subtitle: language.restoreVehicleMsg);
                            }),
                            SizedBox(width: 8),
                            outlineActionIcon(context, mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, () {
                              commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                  toast(language.demoAdminMsg);
                                } else {
                                  Navigator.pop(context);
                                  mData.deletedAt == null ? deleteVehicleApi(mData.id!) : restoreVehicleApiCall(id: mData.id, type: FORCE_DELETE);
                                }
                              }, isForceDelete: mData.deletedAt != null, title: language.delete_vehicle, subtitle: language.deleteVehicleMsg);
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
                                Text(language.vehicle_name, style: primaryTextStyle(size: 14)),
                                Text('${mData.title}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${language.vehicle_size}', style: primaryTextStyle(size: 14)),
                                Text('${mData.size}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${language.vehicle_capacity} ', style: primaryTextStyle(size: 14)),
                                Text('${mData.capacity}', style: boldTextStyle(size: 15)),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.description, style: primaryTextStyle(size: 14)),
                                Text('${(mData.description)}', style: secondaryTextStyle()),
                              ],
                            ),
                            Divider(thickness: 0.9, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.status, style: primaryTextStyle(size: 14)),
                                Text('${mData.status} ', style: boldTextStyle(size: 15)),
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
                : vehicleList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        );
      }),
    );
  }
}
