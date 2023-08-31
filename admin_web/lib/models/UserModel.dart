class UserModel {
  int? id;
  String? name;
  String? email;
  String? id_no;
  String? car_or_moto;
  String? plate_number;
  String? tax_office;
  String? tax_number;
  String? username;
  String? emailVerifiedAt;
  String? address;
  String? contactNumber;
  String? userType;
  int? countryId;
  int? cityId;
  String? playerId;
  String? lastNotificationSeen;
  int? status;
  int? currentTeamId;
  String? profilePhotoPath;
  String? createdAt;

  String? createdAtYear;
  String? createdAtMonth;
  String? updatedAt;
  String? deletedAt;
  String? apiToken;
  String? profileImage;
  String? profilePhotoUrl;
  String? countryName;
  String? cityName;
  String? loginType;
  int? isVerifiedDeliveryMan;
  String? fcmToken;
  String? latitude;
  String? longitude;
  String? idNo;
  List? orderAmount;
  String? amount;
  UserBankAccount? userBankAccount;
  String? uid;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.id_no,
    this.car_or_moto,
    this.plate_number,
    this.tax_office,
    this.tax_number,
    this.username,
    this.emailVerifiedAt,
    this.address,
    this.contactNumber,
    this.userType,
    this.countryId,
    this.cityId,
    this.playerId,
    this.lastNotificationSeen,
    this.status,
    this.currentTeamId,
    this.profilePhotoPath,
    this.createdAt,
    this.createdAtYear,
    this.createdAtMonth,
    this.updatedAt,
    this.deletedAt,
    this.apiToken,
    this.profileImage,
    this.profilePhotoUrl,
    this.countryName,
    this.cityName,
    this.loginType,
    this.isVerifiedDeliveryMan,
    this.fcmToken,
    this.latitude,
    this.longitude,
    this.idNo,
    this.orderAmount,
    this.amount,
    this.userBankAccount,
    this.uid,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    id_no = json['id_no'];
    car_or_moto = json['car_or_moto'];
    plate_number = json['plate_number'];
    tax_office = json['tax_office'];
    tax_number = json['tax_number'];
    username = json['username'];
    emailVerifiedAt = json['email_verified_at'];
    address = json['address'];
    contactNumber = json['contact_number'];
    userType = json['user_type'];
    countryId = json['country_id'];
    cityId = json['city_id'];
    playerId = json['player_id'];
    lastNotificationSeen = json['last_notification_seen'];
    status = json['status'];
    currentTeamId = json['current_team_id'];
    profilePhotoPath = json['profile_photo_path'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    apiToken = json['api_token'];
    profileImage = json['profile_image'];
    profilePhotoUrl = json['profile_photo_url'];
    countryName = json['country_name'];
    cityName = json['city_name'];
    loginType = json['login_type'];
    isVerifiedDeliveryMan = json['is_verified_delivery_man'];
    fcmToken = json['fcm_token'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    userBankAccount = json['user_bank_account'] != null
        ? new UserBankAccount.fromJson(json['user_bank_account'])
        : null;
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['id_no'] = this.id_no;
    data['car_or_moto'] = this.car_or_moto;
    data['plate_number'] = this.plate_number;
    data['tax_office'] = this.tax_office;
    data['tax_number'] = this.tax_number;
    data['username'] = this.username;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['user_type'] = this.userType;
    data['country_id'] = this.countryId;
    data['city_id'] = this.cityId;
    data['player_id'] = this.playerId;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['status'] = this.status;
    data['current_team_id'] = this.currentTeamId;
    data['profile_photo_path'] = this.profilePhotoPath;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['api_token'] = this.apiToken;
    data['profile_image'] = this.profileImage;
    data['profile_photo_url'] = this.profilePhotoUrl;
    data['country_name'] = this.countryName;
    data['city_name'] = this.cityName;
    data['login_type'] = this.loginType;
    data['is_verified_delivery_man'] = this.isVerifiedDeliveryMan;
    data['fcm_token'] = this.fcmToken;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    if (this.userBankAccount != null) {
      data['user_bank_account'] = this.userBankAccount!.toJson();
    }
    data['uid'] = this.uid;
    return data;
  }
}

class UserBankAccount {
  int? id;
  int? userId;
  String? bankName;
  String? bankCode;
  String? accountHolderName;
  String? accountNumber;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  UserBankAccount(
      {this.id,
      this.userId,
      this.bankName,
      this.bankCode,
      this.accountHolderName,
      this.accountNumber,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  UserBankAccount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
    accountHolderName = json['account_holder_name'];
    accountNumber = json['account_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['bank_name'] = this.bankName;
    data['bank_code'] = this.bankCode;
    data['account_holder_name'] = this.accountHolderName;
    data['account_number'] = this.accountNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
