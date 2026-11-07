import 'package:hive_flutter/hive_flutter.dart';

class CacheHive {
  static late Box box;

  //! Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('appBox');
  }

  //! Get String data
  static String? getDataString({required String key}) {
    return box.get(key);
  }

  //! Save data
  static Future<void> saveData({
    required String key,
    required dynamic value,
  }) async {
    await box.put(key, value);
  }

  //! Get data
  static dynamic getData({required String key}) {
    return box.get(key);
  }

  //! Remove data
  static Future<void> removeData({required String key}) async {
    await box.delete(key);
  }

  //! Check if key exists
  static bool containsKey({required String key}) {
    return box.containsKey(key);
  }

  //! Get all keys
  static Iterable<dynamic> getAllKeys() {
    return box.keys;
  }

  //! Clear all data
  static Future<void> clearData() async {
    await box.clear();
  }

  //! Put data
  static Future<void> put({required String key, required dynamic value}) async {
    await box.put(key, value);
  }
}
