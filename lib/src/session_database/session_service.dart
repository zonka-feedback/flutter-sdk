
import 'package:hive/hive.dart';
import 'package:zonkafeedback_sdk/src/session_database/sessions.dart';
import '../data_manager.dart';
import '../utils/app_util.dart';

class SessionService {
  static final SessionService _singleton = SessionService._internal();

  factory SessionService() {
    return _singleton;
  }

  SessionService._internal();

  Future<void> sessionStarted() async {
    var box = await Hive.openBox('registerSession');
    int startTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    String id = "ad-$startTime${AppUtils.instance.getCookieId(14)}";
    Sessions sessions = Sessions(id: id, startTime: startTime, endTime: 0);
    box.add(sessions);
  }

  Future<void> sessionEnded() async {
    var box = await Hive.openBox('registerSession');
    int endTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    if (box.keys.isNotEmpty) {
      int lastKey = box.keys.last as int;
      Sessions? sessions = box.get(lastKey);

      if (sessions != null) {
        sessions.endTime = endTime;
        box.put(lastKey, sessions);
      } else {

      }
    } else {

    }
  }

  Future<void> sessionListPrint() async {
    var box = await Hive.openBox('registerSession');

    if (box.isNotEmpty) {
      print("Session List:");
      box.values.forEach((session) {
        if (session is Sessions) {
          print("Session ID: ${session.id}, Start Time: ${session.startTime}, End Time: ${session.endTime}");
        }
      });
    } else {
      print("No sessions available.");
    }
  }

  Future<void> syncSessionServer(String token) async {
    // Open the Hive box
    var box = await Hive.openBox('registerSession');
    // Check if the box has any data
    if (box.isNotEmpty) {
      // Convert box values to a list of Sessions
      List<Sessions> sessions = box.values.whereType<Sessions>().toList();
      await DataManager().updateSessionToServer(token, sessions);
      box.clear();
    } else {

    }
  }

  Future<void> clearSession() async {
    var box = await Hive.openBox('registerSession');
    box.clear();
  }


}