/// Role: Defines the to-do entity and serialization helpers for local persistence.
enum TodoCategory {
  personal,
  work,
  study,
}

class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.category,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final TodoCategory category;
  final bool isCompleted;

  TodoItem copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    TodoCategory? category,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'category': category.name,
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      category: _categoryFromValue(map['category'] as String?),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  static TodoCategory _categoryFromValue(String? raw) {
    if (raw == null) {
      return TodoCategory.personal;
    }

    return TodoCategory.values.firstWhere(
      (TodoCategory value) => value.name == raw,
      orElse: () => TodoCategory.personal,
    );
  }
}
