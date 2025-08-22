class Event {
  final String id;
  final String title;
  final String? type;
  final DateTime? dateTime;
  final String? userID;
  final bool isSynced;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    this.type,
    this.dateTime,
    this.userID,
    this.isSynced = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'dateTime': dateTime?.toIso8601String(),
      'userID': userID,
      'isSynced': isSynced,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'],
      dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime']) : null,
      userID: map['userID'],
      isSynced: map['isSynced'] ?? false,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? dateTime,
    String? userID,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      userID: userID ?? this.userID,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
