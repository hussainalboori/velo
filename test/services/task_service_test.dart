import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/services/task_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockFunctionsClient mockFunctionsClient;
  late TaskService taskService;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockFunctionsClient = MockFunctionsClient();

    when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
    taskService = TaskService(client: mockSupabaseClient);
  });

  group('TaskService.generateSubtasks', () {
    test('successfully invokes edge function with trimmed parameters', () async {
      when(
        () => mockFunctionsClient.invoke(
          'generate-subtasks',
          body: {
            'taskId': 'task-123',
            'taskTitle': 'Write documentation',
          },
        ),
      ).thenAnswer(
        (_) async => FunctionResponse(
          data: {'status': 'success'},
          status: 200,
        ),
      );

      await taskService.generateSubtasks(' task-123 ', ' Write documentation ');

      verify(
        () => mockFunctionsClient.invoke(
          'generate-subtasks',
          body: {
            'taskId': 'task-123',
            'taskTitle': 'Write documentation',
          },
        ),
      ).called(1);
    });

    test('throws ArgumentError when taskId is empty or whitespace', () async {
      expect(
        () => taskService.generateSubtasks('', 'Valid Title'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'taskId cannot be empty',
          ),
        ),
      );

      expect(
        () => taskService.generateSubtasks('   ', 'Valid Title'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'taskId cannot be empty',
          ),
        ),
      );

      verifyNever(
        () => mockFunctionsClient.invoke(
          any(),
          body: any(named: 'body'),
        ),
      );
    });

    test('throws ArgumentError when taskTitle is empty or whitespace', () async {
      expect(
        () => taskService.generateSubtasks('task-123', ''),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'taskTitle cannot be empty',
          ),
        ),
      );

      expect(
        () => taskService.generateSubtasks('task-123', '   '),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'taskTitle cannot be empty',
          ),
        ),
      );

      verifyNever(
        () => mockFunctionsClient.invoke(
          any(),
          body: any(named: 'body'),
        ),
      );
    });

    test('propagates FunctionException (e.g. OUT_OF_TOKENS error) from edge function', () async {
      final functionException = FunctionException(
        status: 402,
        details: 'OUT_OF_TOKENS',
      );

      when(
        () => mockFunctionsClient.invoke(
          'generate-subtasks',
          body: {
            'taskId': 'task-123',
            'taskTitle': 'Generate Plan',
          },
        ),
      ).thenThrow(functionException);

      expect(
        () => taskService.generateSubtasks('task-123', 'Generate Plan'),
        throwsA(
          isA<FunctionException>().having(
            (e) => e.details,
            'details',
            'OUT_OF_TOKENS',
          ),
        ),
      );
    });

    test('propagates general Exception when functions.invoke fails', () async {
      when(
        () => mockFunctionsClient.invoke(
          'generate-subtasks',
          body: {
            'taskId': 'task-123',
            'taskTitle': 'Generate Plan',
          },
        ),
      ).thenThrow(const FormatException('Network timeout'));

      expect(
        () => taskService.generateSubtasks('task-123', 'Generate Plan'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString()',
            contains('Network timeout'),
          ),
        ),
      );
    });
  });
}
