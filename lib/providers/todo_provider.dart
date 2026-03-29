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
  final List<String> _categories =
      List<String>.from(AppConstants.defaultCategories);
  final Set<String> _busyItemIds = <String>{};

  bool _isLoading = true;
  bool _isAdding = false;
  TodoFilter _selectedFilter = TodoFilter.all;
  String _draftCategory = AppConstants.defaultCategories.first;

  UnmodifiableListView<TodoItem> get items =>
      UnmodifiableListView<TodoItem>(_items);
  UnmodifiableListView<String> get categories =>
      UnmodifiableListView<String>(_categories);
  UnmodifiableSetView<String> get busyItemIds =>
      UnmodifiableSetView<String>(_busyItemIds);

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  TodoFilter get selectedFilter => _selectedFilter;
  String get draftCategory => _draftCategory;

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

  void setDraftCategory(String category) {
    if (_draftCategory == category) {
      return;
    }

    _draftCategory = category;
    notifyListeners();
  }

  bool addCategory(String rawName) {
    final String normalized = CategoryCopy.normalize(rawName);
    if (normalized.isEmpty) {
      return false;
    }

    if (_categories.contains(normalized)) {
      return false;
    }

    _categories.add(normalized);
    _categories.sort();
    _draftCategory = normalized;
    _persistCategories();
    notifyListeners();
    return true;
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> rawCategories =
          prefs.getStringList(AppConstants.categoriesStorageKey) ??
              AppConstants.defaultCategories;
      _categories
        ..clear()
        ..addAll({
          ...rawCategories
              .map((String category) => CategoryCopy.normalize(category))
              .where((String category) => category.isNotEmpty),
        });
      if (_categories.isEmpty) {
        _categories.addAll(AppConstants.defaultCategories);
      }

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

      if (!_categories.contains(_draftCategory)) {
        _draftCategory = _categories.first;
      }
    } catch (_) {
      _items.clear();
      _categories
        ..clear()
        ..addAll(AppConstants.defaultCategories);
      _draftCategory = _categories.first;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTodo(String text, {String? category}) async {
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
      category: CategoryCopy.normalize(category ?? _draftCategory),
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

  Future<void> _persistCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.categoriesStorageKey, _categories);
  }
}
