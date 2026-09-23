import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/models/task.dart';
import 'package:to_do_flutter/services/task_service.dart';

void main() {
  group('TaskService - getTasks() testing gap & full coverage', () {
    const supabaseUrl = 'https://example.supabase.co';
    const anonKey = 'dummy-anon-key';

    test('getTasks returns list of top-level tasks and sets proper filters/order', () async {
      http.Request? capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        final responsePayload = [
          {
            'id': 'task-1',
            'user_id': 'user-123',
            'title': 'Top level task 1',
            'is_completed': false,
            'priority_level': 1,
            'parent_id': null,
            'created_at': '2026-01-01T12:00:00.000Z',
            'category': 'work',
            'description': 'Description 1',
          },
          {
            'id': 'task-2',
            'user_id': 'user-123',
            'title': 'Top level task 2',
            'is_completed': true,
            'priority_level': 2,
            'parent_id': null,
            'created_at': '2026-01-01T11:00:00.000Z',
            'category': 'personal',
            'description': '',
          },
        ];

        return http.Response(
          jsonEncode(responsePayload),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      final tasks = await taskService.getTasks();

      expect(tasks, hasLength(2));
      expect(tasks[0].id, 'task-1');
      expect(tasks[0].title, 'Top level task 1');
      expect(tasks[0].category, 'work');
      expect(tasks[0].isCompleted, isFalse);

      expect(tasks[1].id, 'task-2');
      expect(tasks[1].title, 'Top level task 2');
      expect(tasks[1].isCompleted, isTrue);

      // Verify request details sent to Supabase
      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method.toUpperCase(), 'GET');
      expect(capturedRequest!.url.path, '/rest/v1/tasks');
      expect(capturedRequest!.url.queryParameters['select'], '*');
      expect(capturedRequest!.url.queryParameters['parent_id'], 'is.null');
      expect(capturedRequest!.url.queryParameters['order'], startsWith('created_at.desc'));
    });

    test('getTasks returns an empty list when no top-level tasks exist', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      final tasks = await taskService.getTasks();

      expect(tasks, isEmpty);
    });

    test('getTasks throws PostgrestException on API failure', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Internal Server Error', 'code': '500'}),
          500,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      expect(() async => await taskService.getTasks(), throwsA(isA<PostgrestException>()));
    });

    test('getSubTasks returns subtasks for a specific parent task', () async {
      http.Request? capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        final responsePayload = [
          {
            'id': 'subtask-1',
            'user_id': 'user-123',
            'title': 'Child subtask 1',
            'is_completed': false,
            'priority_level': 1,
            'parent_id': 'parent-123',
            'created_at': '2026-01-01T12:00:00.000Z',
            'category': 'personal',
            'description': '',
          },
        ];

        return http.Response(
          jsonEncode(responsePayload),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      final subtasks = await taskService.getSubTasks('parent-123');

      expect(subtasks, hasLength(1));
      expect(subtasks[0].id, 'subtask-1');
      expect(subtasks[0].parentId, 'parent-123');

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method.toUpperCase(), 'GET');
      expect(capturedRequest!.url.queryParameters['parent_id'], 'eq.parent-123');
      expect(capturedRequest!.url.queryParameters['order'], startsWith('created_at.asc'));
    });

    test('addTask sends POST request and returns created Task', () async {
      http.Request? capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        final responsePayload = {
          'id': 'new-task-1',
          'user_id': 'user-123',
          'title': 'New task',
          'is_completed': false,
          'priority_level': 1,
          'parent_id': null,
          'created_at': '2026-01-01T12:00:00.000Z',
          'category': 'work',
          'description': '',
        };

        return http.Response(
          jsonEncode(responsePayload),
          201,
          request: request,
          headers: {
            'content-type': 'application/json',
            'content-range': '0-0/1',
          },
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      final taskToInsert = Task(title: 'New task', category: 'work');
      final createdTask = await taskService.addTask(taskToInsert);

      expect(createdTask.id, 'new-task-1');
      expect(createdTask.title, 'New task');

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method.toUpperCase(), 'POST');
      final bodyBytes = capturedRequest!.body;
      final parsedBody = jsonDecode(bodyBytes);
      expect(parsedBody['title'], 'New task');
      expect(parsedBody['category'], 'work');
    });

    test('updateTask sends PATCH request and returns updated Task', () async {
      http.Request? capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        final responsePayload = {
          'id': 'task-1',
          'user_id': 'user-123',
          'title': 'Updated title',
          'is_completed': false,
          'priority_level': 1,
          'parent_id': null,
          'created_at': '2026-01-01T12:00:00.000Z',
          'category': 'study',
          'description': 'Updated description',
        };

        return http.Response(
          jsonEncode(responsePayload),
          200,
          request: request,
          headers: {
            'content-type': 'application/json',
            'content-range': '0-0/1',
          },
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      final taskToUpdate = Task(
        id: 'task-1',
        title: 'Updated title',
        category: 'study',
        description: 'Updated description',
      );

      final updated = await taskService.updateTask(taskToUpdate);

      expect(updated.id, 'task-1');
      expect(updated.title, 'Updated title');
      expect(updated.category, 'study');

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method.toUpperCase(), 'PATCH');
      expect(capturedRequest!.url.queryParameters['id'], 'eq.task-1');
    });

    test('updateTaskCompletion sends PATCH request with is_completed status', () async {
      http.Request? capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        final responsePayload = {
          'id': 'task-1',
          'user_id': 'user-123',
          'title': 'Existing title',
          'is_completed': true,
          'priority_level': 1,
          'parent_id': null,
          'created_at': '2026-01-01T12:00:00.000Z',
          'category': 'personal',
          'description': '',
        };

        return http.Response(
          jsonEncode(responsePayload),
          200,
          request: request,
          headers: {
            'content-type': 'application/json',
            'content-range': '0-0/1',
          },
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      final updated = await taskService.updateTaskCompletion('task-1', true);

      expect(updated.isCompleted, isTrue);

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method.toUpperCase(), 'PATCH');
      expect(capturedRequest!.url.queryParameters['id'], 'eq.task-1');
      final body = jsonDecode(capturedRequest!.body);
      expect(body, {'is_completed': true});
    });

    test('deleteTask issues DELETE requests for ai_usage_logs, subtasks, and task', () async {
      final capturedRequests = <http.Request>[];

      final mockClient = MockClient((request) async {
        capturedRequests.add(request);
        return http.Response(
          jsonEncode([]),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      await taskService.deleteTask('task-to-delete');

      expect(capturedRequests, hasLength(3));
      expect(capturedRequests[0].method.toUpperCase(), 'DELETE');
      expect(capturedRequests[0].url.path, '/rest/v1/ai_usage_logs');
      expect(capturedRequests[0].url.queryParameters['task_id'], 'eq.task-to-delete');

      expect(capturedRequests[1].method.toUpperCase(), 'DELETE');
      expect(capturedRequests[1].url.path, '/rest/v1/tasks');
      expect(capturedRequests[1].url.queryParameters['parent_id'], 'eq.task-to-delete');

      expect(capturedRequests[2].method.toUpperCase(), 'DELETE');
      expect(capturedRequests[2].url.path, '/rest/v1/tasks');
      expect(capturedRequests[2].url.queryParameters['id'], 'eq.task-to-delete');
    });

    test('generateSubtasks invokes edge function with task metadata', () async {
      http.Request? capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'success': true}),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      });

      final supabaseClient = SupabaseClient(supabaseUrl, anonKey, httpClient: mockClient);
      final taskService = TaskService(client: supabaseClient);

      await taskService.generateSubtasks('task-99', 'Plan vacation');

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method.toUpperCase(), 'POST');
      expect(capturedRequest!.url.path, '/functions/v1/generate-subtasks');
      final body = jsonDecode(capturedRequest!.body);
      expect(body, {'taskId': 'task-99', 'taskTitle': 'Plan vacation'});
    });
  });
}
