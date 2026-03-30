asd/// Role: Provides a dedicated task details page for editing title, description, and subtasks.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/todo_item.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    required this.taskId,
    super.key,
  });

  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subTaskController = TextEditingController();

  bool _isInitialized = false;
  bool _isEditing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  void _initializeIfNeeded(TodoItem task) {
    if (_isInitialized) {
      return;
    }

    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _isInitialized = true;
  }

  Future<bool> _saveTask(BuildContext context) async {
    final TodoProvider provider = context.read<TodoProvider>();
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text;

    if (title.isEmpty) {
      _showSnackBar(context, AppStrings.taskSaveError);
      return false;
    }

    if (description.length > AppConstants.maxDescriptionLength) {
      _showSnackBar(context, AppStrings.descriptionSaveError);
      return false;
    }

    final bool didSave = await provider.updateTaskDetails(
      id: widget.taskId,
      title: title,
      description: description,
    );

    if (!context.mounted || !didSave) {
      return false;
    }

    _showSnackBar(context, AppStrings.saveChangesSuccess);
    return true;
  }

  Future<void> _addSubTask(BuildContext context) async {
    final String rawTitle = _subTaskController.text;
    final String cleanTitle = rawTitle.trim();
    if (cleanTitle.isEmpty) {
      _showSnackBar(context, AppStrings.subTaskAddError);
      return;
    }

    if (cleanTitle.length > AppConstants.maxSubTaskLength) {
      _showSnackBar(context, AppStrings.subTaskSaveError);
      return;
    }

    final TodoProvider provider = context.read<TodoProvider>();
    final bool didAdd = await provider.addSubTask(
      taskId: widget.taskId,
      title: cleanTitle,
    );

    if (!context.mounted || !didAdd) {
      return;
    }

    _subTaskController.clear();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final TodoProvider provider = context.watch<TodoProvider>();
    final TodoItem? task = provider.taskById(widget.taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.taskDetailsTitle)),
        body: const Center(child: Text(AppStrings.emptyTitle)),
      );
    }

    _initializeIfNeeded(task);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskDetailsTitle),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if (_isEditing) {
                final bool didSave = await _saveTask(context);
                if (!mounted || !didSave) {
                  return;
                }

                setState(() {
                  _isEditing = false;
                });
                return;
              }

              setState(() {
                _titleController.text = task.title;
                _descriptionController.text = task.description;
                _isEditing = true;
              });
            },
            child: Text(
              _isEditing
                  ? AppStrings.taskSaveTopButton
                  : AppStrings.taskEditButton,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.taskTitleLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _titleController,
                  maxLength: AppConstants.maxTodoLength,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                )
              else
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 12),
              Text(
                AppStrings.taskDescriptionLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: AppConstants.maxDescriptionLength,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppStrings.taskDescriptionHint,
                  ),
                )
              else
                Text(
                  task.description.isEmpty
                      ? AppStrings.taskDescriptionHint
                      : task.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 22),
              Text(
                AppStrings.subTasksLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _subTaskController,
                      maxLength: AppConstants.maxSubTaskLength,
                      decoration: const InputDecoration(
                        hintText: AppStrings.subTaskHint,
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      onSubmitted: (_) => _addSubTask(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () => _addSubTask(context),
                    child: const Text(AppStrings.addSubTaskButton),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (task.subTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(AppStrings.emptySubTasks),
                )
              else
                Column(
                  children: task.subTasks.map((SubTask subTask) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: subTask.isCompleted,
                        onChanged: (_) {
                          provider.toggleSubTask(
                            taskId: task.id,
                            subTaskId: subTask.id,
                          );
                        },
                        title: Text(
                          subTask.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondary: IconButton(
                          onPressed: () {
                            provider.deleteSubTask(
                              taskId: task.id,
                              subTaskId: subTask.id,
                            );
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
