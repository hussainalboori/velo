/// Represents a single todo item or a subtask.
///
/// The model is intentionally small but flexible: it mirrors the database schema while also carrying
/// UI-only fields such as `category`, `description`, and nested `subTasks`. This keeps the screen layer
/// simple while still allowing a single object to represent both a top-level task and a child task.
class Task {
  final String? id;
  final String? userId;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int priorityLevel;
  final String? parentId;
  final DateTime? createdAt;

  // UI extended properties.
  final String category;
  final String description;
  final List<Task> subTasks;

  Task({
    this.id,
    this.userId,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.priorityLevel = 1,
    this.parentId,
    this.createdAt,
    this.category = 'personal',
    this.description = '',
    this.subTasks = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // The database returns snake_case keys. Converting them here keeps the model independent from the
    // underlying Supabase schema and gives the rest of the app a cleaner domain model.
    return Task(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      priorityLevel: json['priority_level'] as int? ?? 1,
      parentId: json['parent_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      category: json['category'] as String? ?? 'personal',
      description: json['description'] as String? ?? '',
      subTasks: json['subTasks'] != null
          ? (json['subTasks'] as List).map((i) => Task.fromJson(i)).toList()
          : [],
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
      'category': category,
      'description': description,
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
    String? category,
    String? description,
    List<Task>? subTasks,
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
      category: category ?? this.category,
      description: description ?? this.description,
      subTasks: subTasks ?? this.subTasks,
    );
  }
}
