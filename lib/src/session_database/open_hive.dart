import 'package:hive/hive.dart';

Future<void> openHiveBox() async {
  await Hive.openBox('registerSession');
}
