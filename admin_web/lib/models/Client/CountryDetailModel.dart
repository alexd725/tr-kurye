import '../CountryListModel.dart';

class CountryDetailModel {
  CountryData? data;

  CountryDetailModel({this.data});

  CountryDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new CountryData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
