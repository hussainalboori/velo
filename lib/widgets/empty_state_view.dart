/// Role: Displays a polished empty-state prompt when there are no tasks.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.title = AppStrings.emptyTitle,
    this.message = AppStrings.emptyMessage,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
