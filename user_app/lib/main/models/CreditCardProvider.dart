import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../utils/Constants.dart';
import 'CreditCardModel.dart';

class CreditCardProvider with ChangeNotifier {
  List<CreditCard> creditCard = [];

  // Future deleteCreditCard(int id) async {
  //   final res = await http.delete(Uri.parse(mBaseUrl + "deletecard/$id"));
  //   final response = jsonDecode(res.body);
  // }

  Future getCreditCard(int userId) async {
    creditCard.clear();
    final res = await http.get(Uri.parse(mBaseUrl + "creditcard/$userId"));
    final List<dynamic> response = jsonDecode(res.body);
    if (res.statusCode == 200) {
      response.forEach((element) {
        creditCard.add(CreditCard(
            id: element["id"],
            cardholder: element["cardholder"],
            ccv: element["ccv"].toString().toInt(),
            number: element["number"].toString().toInt(),
            userId: userId,
            expiringDate: element["expireddate"]));
      });
    }
    notifyListeners();
  }

  Future addCreditCard(
    String cardholder,
    String expireddate,
    int ccv,
    int cardNumber,
  ) async {
    final res = await http.post(Uri.parse(mBaseUrl + "savecreditcard"),
        body: jsonEncode({
          "cardholder": cardholder,
          "expireddate": expireddate,
          "cvv": ccv,
          "number": cardNumber.toInt(),
          "user_id": getIntAsync(USER_ID),
        }),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          HttpHeaders.cacheControlHeader: 'no-cache',
          HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
        });

    print(res.body);

    notifyListeners();
  }

  Future updateCreditCard(
    String cardholder,
    String expireddate,
    int ccv,
    int cardNumber,
    int cardId,
  ) async {
    final res = await http.put(Uri.parse(mBaseUrl + "updatecard/$cardId"),
        body: jsonEncode({
          "cardholder": cardholder,
          "expireddate": expireddate,
          "ccv": ccv,
          "number": cardNumber.toInt(),
        }),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          HttpHeaders.cacheControlHeader: 'no-cache',
          HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
        });
    print(res.statusCode);
    print(res.body);

    if (res.statusCode == 200) {
      print(res.body);
    } else {
      print(res.body);
    }
    notifyListeners();
  }

  Future deleteCreditCard(
    int cardId,
  ) async {
    final res =
        await http.delete(Uri.parse(mBaseUrl + "deletecard/$cardId"), headers: {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      HttpHeaders.cacheControlHeader: 'no-cache',
      HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
      'Access-Control-Allow-Headers': '*',
      'Access-Control-Allow-Origin': '*',
    });

    if (res.statusCode == 200) {
      print(res.body);
    } else {
      print(res.body);
    }
    notifyListeners();
  }
}
