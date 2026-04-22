import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox('user');
    await Hive.openBox('order');
    await Hive.openBox('menu');
    await Hive.openBox('table');
  }

  static Box getUserBox() => Hive.box('user');

  static Box getOrderBox() => Hive.box('order');

  static Box getMenuBox() => Hive.box('menu');

  static Box getTableBox() => Hive.box('table');
}