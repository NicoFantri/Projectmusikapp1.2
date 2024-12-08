import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getSharedString(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString(name) ?? "";
}

Future<void> setSharedString(String name, String content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString(name, content);
}

Future<int?> getSharedInt(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getInt(name) ?? 0;
}

Future<void> setSharedInt(String name, int content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setInt(name, content);
}

Future<double?> getSharedDouble(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getDouble(name) ?? 0;
}

Future<void> setSharedDouble(String name, double content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setDouble(name, content);
}

Future<bool?> getSharedBool(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getBool(name) ?? false;
}

Future<void> setSharedBool(String name, bool content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setBool(name, content);
}

Future<List<String>> getSharedListString(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getStringList(name) ?? [];
}

Future<void> setSharedListString(String name, List<String> content) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setStringList(name, content);
}

Future<bool> containShared(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.containsKey(name);
}

Future<void> removeShared(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.remove(name);
}
