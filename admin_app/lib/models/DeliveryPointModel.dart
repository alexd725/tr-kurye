class DeliveryPointModel {
  String? address;
  String? contactNumber;
  String? startTime;
  String? description;
  String? latitude;
  String? longitude;

  DeliveryPointModel({
    this.address,
    this.contactNumber,
    this.startTime,
    this.description,
    this.latitude,
    this.longitude,
  });

  factory DeliveryPointModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPointModel(
      address: json['address'],
      contactNumber: json['contact_number'],
      startTime: json['start_time'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['start_time'] = this.startTime;
    data['description'] = this.description;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
