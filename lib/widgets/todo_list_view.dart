/// Role: Displays the animated list of tasks and delegates row-level actions.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/todo_item.dart';
import 'package:to_do_flutter/widgets/todo_list_item.dart';

class TodoListView extends StatelessWidget {
  const TodoListView({
    required this.items,
    required this.busyIds,
    required this.onToggle,
    required this.onDelete,
    required this.onTapTask,
    super.key,
  });

  final List<TodoItem> items;
  final Set<String> busyIds;
  final Future<void> Function(String id) onToggle;
  final Future<void> Function(String id) onDelete;
  final void Function(TodoItem item) onTapTask;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final TodoItem item = items[index];
        final int delay = (AppConstants.baseAnimationMs +
                (index * AppConstants.itemEntranceAnimationStepMs))
            .clamp(0, AppConstants.longAnimationMs + 240);

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: delay),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 16),
                child: child,
              ),
            );
          },
          child: TodoListItem(
            key: ValueKey<String>(item.id),
            item: item,
            isBusy: busyIds.contains(item.id),
            onToggle: () => onToggle(item.id),
            onDelete: () => onDelete(item.id),
            onTap: () => onTapTask(item),
          ),
        );
      },
    );
  }
}
