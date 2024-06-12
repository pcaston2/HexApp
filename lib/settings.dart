import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Settings? _instance;
  final SharedPreferences _prefs;


  bool get sound {
    return _prefs.getBool('sound') ?? true;
  }

  void set sound(bool value) {
    _prefs.setBool('sound', value);
  }

  bool get developer {
    return _prefs.getBool('dev') ?? false;
  }

  void set developer(bool value) {
    _prefs.setBool('dev', value);
  }

  static Future<Settings> getInstance() async {
    if (_instance == null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      _instance = Settings._(sharedPreferences);
    }
    return _instance!;
  }

  Settings._(SharedPreferences sharedPreferences)
      : _prefs = sharedPreferences;
}