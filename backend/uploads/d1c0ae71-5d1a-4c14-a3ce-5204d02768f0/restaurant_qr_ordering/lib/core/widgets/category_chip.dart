import 'package:flutter/material.dart';

/// Filter chip used in the horizontal category list.
class CategoryChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      ),
    );
  }
}
