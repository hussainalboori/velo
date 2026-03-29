/// Role: Hosts the primary to-do experience with input, list state, and feedback.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/todo_item.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/widgets/empty_state_view.dart';
import 'package:to_do_flutter/widgets/todo_filter_bar.dart';
import 'package:to_do_flutter/widgets/todo_input_field.dart';
import 'package:to_do_flutter/widgets/todo_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ({String title, String message}) _emptyCopyForFilter(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.active:
        return (
          title: AppStrings.emptyActiveTitle,
          message: AppStrings.emptyActiveMessage,
        );
      case TodoFilter.completed:
        return (
          title: AppStrings.emptyCompletedTitle,
          message: AppStrings.emptyCompletedMessage,
        );
      case TodoFilter.all:
        return (title: AppStrings.emptyTitle, message: AppStrings.emptyMessage);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  Future<bool> _addTask(
    BuildContext context,
    String input,
    TodoCategory category,
  ) async {
    final TodoProvider provider = context.read<TodoProvider>();
    final String cleaned = input.trim();

    if (cleaned.isEmpty) {
      _showSnackBar(context, AppStrings.inputErrorEmpty);
      return false;
    }

    if (cleaned.length > AppConstants.maxTodoLength) {
      _showSnackBar(context, AppStrings.inputErrorTooLong);
      return false;
    }

    final bool didAdd = await provider.addTodo(cleaned, category: category);
    if (!context.mounted) {
      return didAdd;
    }

    if (didAdd) {
      _showSnackBar(context, AppStrings.snackbarAddSuccess);
    }

    return didAdd;
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF9F5EC),
              Color(0xFFE4F1F6),
              Color(0xFFD6E8D4),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Consumer<TodoProvider>(
              builder: (BuildContext context, TodoProvider provider, _) {
                final List<TodoItem> filteredItems = provider.filteredItems;
                final ({String title, String message}) emptyCopy =
                    _emptyCopyForFilter(provider.selectedFilter);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppStrings.appTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.appSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    TodoInputField(
                      isLoading: provider.isAdding,
                      selectedCategory: provider.draftCategory,
                      onCategoryChanged: provider.setDraftCategory,
                      onSubmit: (String value, TodoCategory category) =>
                          _addTask(context, value, category),
                    ),
                    const SizedBox(height: 16),
                    TodoFilterBar(
                      selected: provider.selectedFilter,
                      allCount: provider.items.length,
                      activeCount: provider.activeCount,
                      completedCount: provider.completedCount,
                      onChanged: provider.setFilter,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: provider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: AppConstants.longAnimationMs,
                              ),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: filteredItems.isEmpty
                                  ? EmptyStateView(
                                      key: ValueKey<String>('empty_state'),
                                      title: emptyCopy.title,
                                      message: emptyCopy.message,
                                    )
                                  : TodoListView(
                                      key: const ValueKey<String>('list_state'),
                                      items: filteredItems,
                                      busyIds: provider.busyItemIds,
                                      onToggle: provider.toggleCompletion,
                                      onDelete: provider.deleteTodo,
                                    ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
