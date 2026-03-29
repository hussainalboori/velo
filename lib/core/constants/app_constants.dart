/// Role: Centralizes app-wide constants, keys, and all user-facing copy.
class AppConstants {
  static const String todosStorageKey = 'todos_storage_key_v1';
  static const String categoriesStorageKey = 'categories_storage_key_v1';
  static const List<String> defaultCategories = <String>[
    'personal',
    'work',
    'study',
  ];

  static const int maxTodoLength = 240;
  static const int itemEntranceAnimationStepMs = 35;
  static const int baseAnimationMs = 280;
  static const int longAnimationMs = 450;
}

class AppStrings {
  static const String appTitle = 'Momentum Tasks';
  static const String appSubtitle = 'Plan clearly. Ship confidently.';

  static const String filterAll = 'All';
  static const String filterActive = 'Active';
  static const String filterCompleted = 'Completed';

  static const String inputHint = 'What needs to get done?';
  static const String categoryLabel = 'Category';
  static const String addCategoryTooltip = 'Add category';
  static const String addCategoryTitle = 'Add Category';
  static const String addCategoryHint = 'Category name';
  static const String addCategoryCancel = 'Cancel';
  static const String addCategoryConfirm = 'Add';
  static const String addCategoryErrorEmpty = 'Category name cannot be empty.';
  static const String addCategoryErrorExists = 'Category already exists.';
  static const String addCategorySuccess = 'Category added';
  static const String deleteCategoryTooltip = 'Delete category';
  static const String deleteCategoryTitle = 'Delete Category?';
  static const String deleteCategoryMessage =
      'Tasks in this category will be moved to another category.';
  static const String deleteCategoryConfirm = 'Delete';
  static const String deleteCategorySuccess = 'Category deleted';
  static const String deleteCategoryErrorLast =
      'At least one category must remain.';
  static const String deleteCategoryErrorMissing = 'Category not found.';
  static const String addButton = 'Add';
  static const String inputErrorEmpty = 'Enter a task before adding.';
  static const String inputErrorTooLong = 'Task is too long. Keep it concise.';
  static const String snackbarAddSuccess = 'Task added';

  static const String emptyTitle = 'Nothing queued yet';
  static const String emptyMessage =
      'Capture your first task and build momentum for today.';
  static const String emptyActiveTitle = 'No active tasks';
  static const String emptyActiveMessage =
      'Everything is completed. Add a new task to keep moving.';
  static const String emptyCompletedTitle = 'No completed tasks yet';
  static const String emptyCompletedMessage =
      'Finish a task and it will appear here.';

  static const String deleteTooltip = 'Delete task';
  static const String completeSemantic = 'Toggle completion';

  static const String loadingLabel = 'Loading tasks...';
}

class CategoryCopy {
  static String normalize(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String label(String category) {
    final String normalized = normalize(category);
    if (normalized.isEmpty) {
      return 'General';
    }

    return normalized
        .split(' ')
        .map((String part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
