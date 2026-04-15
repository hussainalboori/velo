/// Role: Manages to-do state, interacting with Supabase via TaskService.
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/task.dart';
import 'package:to_do_flutter/services/task_service.dart';

enum TodoFilter { all, active, completed }
enum RemoveCategoryResult { removed, lastCategory, notFound }

class TodoProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  final List<Task> _items = <Task>[];
  final List<String> _categories = List<String>.from(AppConstants.defaultCategories);
  final Set<String> _busyItemIds = <String>{};

  bool _isLoading = true;
  bool _isAdding = false;
  TodoFilter _selectedFilter = TodoFilter.all;
  String _draftCategory = AppConstants.defaultCategories.first;

  UnmodifiableListView<Task> get items => UnmodifiableListView<Task>(_items);
  UnmodifiableListView<String> get categories => UnmodifiableListView<String>(_categories);
  UnmodifiableSetView<String> get busyItemIds => UnmodifiableSetView<String>(_busyItemIds);

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  TodoFilter get selectedFilter => _selectedFilter;
  String get draftCategory => _draftCategory;

  int get activeCount => _items.where((Task item) => !item.isCompleted).length;
  int get completedCount => _items.where((Task item) => item.isCompleted).length;

  List<Task> get filteredItems {
    switch (_selectedFilter) {
      case TodoFilter.active:
        return _items.where((Task item) => !item.isCompleted).toList();
      case TodoFilter.completed:
        return _items.where((Task item) => item.isCompleted).toList();
      case TodoFilter.all:
        return List<Task>.from(_items);
    }
  }

  Task? taskById(String id) {
    try {
      return _items.firstWhere((Task item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isItemBusy(String id) => _busyItemIds.contains(id);

  void setFilter(TodoFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  void setDraftCategory(String category) {
    if (_draftCategory == category) return;
    _draftCategory = category;
    notifyListeners();
  }

  bool addCategory(String rawName) {
    final String normalized = CategoryCopy.normalize(rawName);
    if (normalized.isEmpty || normalized.length > AppConstants.maxCategoryLength || _categories.contains(normalized)) {
      return false;
    }
    _categories.add(normalized);
    _categories.sort();
    _draftCategory = normalized;
    notifyListeners();
    return true;
  }

  Future<RemoveCategoryResult> removeCategory(String category) async {
    final String normalized = CategoryCopy.normalize(category);
    if (!_categories.contains(normalized)) return RemoveCategoryResult.notFound;
    if (_categories.length == 1) return RemoveCategoryResult.lastCategory;

    _categories.remove(normalized);
    final String fallbackCategory = _categories.first;

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].category == normalized) {
        _items[i] = _items[i].copyWith(category: fallbackCategory);
        await _taskService.updateTask(_items[i]);
      }
    }

    if (_draftCategory == normalized) _draftCategory = fallbackCategory;
    notifyListeners();
    return RemoveCategoryResult.removed;
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final tasks = await _taskService.getTasks();
      // Fetch subtasks for each task. In a real app we'd do a joined query.
      for (int i = 0; i < tasks.length; i++) {
        final subTasks = await _taskService.getSubTasks(tasks[i].id!);
        tasks[i] = tasks[i].copyWith(subTasks: subTasks);
      }
      
      _items.clear();
      _items.addAll(tasks);

      // Collect any unique categories from the server
      for (final task in tasks) {
        if (!_categories.contains(task.category)) {
          _categories.add(task.category);
        }
      }

      if (!_categories.contains(_draftCategory)) {
        _draftCategory = _categories.first;
      }
    } catch (_) {
      _items.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTodo(String text, {String? category}) async {
    if (_isAdding) return false;

    final String cleanedText = text.trim();
    if (cleanedText.isEmpty || cleanedText.length > AppConstants.maxTodoLength) return false;

    _isAdding = true;
    notifyListeners();

    try {
      final Task draft = Task(
        title: cleanedText,
        category: CategoryCopy.normalize(category ?? _draftCategory),
      );
      final Task added = await _taskService.addTask(draft);
      _items.insert(0, added);
    } catch (_) {
      _isAdding = false;
      notifyListeners();
      return false;
    }

    _isAdding = false;
    notifyListeners();
    return true;
  }

  Future<void> toggleCompletion(String id) async {
    if (_busyItemIds.contains(id)) return;
    final int index = _items.indexWhere((Task item) => item.id == id);
    if (index == -1) return;

    _busyItemIds.add(id);
    notifyListeners();

    try {
      final bool newStatus = !_items[index].isCompleted;
      final Task updated = await _taskService.updateTaskCompletion(id, newStatus);
      // Keep existing subTasks
      _items[index] = updated.copyWith(subTasks: _items[index].subTasks);
    } catch (_) {}

    _busyItemIds.remove(id);
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    if (_busyItemIds.contains(id)) return;
    _busyItemIds.add(id);
    notifyListeners();

    try {
      await _taskService.deleteTask(id);
      _items.removeWhere((Task item) => item.id == id);
    } catch (_) {}

    _busyItemIds.remove(id);
    notifyListeners();
  }

  Future<bool> updateTaskDetails({
    required String id,
    required String title,
    required String description,
    required String category,
  }) async {
    final int index = _items.indexWhere((Task item) => item.id == id);
    if (index == -1) return false;

    final String cleanTitle = title.trim();
    if (cleanTitle.isEmpty || cleanTitle.length > AppConstants.maxTodoLength) return false;
    if (description.length > AppConstants.maxDescriptionLength) return false;

    final String cleanCategory = CategoryCopy.normalize(category);
    if (cleanCategory.isEmpty || !_categories.contains(cleanCategory)) return false;

    try {
      final updatedTask = _items[index].copyWith(
        title: cleanTitle,
        description: description.trim(),
        category: cleanCategory,
      );
      final savedTask = await _taskService.updateTask(updatedTask);
      _items[index] = savedTask.copyWith(subTasks: _items[index].subTasks);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addSubTask({
    required String taskId,
    required String title,
  }) async {
    final int index = _items.indexWhere((Task item) => item.id == taskId);
    if (index == -1) return false;

    final String cleanTitle = title.trim();
    if (cleanTitle.isEmpty || cleanTitle.length > AppConstants.maxSubTaskLength) return false;

    try {
      final draft = Task(title: cleanTitle, parentId: taskId);
      final added = await _taskService.addTask(draft);
      
      final List<Task> updatedSubTasks = List<Task>.from(_items[index].subTasks)..add(added);
      _items[index] = _items[index].copyWith(subTasks: updatedSubTasks);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleSubTask({
    required String taskId,
    required String subTaskId,
  }) async {
    final int index = _items.indexWhere((Task item) => item.id == taskId);
    if (index == -1) return false;

    final List<Task> updatedSubTasks = List<Task>.from(_items[index].subTasks);
    final int subIndex = updatedSubTasks.indexWhere((Task sub) => sub.id == subTaskId);
    if (subIndex == -1) return false;

    try {
      final newStatus = !updatedSubTasks[subIndex].isCompleted;
      final updated = await _taskService.updateTaskCompletion(subTaskId, newStatus);
      updatedSubTasks[subIndex] = updated;
      _items[index] = _items[index].copyWith(subTasks: updatedSubTasks);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSubTask({
    required String taskId,
    required String subTaskId,
  }) async {
    final int index = _items.indexWhere((Task item) => item.id == taskId);
    if (index == -1) return false;

    try {
      await _taskService.deleteTask(subTaskId);
      final List<Task> updatedSubTasks = List<Task>.from(_items[index].subTasks)
        ..removeWhere((Task sub) => sub.id == subTaskId);
      _items[index] = _items[index].copyWith(subTasks: updatedSubTasks);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
