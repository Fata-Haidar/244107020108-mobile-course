import '../domain/campus_notification.dart';

class CampusNotificationModel extends CampusNotification {
  const CampusNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.route,
    required super.isRead,
    super.createdAt,
  });

  factory CampusNotificationModel.fromMap(Map<String, dynamic> data) {
    return CampusNotificationModel(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Pengumuman Kampus',
      body: data['body']?.toString() ?? '',
      route: data['route']?.toString() ?? '/',
      isRead: data['isRead'] == true,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'route': route,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
