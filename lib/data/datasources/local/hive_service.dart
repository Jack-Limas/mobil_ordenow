import 'package:hive/hive.dart';

import '../../../core/utils/constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.openBox(HiveBoxes.settings);
  }

  static Box<dynamic> get settingsBox => Hive.box(HiveBoxes.settings);
}
