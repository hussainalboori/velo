import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_flutter/models/task.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/services/task_service.dart';

class FakeTaskService extends TaskService {
  int updateCallCount = 0;
  int updateTasksCallCount = 0;
  final Duration delay;
  final bool useLegacySequential;

  FakeTaskService({
    this.delay = const Duration(milliseconds: 10),
    this.useLegacySequential = false,
  });

  @override
  Future<Task> addTask(Task task) async {
    return task.copyWith(id: 'id_${task.title}');
  }

  @override
  Future<Task> updateTask(Task task) async {
    updateCallCount++;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return task;
  }

  @override
  Future<void> updateTasks(List<Task> tasks) async {
    updateTasksCallCount++;
    if (useLegacySequential) {
      for (final t in tasks) {
        await updateTask(t);
      }
    } else {
      if (tasks.isEmpty) return;
      await Future.wait(tasks.map((task) => updateTask(task)));
    }
  }
}

void main() {
  group('TodoProvider removeCategory tests', () {
    test('removeCategory updates items belonging to target category', () async {
      final fakeService = FakeTaskService(delay: Duration.zero);
      final provider = TodoProvider(taskService: fakeService);

      provider.addCategory('work');
      provider.addCategory('personal');

      await provider.addTodo('Task 1', category: 'work');
      await provider.addTodo('Task 2', category: 'work');
      await provider.addTodo('Task 3', category: 'personal');

      final result = await provider.removeCategory('work');

      expect(result, RemoveCategoryResult.removed);
      expect(provider.categories.contains('work'), isFalse);
      expect(provider.items.where((t) => t.category == 'personal').length, 3);
    });

    test('removeCategory benchmark baseline vs parallel update', () async {
      final delay = const Duration(milliseconds: 10);
      const itemCount = 50;

      // Sequential fake service
      final seqService =
          FakeTaskService(delay: delay, useLegacySequential: true);
      final seqProvider = TodoProvider(taskService: seqService);
      seqProvider.addCategory('work');
      seqProvider.addCategory('personal');
      for (int i = 0; i < itemCount; i++) {
        await seqProvider.addTodo('Work Task $i', category: 'work');
      }

      final seqStopwatch = Stopwatch()..start();
      for (int i = 0; i < seqProvider.items.length; i++) {
        if (seqProvider.items[i].category == 'work') {
          await seqService
              .updateTask(seqProvider.items[i].copyWith(category: 'personal'));
        }
      }
      seqStopwatch.stop();

      // Concurrent (updateTasks with Future.wait) fake service
      final parService = FakeTaskService(delay: delay);
      final parProvider = TodoProvider(taskService: parService);
      parProvider.addCategory('work');
      parProvider.addCategory('personal');
      for (int i = 0; i < itemCount; i++) {
        await parProvider.addTodo('Work Task $i', category: 'work');
      }

      final tasksToUpdate = parProvider.items
          .where((t) => t.category == 'work')
          .map((t) => t.copyWith(category: 'personal'))
          .toList();

      final parStopwatch = Stopwatch()..start();
      await parService.updateTasks(tasksToUpdate);
      parStopwatch.stop();

      print(
          'Sequential elapsed time for $itemCount items: ${seqStopwatch.elapsedMilliseconds} ms');
      print(
          'Concurrent elapsed time for $itemCount items: ${parStopwatch.elapsedMilliseconds} ms');

      expect(parStopwatch.elapsedMilliseconds,
          lessThan(seqStopwatch.elapsedMilliseconds ~/ 5));
    });
  });
}
