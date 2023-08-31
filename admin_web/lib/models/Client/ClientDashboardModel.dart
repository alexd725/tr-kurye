import '../../models/Client/WalletListModel.dart';

import '../AppSettingModel.dart';
import '../OrderModel.dart';

class ClientDashboardModel {
  int? totalOrder;
  AppSettingModel? appSetting;
  UserWalletModel? walletData;
  num? totalAmount;
  List<OrderModel>? upcomingOrder;
  int? counts;
  int? allUnreadCount;

  ClientDashboardModel(
      {this.totalOrder,
        this.appSetting,
        this.walletData,
        this.totalAmount,
        this.upcomingOrder,
        this.counts,
        this.allUnreadCount});

  ClientDashboardModel.fromJson(Map<String, dynamic> json) {
    totalOrder = json['total_order'];
    appSetting = json['app_setting'] != null
        ? new AppSettingModel.fromJson(json['app_setting'])
        : null;
    walletData = json['wallet_data'] != null
        ? new UserWalletModel.fromJson(json['wallet_data'])
        : null;
    totalAmount = json['total_amount'];
    if (json['upcoming_order'] != null) {
      upcomingOrder = <OrderModel>[];
      json['upcoming_order'].forEach((v) {
        upcomingOrder!.add(new OrderModel.fromJson(v));
      });
    }
    counts = json['counts'];
    allUnreadCount = json['all_unread_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_order'] = this.totalOrder;
    if (this.appSetting != null) {
      data['app_setting'] = this.appSetting!.toJson();
    }
    if (this.walletData != null) {
      data['wallet_data'] = this.walletData!.toJson();
    }
    data['total_amount'] = this.totalAmount;
    if (this.upcomingOrder != null) {
      data['upcoming_order'] =
          this.upcomingOrder!.map((v) => v.toJson()).toList();
    }
    data['counts'] = this.counts;
    data['all_unread_count'] = this.allUnreadCount;
    return data;
  }
}
