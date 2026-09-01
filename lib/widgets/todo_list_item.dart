/// Role: Renders one animated to-do row with completion and delete actions.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/task.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    // A completed item is visually distinguished with a subtle green border so users can scan their queue
    // quickly without losing the original dark theme language.
    final Color borderColor =
        item.isCompleted ? const Color(0x7A4CAF50) : Colors.transparent;

    Widget widgetTree = AnimatedOpacity(
      duration: const Duration(milliseconds: AppConstants.baseAnimationMs),
      opacity: isBusy ? 0.4 : 1.0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppConstants.baseAnimationMs),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF161616),
          border: Border.all(color: borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
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
                                color: Color(0xFF00F2FF),
                                size: 28,
                              )
                            : const Icon(
                                Icons.radio_button_unchecked_rounded,
                                key: ValueKey<String>('open'),
                                color: Color(0xFF5E5E5E),
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
                                    ? const Color(0xFF757575)
                                    : const Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2E2E), // Solid dark grey to anchor tag
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            CategoryCopy.label(item.category),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFF00F2FF), // Neon teal text overrides
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- Trailing Actions ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const ValueKey<String>('item_ai'),
                        tooltip: 'Generate Sub-tasks with AI',
                        onPressed: isBusy ? null : onGenerateAI,
                        icon: isBusy
                            ? const Icon(Icons.auto_awesome, color: Color(0xFF00F2FF))
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 1000.ms, color: Colors.white)
                                .scaleXY(end: 1.1, duration: 500.ms, curve: Curves.easeInOutSine)
                                .then()
                                .scaleXY(end: 1 / 1.1, duration: 500.ms, curve: Curves.easeInOutSine)
                            : const Icon(Icons.auto_awesome, color: Color(0xFF00F2FF)),
                      ),
                      IconButton(
                        key: const ValueKey<String>('item_delete'),
                        tooltip: AppStrings.deleteTooltip,
                        onPressed: isBusy ? null : onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF5E5E5E)), // Dimmer so it doesn't distract
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (item.isCompleted) {
      widgetTree = widgetTree.animate()
          .shimmer(duration: 500.ms, color: const Color(0x334CAF50))
          .scaleXY(begin: 1.02, end: 1.0, duration: 300.ms, curve: Curves.easeOutBack);
    }
    
    return widgetTree;
  }
}
