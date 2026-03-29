/// Role: Centralizes app-wide constants, keys, and all user-facing copy.
import 'package:to_do_flutter/models/todo_item.dart';

class AppConstants {
  static const String todosStorageKey = 'todos_storage_key_v1';

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

  static const String categoryPersonal = 'Personal';
  static const String categoryWork = 'Work';
  static const String categoryStudy = 'Study';
}

class CategoryCopy {
  static String label(TodoCategory category) {
    switch (category) {
      case TodoCategory.personal:
        return AppStrings.categoryPersonal;
      case TodoCategory.work:
        return AppStrings.categoryWork;
      case TodoCategory.study:
        return AppStrings.categoryStudy;
    }
  }
}
