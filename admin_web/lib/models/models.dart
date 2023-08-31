import 'package:flutter/material.dart';

class MenuItemModel {
  int? index;
  String? imagePath;
  String? title;
  String? route;
  String? subtitle;
  bool? mISCheck;
  Widget? widget;

  MenuItemModel(
      {this.index,
      this.imagePath,
      this.title,
      this.route,
      this.subtitle,
      this.widget,
      this.mISCheck = false});
}

class StaticPaymentModel {
  String? title;
  String? type;

  StaticPaymentModel({@required this.title, @required this.type});
}
