import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../components/AddButtonComponent.dart';
import '../../components/Admin/AddDocumentDialog.dart';
import '../../components/Admin/BodyCornerWidget.dart';
import '../../components/PaginationWidget.dart';
import '../../components/CommonConfirmationDialog.dart';
import '/../models/DocumentListModel.dart';
import '/../network/RestApis.dart';
import '/../main.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import '../../utils/ResponsiveWidget.dart';
import '/../utils/Extensions/common.dart';
import '/../utils/Extensions/constants.dart';
import '/../utils/Extensions/shared_pref.dart';
import '/../utils/Extensions/text_styles.dart';


class DocumentScreen extends StatefulWidget {
  static String route = '/admin/documents';

  @override
  DocumentScreenState createState() => DocumentScreenState();
}

class DocumentScreenState extends State<DocumentScreen> {
  ScrollController horizontalScrollController = ScrollController();

  int currentPage = 1;
  int totalPage = 1;
  int perPage = 10;

  List<DocumentData> documentList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setSelectedMenuIndex(DOCUMENT_INDEX);
    getDocumentListApiCall();
  }

  // Document List
  getDocumentListApiCall() async {
    appStore.setLoading(true);
    await getDocumentList(page: currentPage, isDeleted: true, perPage: perPage).then((value) {
      appStore.setLoading(false);

      totalPage = value.pagination!.totalPages!;
      currentPage = value.pagination!.currentPage!;

      documentList.clear();
      documentList.addAll(value.data!);
      if (currentPage != 1 && documentList.isEmpty) {
        currentPage -= 1;
        getDocumentListApiCall();
      }
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

    Widget addDocumentButton() {
      return AddButtonComponent(language.add_document, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AddDocumentDialog(
              onUpdate: () {
                getDocumentListApiCall();
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
                            Text(language.document, style: boldTextStyle(size: 20, color: primaryColor)),
                            addDocumentButton(),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.document, style: boldTextStyle(size: 20, color: primaryColor)),
                            addDocumentButton(),
                          ],
                        ),
                  documentList.isNotEmpty
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
                                          DataColumn(label: Text(language.required)),
                                          DataColumn(label: Text(language.created)),
                                          DataColumn(label: Text(language.status)),
                                          DataColumn(label: Text(language.actions)),
                                        ],
                                        rows: documentList.map((mData) {
                                          return DataRow(cells: [
                                            DataCell(Text('${mData.id}')),
                                            DataCell(Text('${mData.name ?? "-"}')),
                                            DataCell(Text('${mData.isRequired == 1 ? language.yes : language.no}')),
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
                                                      }, title: mData.status != 1 ? language.enable_document : language.disable_document, subtitle: mData.status != 1 ? language.enable_document_msg : language.disable_document_msg)
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
                                                              return AddDocumentDialog(
                                                                documentData: mData,
                                                                onUpdate: () {
                                                                  getDocumentListApiCall();
                                                                },
                                                              );
                                                            },
                                                          )
                                                        : commonConfirmationDialog(context, DIALOG_TYPE_RESTORE, () {
                                                            if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                              toast(language.demo_admin_msg);
                                                            } else {
                                                              Navigator.pop(context);
                                                              restoreDocumentApiCall(id: mData.id, type: RESTORE);
                                                            }
                                                          }, title: language.restore_document, subtitle: language.restore_document_msg);
                                                  }),
                                                  SizedBox(width: 8),
                                                  outlineActionIcon(mData.deletedAt == null ? Icons.delete : Icons.delete_forever, Colors.red, '${mData.deletedAt == null ? language.delete : language.force_delete}', () {
                                                    commonConfirmationDialog(context, DIALOG_TYPE_DELETE, () {
                                                      if (getStringAsync(USER_TYPE) == DEMO_ADMIN) {
                                                        toast(language.demo_admin_msg);
                                                      } else {
                                                        Navigator.pop(context);
                                                        mData.deletedAt == null ? deleteDocumentApiCall(mData.id!) : restoreDocumentApiCall(id: mData.id, type: FORCE_DELETE);
                                                      }
                                                    }, isForceDelete: mData.deletedAt != null, title: language.delete_document, subtitle: language.delete_document_msg);
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
                              getDocumentListApiCall();
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
                : documentList.isEmpty
                    ? emptyWidget()
                    : SizedBox(),
          ],
        ),
      );
    });
  }
}
