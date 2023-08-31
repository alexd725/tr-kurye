import 'dart:convert';
import 'dart:developer';
import '../../utils/Extensions/string_extensions.dart';
import '../../utils/Extensions/bool_extensions.dart';
import '../../utils/Extensions/double_extensions.dart';
import '../../utils/Extensions/int_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';


/// Returns SharedPref Instance
Future<SharedPreferences> getSharedPref() async {
  return await SharedPreferences.getInstance();
}

/// Add a value in SharedPref based on their type - Must be a String, int, bool, double, Map<String, dynamic> or StringList
Future<bool> setValue(String key, dynamic value, {bool print = true}) async {
  if (print) log('${value.runtimeType} - $key - $value');

  if (value is String) {
    return await sharedPref.setString(key, value.validate());
  } else if (value is int) {
    return await sharedPref.setInt(key, value.validate());
  } else if (value is bool) {
    return await sharedPref.setBool(key, value.validate());
  } else if (value is double) {
    return await sharedPref.setDouble(key, value.validate());
  } else if (value is Map<String, dynamic>) {
    return await sharedPref.setString(key, jsonEncode(value));
  } else if (value is List<String>) {
    return await sharedPref.setStringList(key, value);
  } else {
    throw ArgumentError('Invalid value ${value.runtimeType} - Must be a String, int, bool, double, Map<String, dynamic> or StringList');
  }
}

/// Returns List of Keys that matches with given Key
List<String> getMatchingSharedPrefKeys(String key) {
  List<String> keys = [];

  sharedPref.getKeys().forEach((element) {
    if (element.contains(key)) {
      keys.add(element);
    }
  });

  return keys;
}

/// Returns a StringList if exists in SharedPref
List<String>? getStringListAsync(String key) {
  return sharedPref.getStringList(key);
}


/// Returns a Bool if exists in SharedPref
bool getBoolAsync(String key, {bool defaultValue = false}) {
  return sharedPref.getBool(key) ?? defaultValue;
}

/// Returns a Double if exists in SharedPref
double getDoubleAsync(String key, {double defaultValue = 0.0}) {
  return sharedPref.getDouble(key) ?? defaultValue;
}

/// Returns a Int if exists in SharedPref
int getIntAsync(String key, {int defaultValue = 0}) {
  return sharedPref.getInt(key) ?? defaultValue;
}

/// Returns a String if exists in SharedPref
String getStringAsync(String key, {String defaultValue = ''}) {
  return sharedPref.getString(key) ?? defaultValue;
}

/// Returns a JSON if exists in SharedPref
Map<String, dynamic> getJSONAsync(String key, {Map<String, dynamic>? defaultValue}) {
  if (sharedPref.containsKey(key) && sharedPref.getString(key).validate().isNotEmpty) {
    return jsonDecode(sharedPref.getString(key)!);
  } else {
    return defaultValue ?? {};
  }
}

/// remove key from SharedPref
Future<bool> removeKey(String key) async {
  return await sharedPref.remove(key);
}

/// clear SharedPref
Future<bool> clearSharedPref() async {
  return await sharedPref.clear();
}

/////////////////////////////////////////////////////////////////////// DEPRECATED \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

/// add a Double in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setDoubleAsync(String key, double value) async {
  return await sharedPref.setDouble(key, value);
}

/// add a Bool in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setBoolAsync(String key, bool value) async {
  return await sharedPref.setBool(key, value);
}

/// add a Int in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setIntAsync(String key, int value) async {
  return await sharedPref.setInt(key, value);
}

/// add a String in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setStringAsync(String key, String value) async {
  return await sharedPref.setString(key, value);
}

/// add a JSON in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setJSONAsync(String key, String value) async {
  return await sharedPref.setString(key, jsonEncode(value));
}

/// Returns a String if exists in SharedPref
@Deprecated('Use getStringAsync instead without using await')
Future<String> getString(String key, {defaultValue = ''}) async {
  return await getSharedPref().then((pref) {
    return pref.getString(key) ?? defaultValue;
  });
}

/// Returns a Int if exists in SharedPref
@Deprecated('Use getIntAsync instead without using await')
Future<int> getInt(String key, {defaultValue = 0}) async {
  return await getSharedPref().then((pref) {
    return pref.getInt(key) ?? defaultValue;
  });
}

/// Returns a Double if exists in SharedPref
@Deprecated('Use getDoubleAsync instead without using await')
Future<double> getDouble(String key, {defaultValue = 0.0}) async {
  return await getSharedPref().then((pref) {
    return pref.getDouble(key) ?? defaultValue;
  });
}

/// Returns a Bool if exists in SharedPref
@Deprecated('Use getBoolAsync instead without using await')
Future<bool> getBool(String key, {defaultValue = false}) async {
  return await getSharedPref().then((pref) {
    return pref.getBool(key) ?? defaultValue;
  });
}

/// add a String in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setString(String key, String value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setString(key, value);
  });
}

/// add a Int in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setInt(String key, int value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setInt(key, value);
  });
}

/// add a Bool in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setBool(String key, bool value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setBool(key, value);
  });
}

/// add a Double in SharedPref
@Deprecated('Use setValue instead')
Future<bool> setDouble(String key, double value) async {
  return await getSharedPref().then((pref) async {
    return await pref.setDouble(key, value);
  });
}
