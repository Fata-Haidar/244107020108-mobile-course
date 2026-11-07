class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.route,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String route;
  final bool isRead;
  final DateTime? createdAt;

  CampusNotification copyWith({bool? isRead}) {
    return CampusNotification(
      id: id,
      title: title,
      body: body,
      route: route,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
