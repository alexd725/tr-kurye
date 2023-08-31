import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/Extensions/text_styles.dart';

Widget paginationWidget(BuildContext context, {required int currentPage, required int totalPage, int perPage = 10, bool? isPerpage = true, required Function(int currentPage, int perPage) onUpdate}) {
  List<int> perPageList = [5, 10, 25, 50, 100, -1];
  return Align(
    alignment: AlignmentDirectional.bottomEnd,
    child: Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        if (isPerpage != false)
          Container(
            height: 40,
            decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
            padding: EdgeInsets.only(left: 12, right: 12),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(language.perPage, style: primaryTextStyle()),
                  SizedBox(width: 12),
                  VerticalDivider(),
                  SizedBox(width: 12),
                  DropdownButton<int>(
                      underline: SizedBox(),
                      focusColor: Colors.transparent,
                      style: primaryTextStyle(),
                      dropdownColor: Theme.of(context).cardColor,
                      value: perPage,
                      items: List.generate(perPageList.length, (index) {
                        int item = perPageList[index];
                        return DropdownMenuItem(child: Text(item == -1 ? language.all : '$item'), value: item);
                      }),
                      onChanged: (value) {
                        currentPage = 1;
                        perPage = value!;
                        onUpdate.call(currentPage, perPage);
                      }),
                ],
              ),
            ),
          ),
        Container(
          height: 40,
          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor)),
          padding: EdgeInsets.only(left: 12, right: 12),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${language.page} $currentPage ${language.lbl_of} $totalPage', style: primaryTextStyle()),
                SizedBox(width: 12),
                VerticalDivider(),
                SizedBox(width: 12),
                DropdownButton<int>(
                    underline: SizedBox(),
                    focusColor: Colors.transparent,
                    value: currentPage,
                    style: primaryTextStyle(),
                    dropdownColor: Theme.of(context).cardColor,
                    items: List.generate(totalPage, (index) {
                      return DropdownMenuItem(child: Text('${index + 1}'), value: index + 1);
                    }),
                    onChanged: (value) {
                      currentPage = value!;
                      onUpdate.call(currentPage, perPage);
                    }),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
