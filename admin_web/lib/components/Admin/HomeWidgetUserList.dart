import 'package:flutter/material.dart';
import '/../main.dart';
import '/../models/UserModel.dart';
import '/../utils/Colors.dart';
import '/../utils/Common.dart';
import '/../utils/Extensions/text_styles.dart';

class HomeWidgetUserList extends StatefulWidget {
  final List<UserModel> userModel;

  HomeWidgetUserList({required this.userModel});

  @override
  HomeWidgetUserListState createState() => HomeWidgetUserListState();
}

class HomeWidgetUserListState extends State<HomeWidgetUserList> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingTextStyle: boldTextStyle(),
      dataTextStyle: primaryTextStyle(size: 15),
      headingRowColor: MaterialStateColor.resolveWith((states) => primaryColor.withOpacity(0.1)),
      showCheckboxColumn: false,
      dataRowHeight: 45,
      headingRowHeight: 45,
      horizontalMargin: 16,
      columns: [
        DataColumn(label: Text(language.id)),
        DataColumn(label: Text(language.name)),
        DataColumn(label: Text(language.email_id)),
        DataColumn(label: Text(language.city)),
        DataColumn(label: Text(language.register_date)),
      ],
      rows: widget.userModel.map((e) {
        return DataRow(
          cells: [
            DataCell(Text('#${e.id}')),
            DataCell(Text(e.name ?? '-')),
            DataCell(Text(e.email ?? '-')),
            DataCell(Text(e.cityName ?? '-')),
            DataCell(Text(printDate(e.createdAt ?? ""))),
          ],
        );
      }).toList(),
    );
  }
}
