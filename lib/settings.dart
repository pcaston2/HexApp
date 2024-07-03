import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Settings? _instance;
  final SharedPreferences _prefs;
  final String _storagePath;


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

  bool getLoaded(String name) {
    return _prefs.getBool(name) ?? false;
  }

  void setLoaded(String name) {
    _prefs.setBool(name, true);
  }

  String get storagePath {
    return _storagePath;
  }

  String get board {
    return _prefs.getString("board") ?? "Base Case";
  }

  String get flow {
    return _prefs.getString("flow") ?? "Trace Route";
  }

  String get story {
    return _prefs.getString("story") ?? "Hot Path";
  }

  static Future<Settings> getInstance() async {
    if (_instance == null) {
      final sharedPreferences = await SharedPreferences.getInstance();
      Directory appStorage = await getApplicationDocumentsDirectory();
      Directory storageDirectory = Directory('${appStorage.path}/thex');
      if (!(await storageDirectory.exists())) {
        await storageDirectory.create();
      }
      _instance = Settings._(sharedPreferences, storageDirectory.path);
    }
    return _instance!;
  }

  Settings._(SharedPreferences sharedPreferences, String storagePath)
      : _prefs = sharedPreferences, _storagePath = storagePath;

  Future<void> reset() async {
    await _prefs.clear();
  }
}