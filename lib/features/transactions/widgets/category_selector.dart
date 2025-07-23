import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/core/widgets/category_icon.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onCategorySelected;
  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final cat in categories)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CategoryIcon(
                    category: cat,
                    color: AppColors.categoryColors[cat],
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(cat[0].toUpperCase() + cat.substring(1)),
                  if (selectedCategory == cat) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.categoryColors[cat],
                    ),
                  ],
                ],
              ),
              selected: selectedCategory == cat,
              selectedColor: AppColors.categoryColors[cat]?.withValues(
                alpha: 0.18,
              ),
              backgroundColor: AppColors.paleGrey,
              labelStyle: TextStyle(
                color: selectedCategory == cat
                    ? AppColors.categoryColors[cat]
                    : AppColors.textSecondary,
              ),
              shape: const StadiumBorder(),
              onSelected: (selected) {
                onCategorySelected(selected ? cat : null);
              },
            ),
          ),
      ],
    );
  }
}
