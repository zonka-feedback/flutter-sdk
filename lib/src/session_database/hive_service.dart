import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:zonkafeedback_sdk/src/session_database/register_hive_adaptor.dart';
import 'open_hive.dart';

class HiveService {
  static final HiveService _hiveService = HiveService._internal();

  HiveService._internal();

  factory HiveService() {
    return _hiveService;
  }

  Future<void> init() async {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    await registerHiveAdaptor();
    await openHiveBox();
  }
}
