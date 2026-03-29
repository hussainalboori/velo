/// Role: Defines the to-do entity and serialization helpers for local persistence.
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
  final String category;
  final bool isCompleted;

  TodoItem copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? category,
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
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      category: _categoryFromValue(map['category']),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  static String _categoryFromValue(Object? raw) {
    if (raw == null) {
      return 'personal';
    }

    return raw.toString();
  }
}
