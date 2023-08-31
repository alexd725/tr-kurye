import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../utils/Constants.dart';

import '../utils/Extensions/common.dart';
import '../utils/Extensions/network_utils.dart';
import '../utils/Extensions/shared_pref.dart';
import 'RestApis.dart';


Map<String, String> buildHeaderTokens() {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
  };

  if (appStore.isLoggedIn) {
    header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${getStringAsync('TOKEN')}');
  }
  log(jsonEncode(header));
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http')) url = Uri.parse('$mBaseUrl$endPoint');

  log('URL: ${url.toString()}');

  return url;
}

Future<Response> buildHttpResponse(String endPoint, {HttpMethod method = HttpMethod.GET, Map? request}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens();
    Uri url = buildBaseUrl(endPoint);

    try {
      Response response;

      if (method == HttpMethod.POST) {
        log('Request: $request');

        response = await http.post(url, body: jsonEncode(request), headers: headers).timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
      } else if (method == HttpMethod.DELETE) {
        response = await delete(url, headers: headers).timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
      } else if (method == HttpMethod.PUT) {
        response = await put(url, body: jsonEncode(request), headers: headers).timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
      } else {
        response = await get(url, headers: headers).timeout(Duration(seconds: 20), onTimeout: () => throw 'Timeout');
      }

      log('Response ($method): ${url.toString()} ${response.statusCode} ${response.body}');

      return response;
    } catch (e) {
      throw language.somethingWentWrong;
    }
  } else {
    throw language.internetNotWorking;
  }
}

//region Common

Future handleResponse(Response response, [bool? avoidTokenError]) async {
  if (!await isNetworkAvailable()) {
    throw language.internetNotWorking;
  }
  if (response.statusCode == 401) {
    if (appStore.isLoggedIn) {
      Map req = {
        'email': getStringAsync(USER_EMAIL),
        'password': getStringAsync(USER_PASSWORD),
      };

      await logInApi(req).then((value) {
        throw language.tryAgain;
      }).catchError((e) {
        throw TokenException(e);
      });
    } else {
      throw '';
    }
  }

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    try {
      var body = jsonDecode(response.body);
      throw parseHtmlString(body['message']);
    } on Exception catch (e) {
      log(e);
      throw language.somethingWentWrong;
    }
  }
}

enum HttpMethod { GET, POST, DELETE, PUT }

class TokenException implements Exception {
  final String message;

  const TokenException([this.message = ""]);

  String toString() => "FormatException: $message";
}
