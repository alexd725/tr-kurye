class CreditCard {
  final int id;
  final String cardholder;
  final int ccv;
  final int number;
  final int userId;
  final String expiringDate;

  CreditCard(
      {required this.id,
      required this.cardholder,
      required this.ccv,
      required this.number,
      required this.userId,
      required this.expiringDate});

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
        id: json['id'],
        cardholder: json["cardholder"],
        ccv: json["ccv"],
        number: json["number"],
        userId: json["user_id"],
        expiringDate: json["expireddate"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data["cardholder"] = this.cardholder;
    data["ccv"] = this.ccv;
    data["number"] = this.number;
    data['userId'] = this.userId;
    data["expireddate"] = this.expiringDate;
    return data;
  }
}
