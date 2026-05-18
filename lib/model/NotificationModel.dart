class NotificationModel {

  final String id;
  final String message;
  final String type;
  final DateTime time;
  final bool read;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.time,
    required this.read,
  });

  factory NotificationModel.fromJson(
      Map<String, dynamic> json) {

    return NotificationModel(
      id: json['_id'],
      message: json['message'],
      type: json['type'],
      time: DateTime.parse(json['time']),
      read: json['read'] ?? false,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? message,
    String? type,
    DateTime? time,
    bool? read,
  }) {

    return NotificationModel(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      read: read ?? this.read,
    );
  }
}