/// Role: Collects new to-do input with validation, loading state, and smooth transitions.
import 'package:flutter/material.dart';
import 'package:to_do_flutter/core/constants/app_constants.dart';

class TodoInputField extends StatefulWidget {
  const TodoInputField({
    required this.isLoading,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onAddCategory,
    required this.onDeleteCategory,
    required this.onSubmit,
    super.key,
  });

  final bool isLoading;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onAddCategory;
  final ValueChanged<String> onDeleteCategory;
  final Future<bool> Function(String value, String category) onSubmit;

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AppStrings.categoryLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF425466),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                onPressed: widget.onAddCategory,
                tooltip: AppStrings.addCategoryTooltip,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categories.map((String category) {
              final bool selected = widget.selectedCategory == category;
              return InputChip(
                label: Text(CategoryCopy.label(category)),
                selected: selected,
                onSelected: (_) => widget.onCategoryChanged(category),
                onDeleted: () => widget.onDeleteCategory(category),
                deleteIcon: const Icon(Icons.close_rounded, size: 18),
                deleteButtonTooltipMessage: AppStrings.deleteCategoryTooltip,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
