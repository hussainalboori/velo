import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_flutter/models/task.dart';

void main() {
  group('Task model deserialization tests', () {
    test('Task.fromJson correctly parses nested subTasks', () {
      final Map<String, dynamic> json = {
        'id': 'parent-uuid-123',
        'user_id': 'user-uuid-456',
        'title': 'Parent Task',
        'is_completed': false,
        'category': 'work',
        'description': 'Parent description',
        'subTasks': [
          {
            'id': 'sub-uuid-1',
            'user_id': 'user-uuid-456',
            'title': 'Subtask 1',
            'is_completed': true,
            'parent_id': 'parent-uuid-123',
            'category': 'work',
          },
          {
            'id': 'sub-uuid-2',
            'user_id': 'user-uuid-456',
            'title': 'Subtask 2',
            'is_completed': false,
            'parent_id': 'parent-uuid-123',
            'category': 'work',
          }
        ]
      };

      final task = Task.fromJson(json);

      expect(task.id, equals('parent-uuid-123'));
      expect(task.title, equals('Parent Task'));
      expect(task.subTasks, hasLength(2));
      expect(task.subTasks[0].id, equals('sub-uuid-1'));
      expect(task.subTasks[0].title, equals('Subtask 1'));
      expect(task.subTasks[0].isCompleted, isTrue);
      expect(task.subTasks[1].id, equals('sub-uuid-2'));
      expect(task.subTasks[1].title, equals('Subtask 2'));
      expect(task.subTasks[1].isCompleted, isFalse);
    });

    test('Task.fromJson handles empty or null subTasks', () {
      final Map<String, dynamic> jsonWithoutSubtasks = {
        'id': 'task-1',
        'title': 'Single Task',
      };

      final task = Task.fromJson(jsonWithoutSubtasks);

      expect(task.id, equals('task-1'));
      expect(task.subTasks, isEmpty);
    });
  });
}
