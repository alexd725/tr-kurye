import '../models/ExtraChragesListModel.dart';
import 'CountryListModel.dart';
import 'PaginationModel.dart';

class CityListModel {
  PaginationModel? pagination;
  List<CityData>? data;

  CityListModel({this.pagination, this.data});

  CityListModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null
        ? new PaginationModel.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <CityData>[];
      json['data'].forEach((v) {
        data!.add(new CityData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CityData {
  int? id;
  String? name;
  String? address;
  int? countryId;
  String? countryName;
  String? vehicle_type;
  String? order_type;
  Country? country;
  int? status;
  num? fixedCharges;
  List<ExtraChargesData>? extraCharges;
  num? cancelCharges;
  num? minDistance;
  double? maxDistance;
  double? maxWeight;
  num? minWeight;
  num? perDistanceCharges;
  num? perWeightCharges;
  double? chargePerAddress;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? commissionType;
  num? adminCommission;
  bool isCheck = false;

  CityData({
    this.id,
    this.name,
    this.address,
    this.countryId,
    this.countryName,
    this.vehicle_type,
    this.order_type,
    this.country,
    this.status,
    this.fixedCharges,
    this.extraCharges,
    this.cancelCharges,
    this.minDistance,
    this.maxWeight,
    this.maxDistance,
    this.minWeight,
    this.perDistanceCharges,
    this.perWeightCharges,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.chargePerAddress,
    this.commissionType,
    this.adminCommission,
    this.isCheck = false,
  });

  CityData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    vehicle_type = json['vehicle_type'];
    order_type = json['order_type'];
    country =
        json['country'] != null ? new Country.fromJson(json['country']) : null;
    status = json['status'];
    fixedCharges = json['fixed_charges'];
    if (json['extra_charges'] != null) {
      extraCharges = <ExtraChargesData>[];
      json['extra_charges'].forEach((v) {
        extraCharges!.add(new ExtraChargesData.fromJson(v));
      });
    }
    cancelCharges = json['cancel_charges'];
    minDistance = json['min_distance'];
    maxDistance = json['max_distance'];
    maxWeight = json['max_weight'];
    minWeight = json['min_weight'];
    perDistanceCharges = json['per_distance_charges'];
    perWeightCharges = json['per_weight_charges'];
    chargePerAddress = json['charge_per_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    commissionType = json['commission_type'];
    adminCommission = json['admin_commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    data['vehicle_type'] = this.vehicle_type;
    data['order_type'] = this.order_type;
    data['status'] = this.status;
    data['fixed_charges'] = this.fixedCharges;
    if (this.extraCharges != null) {
      data['extra_charges'] =
          this.extraCharges!.map((v) => v.toJson()).toList();
    }
    data['cancel_charges'] = this.cancelCharges;
    data['min_distance'] = this.minDistance;
    data['min_weight'] = this.minWeight;
    data['max_distance'] = this.maxDistance;
    data['max_weight'] = this.maxWeight;
    data['per_distance_charges'] = this.perDistanceCharges;
    data['per_weight_charges'] = this.perWeightCharges;
    data['charge_per_address'] = this.chargePerAddress;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['commission_type'] = this.commissionType;
    data['admin_commission'] = this.adminCommission;
    return data;
  }
}

class Country {
  int? id;
  String? name;
  String? code;
  String? distanceType;
  String? weightType;
  String? links;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Country(
      {this.id,
      this.name,
      this.code,
      this.distanceType,
      this.weightType,
      this.links,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    distanceType = json['distance_type'];
    weightType = json['weight_type'];
    links = json['links'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['distance_type'] = this.distanceType;
    data['weight_type'] = this.weightType;
    data['links'] = this.links;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class ExtraCharges {
  int? id;
  String? title;
  String? chargesType;
  int? charges;
  int? countryId;
  int? cityId;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  ExtraCharges(
      {this.id,
      this.title,
      this.chargesType,
      this.charges,
      this.countryId,
      this.cityId,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  ExtraCharges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    chargesType = json['charges_type'];
    charges = json['charges'];
    countryId = json['country_id'];
    cityId = json['city_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['charges_type'] = this.chargesType;
    data['charges'] = this.charges;
    data['country_id'] = this.countryId;
    data['city_id'] = this.cityId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
