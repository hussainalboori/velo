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
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 42,
                color: Color(0xFF0F4C5C),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
