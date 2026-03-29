/// Role: Manages to-do state, persistence, and user interactions via Provider.
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/todo_item.dart';

enum TodoFilter {
  all,
  active,
  completed,
}

class TodoProvider extends ChangeNotifier {
  final List<TodoItem> _items = <TodoItem>[];
  final Set<String> _busyItemIds = <String>{};

  bool _isLoading = true;
  bool _isAdding = false;
  TodoFilter _selectedFilter = TodoFilter.all;
  TodoCategory _draftCategory = TodoCategory.personal;

  UnmodifiableListView<TodoItem> get items =>
      UnmodifiableListView<TodoItem>(_items);
  UnmodifiableSetView<String> get busyItemIds =>
      UnmodifiableSetView<String>(_busyItemIds);

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  TodoFilter get selectedFilter => _selectedFilter;
  TodoCategory get draftCategory => _draftCategory;

  int get activeCount =>
      _items.where((TodoItem item) => !item.isCompleted).length;
  int get completedCount =>
      _items.where((TodoItem item) => item.isCompleted).length;

  List<TodoItem> get filteredItems {
    switch (_selectedFilter) {
      case TodoFilter.active:
        return _items.where((TodoItem item) => !item.isCompleted).toList();
      case TodoFilter.completed:
        return _items.where((TodoItem item) => item.isCompleted).toList();
      case TodoFilter.all:
        return List<TodoItem>.from(_items);
    }
  }

  bool isItemBusy(String id) => _busyItemIds.contains(id);

  void setFilter(TodoFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    _selectedFilter = filter;
    notifyListeners();
  }

  void setDraftCategory(TodoCategory category) {
    if (_draftCategory == category) {
      return;
    }

    _draftCategory = category;
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> rawTodos =
          prefs.getStringList(AppConstants.todosStorageKey) ?? <String>[];

      _items
        ..clear()
        ..addAll(
          rawTodos
              .map((String raw) =>
                  TodoItem.fromMap(jsonDecode(raw) as Map<String, dynamic>))
              .toList(),
        );
    } catch (_) {
      _items.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTodo(String text, {TodoCategory? category}) async {
    if (_isAdding) {
      return false;
    }

    final String cleanedText = text.trim();
    if (cleanedText.isEmpty ||
        cleanedText.length > AppConstants.maxTodoLength) {
      return false;
    }

    _isAdding = true;
    notifyListeners();

    final TodoItem item = TodoItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: cleanedText,
      createdAt: DateTime.now(),
      category: category ?? _draftCategory,
    );

    _items.insert(0, item);
    notifyListeners();

    await _persistTodos();

    _isAdding = false;
    notifyListeners();
    return true;
  }

  Future<void> toggleCompletion(String id) async {
    if (_busyItemIds.contains(id)) {
      return;
    }

    final int index = _items.indexWhere((TodoItem item) => item.id == id);
    if (index == -1) {
      return;
    }

    _busyItemIds.add(id);
    _items[index] = _items[index].copyWith(
      isCompleted: !_items[index].isCompleted,
    );
    notifyListeners();

    await _persistTodos();

    _busyItemIds.remove(id);
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    if (_busyItemIds.contains(id)) {
      return;
    }

    _busyItemIds.add(id);
    notifyListeners();

    _items.removeWhere((TodoItem item) => item.id == id);
    notifyListeners();

    await _persistTodos();

    _busyItemIds.remove(id);
    notifyListeners();
  }

  Future<void> _persistTodos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> encoded =
        _items.map((TodoItem item) => jsonEncode(item.toMap())).toList();

    await prefs.setStringList(AppConstants.todosStorageKey, encoded);
  }
}
