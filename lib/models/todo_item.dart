/// Role: Defines the to-do entity and serialization helpers for local persistence.
class SubTask {
  const SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.category,
    this.description = '',
    this.subTasks = const <SubTask>[],
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final String category;
  final String description;
  final List<SubTask> subTasks;
  final bool isCompleted;

  TodoItem copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? category,
    String? description,
    List<SubTask>? subTasks,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      description: description ?? this.description,
      subTasks: subTasks ?? this.subTasks,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'category': category,
      'description': description,
      'subTasks': subTasks.map((SubTask task) => task.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      category: _categoryFromValue(map['category']),
      description: map['description'] as String? ?? '',
      subTasks: _subTasksFromValue(map['subTasks']),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  static String _categoryFromValue(Object? raw) {
    if (raw == null) {
      return 'personal';
    }

    return raw.toString();
  }

  static List<SubTask> _subTasksFromValue(Object? raw) {
    if (raw is! List) {
      return <SubTask>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (Map map) => SubTask.fromMap(
            map.cast<String, dynamic>(),
          ),
        )
        .toList();
  }
}
