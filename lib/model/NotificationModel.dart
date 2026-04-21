class NotificationModel {
  final String id;
  final String message;
  final String type;
  final DateTime time;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.time,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      message: json['message'],
      type: json['type'],
      time: DateTime.parse(json['time']),
    );
  }
}

// class NotificationModel {
//   final String id;
//   final String message;
//   final String type;
//   final DateTime time;

//   NotificationModel({
//     required this.id,
//     required this.message,
//     required this.type,
//     required this.time,
//   });

//   factory NotificationModel.fromJson(Map<String, dynamic> json) {
//     DateTime parsedTime;

//     try {
//     parsedTime = DateTime.parse(json['time']).toUtc(); // ✅ FIXED
//   } catch (e) {
//     print("❌ Time parse error: ${json['time']}");
//     parsedTime = DateTime.fromMillisecondsSinceEpoch(0); // ✅ SAFE fallback
//   }

//     return NotificationModel(
//       id: json['_id'] ?? '',
//       message: json['message'] ?? '',
//       type: json['type'] ?? '',
//       time: parsedTime,
//     );
//   }
// }
