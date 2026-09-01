/// Role: Hosts the primary to-do experience with input, list state, and feedback.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/task.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';
import 'package:to_do_flutter/screens/paywall_screen.dart';
import 'package:to_do_flutter/screens/settings_screen.dart';
import 'package:to_do_flutter/services/task_service.dart';
import 'package:to_do_flutter/widgets/empty_state_view.dart';
import 'package:to_do_flutter/screens/task_detail_screen.dart';
import 'package:to_do_flutter/widgets/todo_filter_bar.dart';
import 'package:to_do_flutter/widgets/todo_input_field.dart';
import 'package:to_do_flutter/widgets/todo_list_view.dart';
import 'package:to_do_flutter/widgets/smart_banner_ad.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Returns the empty-state text for each filter mode.
  ///
  /// The UI intentionally changes its message depending on whether the user is viewing all, active, or
  /// completed tasks; this keeps the experience informative rather than static.
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
    String category,
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

  /// Creates a modal dialog for category creation and normalizes the value before passing it upstream.
  ///
  /// Validation is intentionally repeated here because the UI should provide immediate feedback before the
  /// provider mutates app state. This reduces accidental duplicate or empty categories.
  Future<void> _showAddCategoryDialog() async {
    String draftCategory = '';

    final String? rawCategory = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.addCategoryTitle),
          content: TextField(
            textInputAction: TextInputAction.done,
            autofocus: true,
            onChanged: (String value) {
              draftCategory = value;
            },
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(draftCategory);
            },
            decoration: const InputDecoration(
              hintText: AppStrings.addCategoryHint,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.addCategoryCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(draftCategory),
              child: const Text(AppStrings.addCategoryConfirm),
            ),
          ],
        );
      },
    );

    if (!mounted || rawCategory == null) {
      return;
    }

    final TodoProvider provider = context.read<TodoProvider>();

    final String normalized = CategoryCopy.normalize(rawCategory);
    if (normalized.isEmpty) {
      _showSnackBar(context, AppStrings.addCategoryErrorEmpty);
      return;
    }

    if (normalized.length > AppConstants.maxCategoryLength) {
      _showSnackBar(context, AppStrings.addCategoryErrorTooLong);
      return;
    }

    final bool didAdd = provider.addCategory(normalized);
    _showSnackBar(
      context,
      didAdd
          ? AppStrings.addCategorySuccess
          : AppStrings.addCategoryErrorExists,
    );
  }

  Future<void> _deleteCategory(BuildContext context, String category) async {
    final bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(AppStrings.deleteCategoryTitle),
              content: Text(
                '${CategoryCopy.label(category)}. ${AppStrings.deleteCategoryMessage}',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(AppStrings.addCategoryCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text(AppStrings.deleteCategoryConfirm),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !context.mounted) {
      return;
    }

    final TodoProvider provider = context.read<TodoProvider>();
    final RemoveCategoryResult result = await provider.removeCategory(category);

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case RemoveCategoryResult.removed:
        _showSnackBar(context, AppStrings.deleteCategorySuccess);
        break;
      case RemoveCategoryResult.lastCategory:
        _showSnackBar(context, AppStrings.deleteCategoryErrorLast);
        break;
      case RemoveCategoryResult.notFound:
        _showSnackBar(context, AppStrings.deleteCategoryErrorMissing);
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  void _openTaskDetails(BuildContext context, Task item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskDetailScreen(taskId: item.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Consumer<TodoProvider>(
              builder: (BuildContext context, TodoProvider provider, _) {
                final List<Task> filteredItems = provider.filteredItems;
                final ({String title, String message}) emptyCopy =
                    _emptyCopyForFilter(provider.selectedFilter);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.appTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_outlined, color: Color(0xFF00F2FF)),
                          tooltip: 'Settings',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.appSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    TodoInputField(
                      isLoading: provider.isAdding,
                      categories: provider.categories,
                      selectedCategory: provider.draftCategory,
                      onCategoryChanged: provider.setDraftCategory,
                      onAddCategory: _showAddCategoryDialog,
                      onDeleteCategory: (String category) =>
                          _deleteCategory(context, category),
                      onSubmit: (String value, String category) =>
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
                                      onGenerateAI: (String id) async {
                                        final taskItem = context.read<TodoProvider>().taskById(id);
                                        if (taskItem == null) return;
                                        
                                        _showSnackBar(context, 'AI is thinking...');
                                        try {
                                          await TaskService().generateSubtasks(id, taskItem.title);
                                          if (context.mounted) {
                                            _showSnackBar(context, 'Sub-tasks generated!');
                                            await context.read<TodoProvider>().reloadSubTasks(id);
                                          }
                                        } catch (e) {
                                          debugPrint('AI Error: $e');
                                          if (context.mounted) {
                                            if (e.toString().contains('OUT_OF_TOKENS')) {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (sheetContext) => PaywallScreen(
                                                  onRewardSuccess: () async {
                                                    _showSnackBar(context, 'Generating your reward...');
                                                    await Future<void>.delayed(const Duration(milliseconds: 500));
                                                    try {
                                                      await TaskService().generateSubtasks(id, taskItem.title);
                                                      if (context.mounted) {
                                                        _showSnackBar(context, 'Sub-tasks generated!');
                                                        await context.read<TodoProvider>().reloadSubTasks(id);
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) _showSnackBar(context, 'Error: $e');
                                                    }
                                                  },
                                                ),
                                              );
                                            } else {
                                              _showSnackBar(context, 'Error: $e');
                                            }
                                          }
                                        }
                                      },
                                      onTapTask: (Task item) =>
                                          _openTaskDetails(context, item),
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
      bottomNavigationBar: !context.watch<TodoProvider>().isPro 
          ? const SmartBannerAd() 
          : const SizedBox.shrink(),
    );
  }
}
