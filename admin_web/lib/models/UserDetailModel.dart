import 'UserModel.dart';

class UserDetailModel {
  UserModel? userDataModel;
  WalletHistory? walletHistory;
  EarningDetail? earningDetail;
  EarningList? earningList;

  UserDetailModel({this.userDataModel, this.walletHistory, this.earningDetail, this.earningList});

  UserDetailModel.fromJson(Map<String, dynamic> json) {
    userDataModel = json['data'] != null ? new UserModel.fromJson(json['data']) : null;
    walletHistory = json['wallet_history'] != null ? new WalletHistory.fromJson(json['wallet_history']) : null;
    earningDetail = json['earning_detail'] != null ? new EarningDetail.fromJson(json['earning_detail']) : null;
    earningList = json['earning_list'] != null ? new EarningList.fromJson(json['earning_list']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userDataModel != null) {
      data['data'] = this.userDataModel!.toJson();
    }
    if (this.walletHistory != null) {
      data['wallet_history'] = this.walletHistory!.toJson();
    }
    if (this.earningDetail != null) {
      data['earning_detail'] = this.earningDetail!.toJson();
    }
    if (this.earningList != null) {
      data['earning_list'] = this.earningList!.toJson();
    }
    return data;
  }
}

class UserDataModel {
  int? id;
  String? name;
  String? email;
  String? username;
  int? status;
  String? userType;
  int? countryId;
  String? countryName;
  int? cityId;
  String? cityName;
  String? address;
  String? contactNumber;
  String? profileImage;
  String? loginType;
  String? latitude;
  String? longitude;
  String? uid;
  String? playerId;
  String? fcmToken;
  String? lastNotificationSeen;
  int? isVerifiedDeliveryMan;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  UserBankAccount? userBankAccount;

  UserDataModel(
      {this.id,
      this.name,
      this.email,
      this.username,
      this.status,
      this.userType,
      this.countryId,
      this.countryName,
      this.cityId,
      this.cityName,
      this.address,
      this.contactNumber,
      this.profileImage,
      this.loginType,
      this.latitude,
      this.longitude,
      this.uid,
      this.playerId,
      this.fcmToken,
      this.lastNotificationSeen,
      this.isVerifiedDeliveryMan,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.userBankAccount});

  UserDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    username = json['username'];
    status = json['status'];
    userType = json['user_type'];
    countryId = json['country_id'];
    countryName = json['country_name'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    address = json['address'];
    contactNumber = json['contact_number'];
    profileImage = json['profile_image'];
    loginType = json['login_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    uid = json['uid'];
    playerId = json['player_id'];
    fcmToken = json['fcm_token'];
    lastNotificationSeen = json['last_notification_seen'];
    isVerifiedDeliveryMan = json['is_verified_delivery_man'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    userBankAccount = json['user_bank_account'] != null ? new UserBankAccount.fromJson(json['user_bank_account']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['username'] = this.username;
    data['status'] = this.status;
    data['user_type'] = this.userType;
    data['country_id'] = this.countryId;
    data['country_name'] = this.countryName;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['address'] = this.address;
    data['contact_number'] = this.contactNumber;
    data['profile_image'] = this.profileImage;
    data['login_type'] = this.loginType;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['uid'] = this.uid;
    data['player_id'] = this.playerId;
    data['fcm_token'] = this.fcmToken;
    data['last_notification_seen'] = this.lastNotificationSeen;
    data['is_verified_delivery_man'] = this.isVerifiedDeliveryMan;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    if (this.userBankAccount != null) {
      data['user_bank_account'] = this.userBankAccount!.toJson();
    }
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

  UserBankAccount({this.id, this.userId, this.bankName, this.bankCode, this.accountHolderName, this.accountNumber, this.createdAt, this.updatedAt, this.deletedAt});

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

class WalletHistory {
  Pagination? pagination;
  List<WalletDataModel>? walletDataModel;

  WalletHistory({this.pagination, this.walletDataModel});

  WalletHistory.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new Pagination.fromJson(json['pagination']) : null;
    // if (json['data'] != null) {
    //   walletDataModel = <WalletDataModel>[];
    //   json['data'].forEach((v) {
    //     walletDataModel!.add(new WalletDataModel.fromJson(v));
    //   });
    // }

      walletDataModel= json['data'] != null ? (json['data'] as List).map((i) => WalletDataModel.fromJson(i)).toList() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.walletDataModel != null) {
      data['data'] = this.walletDataModel!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;

  Pagination({this.totalItems, this.perPage, this.currentPage, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'];
    perPage = json['per_page'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_items'] = this.totalItems;
    data['per_page'] = this.perPage;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class WalletDataModel {
  int? id;
  int? userId;
  String? userName;
  String? type;
  String? transactionType;
  String? currency;
  num? amount;
  num? balance;
  num? walletBalance;
  String? datetime;
  int? orderId;
  String? description;
  Data? data;
  String? createdAt;
  String? updatedAt;

  WalletDataModel(
      {this.id,
      this.userId,
      this.userName,
      this.type,
      this.transactionType,
      this.currency,
      this.amount,
      this.balance,
      this.walletBalance,
      this.datetime,
      this.orderId,
      this.description,
      this.data,
      this.createdAt,
      this.updatedAt});

  WalletDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    type = json['type'];
    transactionType = json['transaction_type'];
    currency = json['currency'];
    amount = json['amount'];
    balance = json['balance'];
    walletBalance = json['wallet_balance'];
    datetime = json['datetime'];
    orderId = json['order_id'];
    description = json['description'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['type'] = this.type;
    data['transaction_type'] = this.transactionType;
    data['currency'] = this.currency;
    data['amount'] = this.amount;
    data['balance'] = this.balance;
    data['wallet_balance'] = this.walletBalance;
    data['datetime'] = this.datetime;
    data['order_id'] = this.orderId;
    data['description'] = this.description;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Data {
  int? paymentId;
  num? tip;

  Data({this.paymentId, this.tip});

  Data.fromJson(Map<String, dynamic> json) {
    paymentId = json['payment_id'];
    tip = json['tip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_id'] = this.paymentId;
    data['tip'] = this.tip;
    return data;
  }
}

class EarningDetail {
  int? id;
  String? name;
  num? walletBalance;
  num? totalWithdrawn;
  num? adminCommission;
  num? deliveryManCommission;
  int? totalOrder;
  int? paidOrder;

  EarningDetail({this.id, this.name, this.walletBalance, this.totalWithdrawn, this.adminCommission, this.deliveryManCommission, this.totalOrder, this.paidOrder});

  EarningDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    walletBalance = json['wallet_balance'];
    totalWithdrawn = json['total_withdrawn'];
    adminCommission = json['admin_commission'];
    deliveryManCommission = json['delivery_man_commission'];
    totalOrder = json['total_order'];
    paidOrder = json['paid_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['wallet_balance'] = this.walletBalance;
    data['total_withdrawn'] = this.totalWithdrawn;
    data['admin_commission'] = this.adminCommission;
    data['delivery_man_commission'] = this.deliveryManCommission;
    data['total_order'] = this.totalOrder;
    data['paid_order'] = this.paidOrder;
    return data;
  }
}

class EarningList {
  Pagination? pagination;
  List<EarningDataModel>? earningDataModel;

  EarningList({this.pagination, this.earningDataModel});

  EarningList.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      earningDataModel = <EarningDataModel>[];
      json['data'].forEach((v) {
        earningDataModel!.add(new EarningDataModel.fromJson(v));
      });
    }


   //earningDataModel= json['data'] != null ? (json['data'] as List).map((i) => EarningDataModel.fromJson(i)).toList() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.earningDataModel != null) {
      data['data'] = this.earningDataModel!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EarningDataModel {
  int? id;
  int? orderId;
  int? clientId;
  String? clientName;
  String? orderStatus;
  String? datetime;
  num? totalAmount;
  String? paymentType;
  String? txnId;
  String? paymentStatus;
  TransactionDetail? transactionDetail;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  num? cancelCharges;
  num? adminCommission;
  String? receivedBy;
  num? deliveryManFee;
  num? deliveryManTip;
  num? deliveryManCommission;

  EarningDataModel(
      {this.id,
      this.orderId,
      this.clientId,
      this.clientName,
      this.orderStatus,
      this.datetime,
      this.totalAmount,
      this.paymentType,
      this.txnId,
      this.paymentStatus,
      this.transactionDetail,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.cancelCharges,
      this.adminCommission,
      this.receivedBy,
      this.deliveryManFee,
      this.deliveryManTip,
      this.deliveryManCommission});

  EarningDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    clientId = json['client_id'];
    clientName = json['client_name'];
    orderStatus = json['order_status'];
    datetime = json['datetime'];
    totalAmount = json['total_amount'];
    paymentType = json['payment_type'];
    txnId = json['txn_id'];
    paymentStatus = json['payment_status'];
  //  transactionDetail = json['transaction_detail'] != null ? new TransactionDetail.fromJson(json['transaction_detail']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    cancelCharges = json['cancel_charges'];
    adminCommission = json['admin_commission'];
    receivedBy = json['received_by'];
    deliveryManFee = json['delivery_man_fee'];
    deliveryManTip = json['delivery_man_tip'];
    deliveryManCommission = json['delivery_man_commission'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['order_status'] = this.orderStatus;
    data['datetime'] = this.datetime;
    data['total_amount'] = this.totalAmount;
    data['payment_type'] = this.paymentType;
    data['txn_id'] = this.txnId;
    data['payment_status'] = this.paymentStatus;
    // if (this.transactionDetail != null) {
    //   data['transaction_detail'] = this.transactionDetail!.toJson();
    // }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['cancel_charges'] = this.cancelCharges;
    data['admin_commission'] = this.adminCommission;
    data['received_by'] = this.receivedBy;
    data['delivery_man_fee'] = this.deliveryManFee;
    data['delivery_man_tip'] = this.deliveryManTip;
    data['delivery_man_commission'] = this.deliveryManCommission;
    return data;
  }
}

class TransactionDetail {
  String? txnId;
  String? description;
  String? paypalPayerId;

  TransactionDetail({this.txnId, this.description, this.paypalPayerId});

  TransactionDetail.fromJson(Map<String, dynamic> json) {
    txnId = json['txn_id'];
    description = json['description'];
    paypalPayerId = json['paypal_payer_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['txn_id'] = this.txnId;
    data['description'] = this.description;
    data['paypal_payer_id'] = this.paypalPayerId;
    return data;
  }
}
