class OrderHistoryModel {
  String? createdAt;
  String? datetime;
  String? deletedAt;
  HistoryData? historyData;
  String? historyMessage;
  String? historyType;
  int? id;
  int? orderId;
  String? updatedAt;

  OrderHistoryModel({
    this.createdAt,
    this.datetime,
    this.deletedAt,
    this.historyData,
    this.historyMessage,
    this.historyType,
    this.id,
    this.orderId,
    this.updatedAt,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      createdAt: json['created_at'],
      datetime: json['datetime'],
      deletedAt: json['deleted_at'],
      historyData: json['history_data'] != null ? HistoryData.fromJson(json['history_data']) : null,
      historyMessage: json['history_message'],
      historyType: json['history_type'],
      id: json['id'],
      orderId: json['order_id'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.createdAt;
    data['datetime'] = this.datetime;
    data['deleted_at'] = this.deletedAt;
    data['history_message'] = this.historyMessage;
    data['history_type'] = this.historyType;
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['updated_at'] = this.updatedAt;
    if (this.historyData != null) {
      data['history_data'] = this.historyData!.toJson();
    }
    return data;
  }
}

class HistoryData {
  var clientId;
  String? clientName;
  var deliveryManId;
  String? deliveryManName;
  var orderId;
  String? paymentStatus;

  HistoryData({this.clientId, this.clientName, this.deliveryManName});

  HistoryData.fromJson(Map<String, dynamic> json) {
    clientId = json['client_id'];
    clientName = json['client_name'];
    deliveryManId = json['delivery_man_id'];
    deliveryManName = json['delivery_man_name'];
    orderId = json['order_id'];
    paymentStatus = json['payment_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['delivery_man_id'] = this.deliveryManId;
    data['delivery_man_name'] = this.deliveryManName;
    data['order_id'] = this.orderId;
    data['payment_status'] = this.paymentStatus;
    return data;
  }
}
