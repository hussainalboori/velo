import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:to_do_flutter/models/task.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch tasks for the current user, excluding subtasks
  Future<List<Task>> getTasks() async {
    final response = await _client
        .from('tasks')
        .select()
        .isFilter('parent_id', null)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Add a new task
  Future<Task> addTask(Task task) async {
    final response = await _client.from('tasks').insert(task.toJson()).select().single();
    return Task.fromJson(response);
  }

  /// Update task completion status
  Future<Task> updateTaskCompletion(String taskId, bool isCompleted) async {
    final response = await _client
        .from('tasks')
        .update({'is_completed': isCompleted})
        .eq('id', taskId)
        .select()
        .single();
    return Task.fromJson(response);
  }

  /// Call Edge Function to generate subtasks
  Future<void> generateSubtasks(String parentId) async {
    await _client.functions.invoke(
      'generate-subtasks',
      body: {'parent_id': parentId},
    );
  }
}
