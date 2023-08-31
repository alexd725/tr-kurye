import 'VehicleListModel.dart';

class VehicleResponse {
  VehicleData? vehicleData;

  VehicleResponse(this.vehicleData);

  VehicleResponse.fromJson(Map<String, dynamic> json) {
    vehicleData = json['vehicleData'] != null
        ? new VehicleData.fromJson(json['vehicleData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vehicleData != null) {
      data['data'] = this.vehicleData!.toJson();
    }
    return data;
  }
}
