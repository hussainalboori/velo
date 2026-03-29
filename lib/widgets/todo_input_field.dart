/// Role: Collects new to-do input with validation, loading state, and smooth transitions.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';
import 'package:to_do_flutter/models/todo_item.dart';

class TodoInputField extends StatefulWidget {
  const TodoInputField({
    required this.isLoading,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSubmit,
    super.key,
  });

  final bool isLoading;
  final TodoCategory selectedCategory;
  final ValueChanged<TodoCategory> onCategoryChanged;
  final Future<bool> Function(String value, TodoCategory category) onSubmit;

  @override
  State<TodoInputField> createState() => _TodoInputFieldState();
}

class _TodoInputFieldState extends State<TodoInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Future<void> _submit() async {
    final String value = _controller.text;
    final bool didAdd = await widget.onSubmit(value, widget.selectedCategory);

    if (!mounted) {
      return;
    }

    if (didAdd) {
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.done,
                  maxLength: AppConstants.maxTodoLength,
                  buildCounter: (
                    BuildContext context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return const SizedBox.shrink();
                  },
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: AppStrings.inputHint,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: AppConstants.baseAnimationMs),
                child: widget.isLoading
                    ? const SizedBox(
                        key: ValueKey<String>('loading'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : FilledButton(
                        key: const ValueKey<String>('button'),
                        onPressed: _submit,
                        child: const Text(AppStrings.addButton),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.categoryLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF425466),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TodoCategory.values.map((TodoCategory category) {
              final bool selected = widget.selectedCategory == category;
              return ChoiceChip(
                label: Text(CategoryCopy.label(category)),
                selected: selected,
                onSelected: (_) => widget.onCategoryChanged(category),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
