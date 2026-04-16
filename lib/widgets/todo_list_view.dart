/// Role: Displays the animated list of tasks and delegates row-level actions.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/task.dart';
import 'package:to_do_flutter/widgets/todo_list_item.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TodoListView extends StatelessWidget {
  const TodoListView({
    required this.items,
    required this.busyIds,
    required this.onToggle,
    required this.onDelete,
    required this.onGenerateAI,
    required this.onTapTask,
    super.key,
  });

  final List<Task> items;
  final Set<String> busyIds;
  final Future<void> Function(String id) onToggle;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function(String id) onGenerateAI;
  final void Function(Task item) onTapTask;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final Task item = items[index];
        final int delay = (index * AppConstants.itemEntranceAnimationStepMs)
            .clamp(0, AppConstants.longAnimationMs + 240);

        return TodoListItem(
          key: ValueKey<String>(item.id!),
          item: item,
          isBusy: busyIds.contains(item.id),
          onToggle: () => onToggle(item.id!),
          onDelete: () => onDelete(item.id!),
          onGenerateAI: () => onGenerateAI(item.id!),
          onTap: () => onTapTask(item),
        ).animate().fade(duration: 400.ms, delay: delay.ms).slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}
