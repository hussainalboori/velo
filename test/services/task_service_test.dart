import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/services/task_service.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, MockPostgrestFilterBuilder> tableMocks = {};

  void setTableException(String table, Exception exception) {
    tableMocks[table] = MockPostgrestFilterBuilder(table, exceptionToThrow: exception);
  }

  @override
  SupabaseQueryBuilder from(String table) {
    if (!tableMocks.containsKey(table)) {
      tableMocks[table] = MockPostgrestFilterBuilder(table);
    }
    return MockSupabaseQueryBuilder(tableMocks[table]!);
  }
}

class MockSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final MockPostgrestFilterBuilder filterBuilder;

  MockSupabaseQueryBuilder(this.filterBuilder);

  @override
  PostgrestFilterBuilder<PostgrestList> delete() {
    return filterBuilder;
  }
}

class MockPostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  final String tableName;
  final List<String> deletedEqCalls = [];
  final Exception? _exceptionToThrow;

  MockPostgrestFilterBuilder(this.tableName, {Exception? exceptionToThrow})
      : _exceptionToThrow = exceptionToThrow;

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) {
    deletedEqCalls.add('$column=$value');
    final ex = _exceptionToThrow;
    if (ex != null) {
      throw ex;
    }
    return this;
  }

  // Allow awaiting PostgrestFilterBuilder as a Future
  @override
  Future<S> then<S>(FutureOr<S> Function(PostgrestList value) onValue,
      {Function? onError}) {
    final ex = _exceptionToThrow;
    if (ex != null) {
      return Future<PostgrestList>.error(ex).then(onValue, onError: onError);
    }
    return Future<PostgrestList>.value([]).then(onValue, onError: onError);
  }
}

void main() {
  late MockSupabaseClient mockClient;
  late TaskService taskService;

  setUp(() {
    mockClient = MockSupabaseClient();
    taskService = TaskService(client: mockClient);
  });

  group('TaskService.deleteTask', () {
    test('successfully deletes ai_usage_logs, subtasks, and task', () async {
      await taskService.deleteTask('task-123');

      final aiLogsMock = mockClient.tableMocks['ai_usage_logs'];
      final tasksMock = mockClient.tableMocks['tasks'];

      expect(aiLogsMock, isNotNull);
      expect(aiLogsMock!.deletedEqCalls, contains('task_id=task-123'));

      expect(tasksMock, isNotNull);
      expect(tasksMock!.deletedEqCalls, contains('parent_id=task-123'));
      expect(tasksMock.deletedEqCalls, contains('id=task-123'));
    });

    test('rethrows exception when ai_usage_logs deletion fails', () async {
      mockClient.setTableException(
        'ai_usage_logs',
        Exception('Database connection error on ai_usage_logs'),
      );

      expect(
        () async => await taskService.deleteTask('task-123'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Database connection error on ai_usage_logs'),
        )),
      );
    });

    test('rethrows exception when subtasks deletion fails', () async {
      mockClient.setTableException(
        'tasks',
        Exception('FK constraint error on subtasks'),
      );

      expect(
        () async => await taskService.deleteTask('task-123'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('FK constraint error on subtasks'),
        )),
      );
    });

    test('rethrows exception when primary task deletion fails', () async {
      final tasksQueryBuilder = MockQueryBuilderWithFailureOnSecondEq();

      final customClient = CustomMockSupabaseClient(tasksQueryBuilder);
      final customTaskService = TaskService(client: customClient);

      expect(
        () async => await customTaskService.deleteTask('task-123'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to delete primary task'),
        )),
      );
    });
  });
}

class CustomMockSupabaseClient extends Fake implements SupabaseClient {
  final MockQueryBuilderWithFailureOnSecondEq tasksQueryBuilder;
  final MockPostgrestFilterBuilder aiLogsMock = MockPostgrestFilterBuilder('ai_usage_logs');

  CustomMockSupabaseClient(this.tasksQueryBuilder);

  @override
  SupabaseQueryBuilder from(String table) {
    if (table == 'tasks') {
      return tasksQueryBuilder;
    }
    return MockSupabaseQueryBuilder(aiLogsMock);
  }
}

class MockQueryBuilderWithFailureOnSecondEq extends Fake implements SupabaseQueryBuilder {
  final List<int> _callCount = [0];

  @override
  PostgrestFilterBuilder<PostgrestList> delete() {
    return MockFilterBuilderWithCount(_callCount);
  }
}

class MockFilterBuilderWithCount extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  final List<int> _callCount;

  MockFilterBuilderWithCount(this._callCount);

  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) {
    _callCount[0]++;
    if (_callCount[0] == 2) {
      throw Exception('Failed to delete primary task');
    }
    return this;
  }

  @override
  Future<S> then<S>(FutureOr<S> Function(PostgrestList value) onValue, {Function? onError}) {
    return Future<PostgrestList>.value([]).then(onValue, onError: onError);
  }
}
