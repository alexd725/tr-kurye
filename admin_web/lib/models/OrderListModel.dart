import '../models/OrderModel.dart';
import '../models/PaginationModel.dart';
import 'Client/WalletListModel.dart';

class OrderListModel {
  PaginationModel? pagination;
  List<OrderModel>? data;
  int? allUnreadCount;
  UserWalletModel? walletData;


  OrderListModel({this.pagination, this.data, this.allUnreadCount,this.walletData});

  OrderListModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <OrderModel>[];
      json['data'].forEach((v) {
        data!.add(new OrderModel.fromJson(v));
      });
    }
    allUnreadCount = json['all_unread_count'];
    walletData = json['wallet_data'] != null
        ? new UserWalletModel.fromJson(json['wallet_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['all_unread_count'] = this.allUnreadCount;
    if (this.walletData != null) {
      data['wallet_data'] = this.walletData!.toJson();
    }
    return data;
  }
}


