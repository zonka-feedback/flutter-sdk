import 'package:hive/hive.dart';

part 'sessions.g.dart';

@HiveType(typeId: 0) // Assign a unique typeId for this model
class Sessions extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  int? startTime;

  @HiveField(2)
  int? endTime;

  Sessions({
    required this.id,
    required this.startTime,
    required this.endTime,
  });
}
