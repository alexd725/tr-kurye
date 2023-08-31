import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mightydelivery_admin_app/models/DocumentListModel.dart';
import 'package:mightydelivery_admin_app/network/RestApis.dart';
import 'package:mightydelivery_admin_app/utils/Colors.dart';

import '../components/AddDocumentDialog.dart';
import '../main.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class DocumentScreen extends StatefulWidget {
  static String tag = '/AppDocumentScreen';

  @override
  DocumentScreenState createState() => DocumentScreenState();
}

class DocumentScreenState extends State<DocumentScreen> {
  ScrollController controller = ScrollController();
  int currentPage = 1;
  int totalPage = 1;

  List<DocumentData> documentList = [];

  @override
  void initState() {
    super.initState();
    init();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          currentPage++;
          setState(() {});
          getDocumentListApiCall();
        }
      }
    });
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
      getDocumentListApiCall();
    });
  }

  // Document List
  getDocumentListApiCall() async {
    appStore.setLoading(true);
    await getDocumentList(page: currentPage, isDeleted: true).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages!;
      if (currentPage == 1) {
        documentList.clear();
      }
      documentList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  // Force
  deleteDocumentApiCall(int id) async {
    appStore.setLoading(true);
    await deleteDocument(id).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getDocumentListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  // Restore or force delete Document
  restoreDocumentApiCall({@required int? id, @required String? type}) async {
    Map req = {"id": id, "type": type};
    appStore.setLoading(true);
    await documentAction(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getDocumentListApiCall();
      toast(value.message.toString());
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  // Update Status
  updateStatusApiCall(DocumentData documentData) async {
    Map req = {
      "id": documentData.id,
      "status": documentData.status == 1 ? 0 : 1,
    };
    appStore.setLoading(true);
    await addDocument(req).then((value) {
      appStore.setLoading(false);
      currentPage = 1;
      getDocumentListApiCall();
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
      appBar: AppBar(
        title: Text(language.document),
        actions: [
          addButton(language.add, () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                return AddDocumentDialog(
                  onUpdate: () {
                    currentPage = 1;
                    getDocumentListApiCall();
                  },
                );
              },
            );
          })
        ],
      ),
      body: Observer(builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ListView.builder(
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              shrinkWrap: true,
              controller: controller,
              itemCount: documentList.length,
              itemBuilder: (context, index) {
                DocumentData mData = documentList[index];
                return Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: containerDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(mData.name ?? "", style: boldTextStyle()),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              mData.deletedAt == null
                                  ? commonConfirmationDialog(context, mData.status == 1 ? DIALOG_TYPE_DISABLE : DIALOG_TYPE_ENABLE, () {
                                      if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                        toast(language.demoAdminMsg);
                                      } else {
                                        Navigator.pop(context);
                                        updateStatusApiCall(mData);
                                      }
                                    }, title: mData.status != 1 ? language.enableDocument : language.disableDocument, subtitle: mData.status != 1 ? language.enableDocumentMsg : language.disableDocumentMsg)
                                  : toast(language.youCannotUpdateStatusRecordDeleted);
                            },
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
                                style: primaryTextStyle(color: mData.status == 1 ? primaryColor : Colors.red, size: 14),
                              ),
                            ),
                          ),
                          outlineActionIcon(context, mData.deletedAt == null ? Icons.edit : Icons.restore, Colors.green, () {
                            mData.deletedAt == null
                                ? showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext dialogContext) {
                                      return AddDocumentDialog(
                                        documentData: mData,
                                        onUpdate: () {
                                          currentPage = 1;
                                          getDocumentListApiCall();
                                        },
                                      );
                                    },
                                  )
                                : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                    if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                      toast(language.demoAdminMsg);
                                    } else {
                                      Navigator.pop(context);
                                      restoreDocumentApiCall(id: mData.id, type: RESTORE);
                                    }
                                  }, title: language.restoreDocument, subtitle: language.restoreDocumentMsg);
                          }),
                          SizedBox(width: 8),
                          outlineActionIcon(context, mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, () {
                            commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                              if (sharedPref.getString(USER_TYPE) == DEMO_ADMIN) {
                                toast(language.demoAdminMsg);
                              } else {
                                Navigator.pop(context);
                                mData.deletedAt == null ? deleteDocumentApiCall(mData.id!) : restoreDocumentApiCall(id: mData.id, type: FORCE_DELETE);
                              }
                            }, isForceDelete: mData.deletedAt != null, title: language.deleteDocument, subtitle: language.deleteDocumentMsg);
                          }),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(printDate(mData.createdAt ?? ""), style: secondaryTextStyle()),
                          Spacer(),
                          Text('${language.id}: #${mData.id ?? ""}', style: secondaryTextStyle()),
                        ],
                      ),
                      Visibility(
                          visible: mData.isRequired == 1,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, size: 18, color: primaryColor),
                                SizedBox(width: 4),
                                Text(language.required, style: primaryTextStyle(color: primaryColor)),
                              ],
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
            appStore.isLoading
                ? loaderWidget()
                : documentList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        );
      }),
    );
  }
}
