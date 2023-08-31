class WithDrawModel {
  Pagination? pagination;
  List<WithdrawResponse>? data;
  String? walletBalance;

  WithDrawModel({this.pagination, this.data, this.walletBalance});

  WithDrawModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <WithdrawResponse>[];
      json['data'].forEach((v) {
        data!.add(new WithdrawResponse.fromJson(v));
      });
    }
    walletBalance = json['wallet_balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['wallet_balance'] = this.walletBalance;
    return data;
  }
}

class Pagination {
  int? totalItems;
  String? perPage;
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

class WithdrawResponse {
  int? id;
  int? userId;
  String? userName;
  int? amount;
  String? currency;
  String? status;
  var walletBalance;
  String? createdAt;
  String? updatedAt;

  WithdrawResponse({this.id, this.userId, this.userName, this.amount, this.currency, this.status, this.walletBalance, this.createdAt, this.updatedAt});

  WithdrawResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userName = json['user_name'];
    amount = json['amount'];
    currency = json['currency'];
    status = json['status'];
    walletBalance = json['wallet_balance'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['status'] = this.status;
    data['wallet_balance'] = this.walletBalance;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
