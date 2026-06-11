import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Settings? _instance;
  final SharedPreferences _prefs;
  final String _storagePath;
  final String? _downloadPath;


  bool get sound {
    return _prefs.getBool('sound') ?? true;
  }

  void set sound(bool value) {
    _prefs.setBool('sound', value);
  }

  bool get haptic {
    return _prefs.getBool('haptic') ?? true;
  }

  void set haptic(bool value) {
    _prefs.setBool('haptic', value);
  }

  bool get developer {
    return _prefs.getBool('dev') ?? false;
  }

  void set developer(bool value) {
    _prefs.setBool('dev', value);
  }

  bool get isDeveloperUnlocked {
    return _prefs.getBool('devUnlocked') ?? false;
  }

  void set isDeveloperUnlocked(bool value) {
    _prefs.setBool('devUnlocked', value);
  }

  bool getLoaded(String name) {
    return _prefs.getBool(name) ?? false;
  }

  void setLoaded(String name) {
    _prefs.setBool(name, true);
  }

  void setComplete(String hash) {
    List<String> completed = _prefs.getStringList('complete') ?? [];
    if (!completed.contains(hash)) {
      completed.add(hash);
      _prefs.setStringList('complete', completed);
    }
  }

  bool isComplete(String hash) {
    return (_prefs.getStringList('complete') ?? []).contains(hash);
  }

  void clearComplete() {
    _prefs.remove('complete');
  }

  String get storagePath {
    return _storagePath;
  }

  String? get downloadPath {
    return _downloadPath;
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

      String? downloadPath;
      if (Platform.isAndroid) {
        final List<Directory>? externalDirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (externalDirs != null && externalDirs.isNotEmpty) {
          downloadPath = externalDirs.first.path;
        } else {
          // Fallback to a common path if getExternalStorageDirectories fails
          downloadPath = "/storage/emulated/0/Download";
        }
      } else {
        Directory? downloadDirectory = await getDownloadsDirectory();
        downloadPath = downloadDirectory?.path;
      }

      Directory storageDirectory = Directory('${appStorage.path}/thex');
      if (!(await storageDirectory.exists())) {
        await storageDirectory.create();
      }
      _instance = Settings._(sharedPreferences, storageDirectory.path, downloadPath);
    }
    return _instance!;
  }

  Settings._(SharedPreferences sharedPreferences, String storagePath, String? downloadPath)
      : _prefs = sharedPreferences, _storagePath = storagePath, _downloadPath = downloadPath;

  Future<void> reset() async {
    await _prefs.clear();
    developer = false;
    isDeveloperUnlocked = false;
    haptic = true;
    clearComplete();
  }
}