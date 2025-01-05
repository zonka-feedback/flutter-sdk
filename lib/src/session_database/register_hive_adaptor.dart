


import 'package:hive/hive.dart';
import 'sessions.dart';


Future<void> registerHiveAdaptor() async {
  if (!Hive.isAdapterRegistered(SessionsAdapter().typeId)) {
    Hive.registerAdapter(SessionsAdapter());
  }
}