/// Role: Renders one animated to-do row with completion and delete actions.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/task.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    required this.item,
    required this.isBusy,
    required this.onToggle,
    required this.onDelete,
    required this.onGenerateAI,
    required this.onTap,
    super.key,
  });

  final Task item;
  final bool isBusy;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onGenerateAI;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        item.isCompleted ? const Color(0x7A4CAF50) : Colors.transparent;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: AppConstants.baseAnimationMs),
      opacity: isBusy ? 0.4 : 1.0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppConstants.baseAnimationMs),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: item.isCompleted ? const Color(0xFFE9F8EC) : Colors.white,
          border: Border.all(color: borderColor),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Leading Checkbox ---
                  IgnorePointer(
                    ignoring: isBusy,
                    child: IconButton(
                      tooltip: AppStrings.completeSemantic,
                      onPressed: onToggle,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: AppConstants.baseAnimationMs),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: item.isCompleted
                            ? const Icon(
                                Icons.check_circle_rounded,
                                key: ValueKey<String>('done'),
                                color: Color(0xFF2E7D32),
                                size: 28,
                              )
                            : const Icon(
                                Icons.radio_button_unchecked_rounded,
                                key: ValueKey<String>('open'),
                                color: Color(0xFF0F4C5C),
                                size: 28,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- Center Content ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                decoration:
                                    item.isCompleted ? TextDecoration.lineThrough : null,
                                color: item.isCompleted
                                    ? const Color(0xFF607D68)
                                    : const Color(0xFF1D2939),
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x140F4C5C),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            CategoryCopy.label(item.category),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFF0F4C5C),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- Trailing Actions ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: AppConstants.baseAnimationMs),
                    child: isBusy
                        ? const SizedBox(
                            key: ValueKey<String>('item_loading'),
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                key: const ValueKey<String>('item_ai'),
                                tooltip: 'Generate Sub-tasks with AI',
                                onPressed: onGenerateAI,
                                icon: const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
                              ),
                              IconButton(
                                key: const ValueKey<String>('item_delete'),
                                tooltip: AppStrings.deleteTooltip,
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.black54),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
