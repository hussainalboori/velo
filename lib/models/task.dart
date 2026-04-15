class Task {
  final String? id;
  final String? userId;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int priorityLevel;
  final String? parentId;
  final DateTime? createdAt;

  Task({
    this.id,
    this.userId,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.priorityLevel = 1,
    this.parentId,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      priorityLevel: json['priority_level'] as int? ?? 1,
      parentId: json['parent_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'title': title,
      'is_completed': isCompleted,
      if (dueDate != null) 'due_date': dueDate?.toIso8601String(),
      'priority_level': priorityLevel,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    int? priorityLevel,
    String? parentId,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
