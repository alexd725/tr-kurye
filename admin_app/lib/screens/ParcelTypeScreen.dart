import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/models/ParcelTypeListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Constants.dart';
import 'package:mightydelivery_admin_app/utils/Extensions/app_common.dart';

import '../components/AddParcelTypeDialog.dart';
import '../main.dart';
import '../utils/Common.dart';

class ParcelTypeScreen extends StatefulWidget {
  static String tag = '/ParcelTypeComponent';

  @override
  ParcelTypeScreenState createState() => ParcelTypeScreenState();
}

class ParcelTypeScreenState extends State<ParcelTypeScreen> {
  ScrollController controller = ScrollController();

  int currentPage = 1;
  int totalPage = 1;

  List<ParcelTypeData> parcelTypeList = [];

  @override
  void initState() {
    super.initState();
    init();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;
          setState(() {});
          getParcelTypeListApiCall();
        }
      }
    });
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
      getParcelTypeListApiCall();
    });
  }

  getParcelTypeListApiCall() async {
    appStore.setLoading(true);
    await getParcelTypeList(page: currentPage).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        parcelTypeList.clear();
      }
      parcelTypeList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  deleteParcelTypeApiCall(int id) async {
    appStore.setLoading(true);
    await deleteParcelType(id).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getParcelTypeListApiCall();
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
      appBar: AppBar(title: Text(language.parcelType), actions: [
        addButton(language.add, () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AddParcelTypeDialog(
                onUpdate: () {
                  currentPage = 1;
                  getParcelTypeListApiCall();
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
              padding: EdgeInsets.only(left: 16,right: 16,top: 16),
              itemCount: parcelTypeList.length,
              itemBuilder: (context, index) {
                ParcelTypeData mData = parcelTypeList[index];
                return Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: containerDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(mData.label ?? "", style: boldTextStyle()),
                          Spacer(),
                          outlineActionIcon(context,Icons.edit, Colors.green, () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext dialogContext) {
                                return AddParcelTypeDialog(
                                    parcelTypeData: mData,
                                    onUpdate: () {
                                      currentPage = 1;
                                      getParcelTypeListApiCall();
                                    });
                              },
                            );
                          }),
                          SizedBox(width: 8),
                          outlineActionIcon(context,Icons.delete, Colors.red,() {
                            commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                              if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                toast(language.demoAdminMsg);
                              } else {
                                Navigator.pop(context);
                                deleteParcelTypeApiCall(mData.id!);
                              }
                            }, title: language.deleteParcelType, subtitle: language.deleteParcelTypeMsg);
                          }),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(printDate(mData.createdAt ?? ""), style: secondaryTextStyle()),
                          Text('${language.id}: #${mData.id ?? ""}', style: secondaryTextStyle()),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            appStore.isLoading
                ? loaderWidget()
                : parcelTypeList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        );
      }),
    );
  }
}
