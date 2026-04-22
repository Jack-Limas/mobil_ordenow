import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/utils/constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.openBox(HiveBoxes.settings);
    await Hive.openBox(HiveBoxes.user);
    await Hive.openBox(HiveBoxes.order);
    await Hive.openBox(HiveBoxes.menu);
    await Hive.openBox(HiveBoxes.table);
  }

  static Box get settingsBox => Hive.box(HiveBoxes.settings);

  static Box getUserBox() => Hive.box(HiveBoxes.user);

  static Box getOrderBox() => Hive.box(HiveBoxes.order);

  static Box getMenuBox() => Hive.box(HiveBoxes.menu);

  static Box getTableBox() => Hive.box(HiveBoxes.table);
}
