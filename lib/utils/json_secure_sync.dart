import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleep_tracker/logger/logger.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );

/// JSON Local Sync
/// Save and Get a Json [Map<String, dynamic>] from local persistent storage
class JsonSecureSync {
  static final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  /// Save a Json object to local persistent storage
  static Future<bool> save({required String key, required Map<String, dynamic> value}) async {
    try {
      final jsonString = json.encode(value);
      await storage.write(key: key, value: jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get a Json object from local persistent storage
  static Future<Map<String, dynamic>?> get({required String key}) async {
    await tryMigrate(key: key);
    final jsonString = await storage.read(key: key);
    if (jsonString == null) {
      AppLogger.I.i('Unable to read for key: $key');

      return null;
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<bool> delete({required String key}) async {
    try {
      await storage.delete(key: key);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> tryMigrate({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) {
      return;
    }
    final jsonString = prefs.getString(key);
    if (jsonString == null) {
      return;
    }
    await storage.write(key: key, value: jsonString);
    await prefs.remove(key);
    AppLogger.I.d('Migrated $key to KeyChain.');
  }
}
