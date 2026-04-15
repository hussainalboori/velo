/// Role: Provides category filters (All, Active, Completed) with task counts.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/providers/todo_provider.dart';

class TodoFilterBar extends StatelessWidget {
  const TodoFilterBar({
    required this.selected,
    required this.allCount,
    required this.activeCount,
    required this.completedCount,
    required this.onChanged,
    super.key,
  });

  final TodoFilter selected;
  final int allCount;
  final int activeCount;
  final int completedCount;
  final ValueChanged<TodoFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _FilterChip(
            label: AppStrings.filterAll,
            count: allCount,
            selected: selected == TodoFilter.all,
            onTap: () => onChanged(TodoFilter.all),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: AppStrings.filterActive,
            count: activeCount,
            selected: selected == TodoFilter.active,
            onTap: () => onChanged(TodoFilter.active),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: AppStrings.filterCompleted,
            count: completedCount,
            selected: selected == TodoFilter.completed,
            onTap: () => onChanged(TodoFilter.completed),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        selected ? const Color(0xFF0F4C5C) : const Color(0x330F4C5C);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppConstants.baseAnimationMs),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: selected ? const Color(0xFF0F4C5C) : const Color(0xFFF3F4F6),
            boxShadow: selected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x330F4C5C),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? Colors.white : const Color(0xFF4B5563),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: AppConstants.baseAnimationMs),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: selected
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0x140F4C5C),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            selected ? Colors.white : const Color(0xFF0F4C5C),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
