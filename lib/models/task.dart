class Task {
  final String id;
  final String title;
  final String? type;
  final bool isDone;
  final String? userID;
  final DateTime? deadline;
  final bool isSynced;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.type,
    this.isDone = false,
    this.userID,
    this.deadline,
    this.isSynced = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'isDone': isDone,
      'userID': userID,
      'deadline': deadline?.toIso8601String(),
      'isSynced': isSynced,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'],
      isDone: map['isDone'] ?? false,
      userID: map['userID'],
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      isSynced: map['isSynced'] ?? false,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? type,
    bool? isDone,
    String? userID,
    DateTime? deadline,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isDone: isDone ?? this.isDone,
      userID: userID ?? this.userID,
      deadline: deadline ?? this.deadline,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
