import 'package:zonkafeedback_sdk/src/session_database/sessions.dart';
import '../data_manager.dart';
import '../utils/app_util.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class SessionService {
  static final SessionService _singleton = SessionService._internal();

  factory SessionService() {
    return _singleton;
  }

  SessionService._internal();

  static const String _sessionKey = 'registerSession';

  Future<void> sessionStarted() async {
    final prefs = await SharedPreferences.getInstance();
    int startTime = DateTime.now().toUtc().millisecondsSinceEpoch;
    String id = "ad-$startTime${AppUtils.instance.getCookieId(14)}";
    Sessions session = Sessions(id: id, startTime: startTime, endTime: 0);

    List<String> sessions = prefs.getStringList(_sessionKey) ?? [];
    sessions.add(jsonEncode(session.toJson()));
    await prefs.setStringList(_sessionKey, sessions);
  }

  Future<void> sessionEnded() async {
    final prefs = await SharedPreferences.getInstance();
    int endTime = DateTime.now().toUtc().millisecondsSinceEpoch;

    List<String> sessions = prefs.getStringList(_sessionKey) ?? [];
    if (sessions.isNotEmpty) {
      String lastSessionJson = sessions.last;
      Sessions lastSession = Sessions.fromJson(jsonDecode(lastSessionJson));
      lastSession.endTime = endTime;

      // Update the last session
      sessions[sessions.length - 1] = jsonEncode(lastSession.toJson());
      await prefs.setStringList(_sessionKey, sessions);
      print("sessionEnded ${lastSession.id}, ${lastSession.endTime}");
    }
  }

  Future<void> sessionListPrint() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sessions = prefs.getStringList(_sessionKey) ?? [];

    if (sessions.isNotEmpty) {
      print("Session List:");
      for (var sessionJson in sessions) {
        Sessions session = Sessions.fromJson(jsonDecode(sessionJson));
        print("Session ID: ${session.id}, Start Time: ${session.startTime}, End Time: ${session.endTime}");
      }
    } else {
      print("No sessions available.");
    }
  }

  Future<void> syncSessionServer(String token) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sessions = prefs.getStringList(_sessionKey) ?? [];

    if (sessions.isNotEmpty) {
      List<Sessions> sessionList = sessions
          .map((sessionJson) => Sessions.fromJson(jsonDecode(sessionJson)))
          .toList();
      await DataManager().updateSessionToServer(token, sessionList);

      // Clear sessions after syncing
      await prefs.remove(_sessionKey);
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
