import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_flutter/models/task.dart';

void main() {
  group('Task.toJson', () {
    test('serializes all fields when non-null', () {
      final now = DateTime.now();
      final task = Task(
        id: 'task-123',
        userId: 'user-456',
        title: 'Test Task',
        isCompleted: true,
        dueDate: now,
        priorityLevel: 2,
        parentId: 'parent-789',
        createdAt: now,
        category: 'work',
        description: 'Task description',
      );

      final json = task.toJson();

      expect(json, {
        'id': 'task-123',
        'user_id': 'user-456',
        'title': 'Test Task',
        'is_completed': true,
        'due_date': now.toIso8601String(),
        'priority_level': 2,
        'parent_id': 'parent-789',
        'created_at': now.toIso8601String(),
        'category': 'work',
        'description': 'Task description',
      });
    });

    test('omits optional null fields from serialization', () {
      final task = Task(
        title: 'Minimal Task',
      );

      final json = task.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('user_id'), isFalse);
      expect(json.containsKey('due_date'), isFalse);
      expect(json.containsKey('parent_id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);

      expect(json, {
        'title': 'Minimal Task',
        'is_completed': false,
        'priority_level': 1,
        'category': 'personal',
        'description': '',
      });
    });

    test('supports roundtrip serialization with fromJson and toJson', () {
      final originalJson = {
        'id': 'task-999',
        'user_id': 'user-888',
        'title': 'Roundtrip Task',
        'is_completed': true,
        'due_date': '2025-12-31T23:59:59.000Z',
        'priority_level': 3,
        'parent_id': 'parent-111',
        'created_at': '2025-01-01T00:00:00.000Z',
        'category': 'study',
        'description': 'Description for roundtrip',
      };

      final task = Task.fromJson(originalJson);
      final json = task.toJson();

      expect(json['id'], equals(originalJson['id']));
      expect(json['user_id'], equals(originalJson['user_id']));
      expect(json['title'], equals(originalJson['title']));
      expect(json['is_completed'], equals(originalJson['is_completed']));
      expect(json['due_date'], equals(DateTime.parse(originalJson['due_date'] as String).toIso8601String()));
      expect(json['priority_level'], equals(originalJson['priority_level']));
      expect(json['parent_id'], equals(originalJson['parent_id']));
      expect(json['created_at'], equals(DateTime.parse(originalJson['created_at'] as String).toIso8601String()));
      expect(json['category'], equals(originalJson['category']));
      expect(json['description'], equals(originalJson['description']));
    });
  });
}
