import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_flutter/models/task.dart';

void main() {
  group('Task.fromJson', () {
    test('deserializes complete JSON payload with all fields', () {
      final json = {
        'id': 'task-123',
        'user_id': 'user-456',
        'title': 'Complete project proposal',
        'is_completed': true,
        'due_date': '2026-12-31T23:59:59.000Z',
        'priority_level': 3,
        'parent_id': 'parent-789',
        'created_at': '2026-01-01T10:00:00.000Z',
        'category': 'work',
        'description': 'Draft and finalize proposal document.',
        'subTasks': [
          {
            'id': 'subtask-1',
            'user_id': 'user-456',
            'title': 'Gather requirements',
            'is_completed': true,
            'priority_level': 2,
            'parent_id': 'task-123',
            'category': 'work',
            'description': 'Talk to stakeholders',
          },
          {
            'id': 'subtask-2',
            'user_id': 'user-456',
            'title': 'Write outline',
            'is_completed': false,
            'priority_level': 1,
            'parent_id': 'task-123',
            'category': 'work',
            'description': '',
          }
        ],
      };

      final task = Task.fromJson(json);

      expect(task.id, equals('task-123'));
      expect(task.userId, equals('user-456'));
      expect(task.title, equals('Complete project proposal'));
      expect(task.isCompleted, isTrue);
      expect(
        task.dueDate,
        equals(DateTime.parse('2026-12-31T23:59:59.000Z')),
      );
      expect(task.priorityLevel, equals(3));
      expect(task.parentId, equals('parent-789'));
      expect(
        task.createdAt,
        equals(DateTime.parse('2026-01-01T10:00:00.000Z')),
      );
      expect(task.category, equals('work'));
      expect(task.description, equals('Draft and finalize proposal document.'));
      expect(task.subTasks, hasLength(2));

      expect(task.subTasks[0].id, equals('subtask-1'));
      expect(task.subTasks[0].title, equals('Gather requirements'));
      expect(task.subTasks[0].isCompleted, isTrue);
      expect(task.subTasks[0].parentId, equals('task-123'));

      expect(task.subTasks[1].id, equals('subtask-2'));
      expect(task.subTasks[1].title, equals('Write outline'));
      expect(task.subTasks[1].isCompleted, isFalse);
    });

    test('applies default values when optional fields are missing', () {
      final json = <String, dynamic>{
        'title': 'Minimal Task',
      };

      final task = Task.fromJson(json);

      expect(task.id, isNull);
      expect(task.userId, isNull);
      expect(task.title, equals('Minimal Task'));
      expect(task.isCompleted, isFalse);
      expect(task.dueDate, isNull);
      expect(task.priorityLevel, equals(1));
      expect(task.parentId, isNull);
      expect(task.createdAt, isNull);
      expect(task.category, equals('personal'));
      expect(task.description, equals(''));
      expect(task.subTasks, isEmpty);
    });

    test('handles explicit null values for optional fields', () {
      final json = <String, dynamic>{
        'id': null,
        'user_id': null,
        'title': 'Task with nulls',
        'is_completed': null,
        'due_date': null,
        'priority_level': null,
        'parent_id': null,
        'created_at': null,
        'category': null,
        'description': null,
        'subTasks': null,
      };

      final task = Task.fromJson(json);

      expect(task.id, isNull);
      expect(task.userId, isNull);
      expect(task.title, equals('Task with nulls'));
      expect(task.isCompleted, isFalse);
      expect(task.dueDate, isNull);
      expect(task.priorityLevel, equals(1));
      expect(task.parentId, isNull);
      expect(task.createdAt, isNull);
      expect(task.category, equals('personal'));
      expect(task.description, equals(''));
      expect(task.subTasks, isEmpty);
    });

    test('round-trip serialization via fromJson and toJson', () {
      final originalJson = {
        'id': 'task-roundtrip',
        'user_id': 'user-111',
        'title': 'Roundtrip test',
        'is_completed': true,
        'due_date': '2026-05-15T08:00:00.000Z',
        'priority_level': 2,
        'parent_id': 'parent-000',
        'created_at': '2026-01-01T12:00:00.000Z',
        'category': 'study',
        'description': 'Testing round-trip',
      };

      final task = Task.fromJson(originalJson);
      final jsonOutput = task.toJson();

      expect(jsonOutput['id'], equals('task-roundtrip'));
      expect(jsonOutput['user_id'], equals('user-111'));
      expect(jsonOutput['title'], equals('Roundtrip test'));
      expect(jsonOutput['is_completed'], isTrue);
      expect(jsonOutput['due_date'], equals(DateTime.parse('2026-05-15T08:00:00.000Z').toIso8601String()));
      expect(jsonOutput['priority_level'], equals(2));
      expect(jsonOutput['parent_id'], equals('parent-000'));
      expect(jsonOutput['created_at'], equals(DateTime.parse('2026-01-01T12:00:00.000Z').toIso8601String()));
      expect(jsonOutput['category'], equals('study'));
      expect(jsonOutput['description'], equals('Testing round-trip'));
    });
  });
}
