import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_flutter/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('toJson converts full Task instance to JSON map correctly', () {
      final now = DateTime.parse('2025-01-01T12:00:00.000Z');
      final task = Task(
        id: 'task-1',
        userId: 'user-123',
        title: 'Complete task tests',
        isCompleted: true,
        dueDate: now,
        priorityLevel: 2,
        parentId: 'parent-task',
        createdAt: now,
        category: 'work',
        description: 'Add tests for Task model',
        subTasks: [
          Task(id: 'sub-1', title: 'Subtask 1'),
        ],
      );

      final json = task.toJson();

      expect(json, {
        'id': 'task-1',
        'user_id': 'user-123',
        'title': 'Complete task tests',
        'is_completed': true,
        'due_date': now.toIso8601String(),
        'priority_level': 2,
        'parent_id': 'parent-task',
        'created_at': now.toIso8601String(),
        'category': 'work',
        'description': 'Add tests for Task model',
      });
    });

    test('toJson omits optional null fields', () {
      final task = Task(
        title: 'Minimal task',
      );

      final json = task.toJson();

      expect(json, {
        'title': 'Minimal task',
        'is_completed': false,
        'priority_level': 1,
        'category': 'personal',
        'description': '',
      });
      expect(json.containsKey('id'), false);
      expect(json.containsKey('user_id'), false);
      expect(json.containsKey('due_date'), false);
      expect(json.containsKey('parent_id'), false);
      expect(json.containsKey('created_at'), false);
    });

    test('fromJson creates Task correctly with full data', () {
      final json = {
        'id': 'task-1',
        'user_id': 'user-123',
        'title': 'Test fromJson',
        'is_completed': true,
        'due_date': '2025-01-01T12:00:00.000Z',
        'priority_level': 3,
        'parent_id': 'parent-1',
        'created_at': '2025-01-01T10:00:00.000Z',
        'category': 'study',
        'description': 'Test description',
        'subTasks': [
          {
            'id': 'sub-1',
            'title': 'Child task',
            'is_completed': false,
          }
        ],
      };

      final task = Task.fromJson(json);

      expect(task.id, 'task-1');
      expect(task.userId, 'user-123');
      expect(task.title, 'Test fromJson');
      expect(task.isCompleted, true);
      expect(task.dueDate, DateTime.parse('2025-01-01T12:00:00.000Z'));
      expect(task.priorityLevel, 3);
      expect(task.parentId, 'parent-1');
      expect(task.createdAt, DateTime.parse('2025-01-01T10:00:00.000Z'));
      expect(task.category, 'study');
      expect(task.description, 'Test description');
      expect(task.subTasks.length, 1);
      expect(task.subTasks.first.id, 'sub-1');
      expect(task.subTasks.first.title, 'Child task');
    });

    test('fromJson creates Task correctly with minimal data', () {
      final json = {
        'title': 'Minimal JSON task',
      };

      final task = Task.fromJson(json);

      expect(task.id, isNull);
      expect(task.userId, isNull);
      expect(task.title, 'Minimal JSON task');
      expect(task.isCompleted, false);
      expect(task.dueDate, isNull);
      expect(task.priorityLevel, 1);
      expect(task.parentId, isNull);
      expect(task.createdAt, isNull);
      expect(task.category, 'personal');
      expect(task.description, '');
      expect(task.subTasks, isEmpty);
    });

    test('copyWith updates specified fields while keeping remaining intact', () {
      final original = Task(
        id: '1',
        title: 'Original Title',
        category: 'personal',
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        category: 'work',
        isCompleted: true,
      );

      expect(updated.id, '1');
      expect(updated.title, 'Updated Title');
      expect(updated.category, 'work');
      expect(updated.isCompleted, true);
    });
  });
}
