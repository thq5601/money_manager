import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/core/widgets/category_icon.dart';

class FilterDialog extends StatefulWidget {
  final Set<String> initialCategories;
  final String? initialType;
  const FilterDialog({
    Key? key,
    required this.initialCategories,
    this.initialType,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Set<String> tempCategories;
  String? tempType;

  @override
  void initState() {
    super.initState();
    tempCategories = {...widget.initialCategories};
    tempType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = AppColors.categoryColors.keys.toList()..sort();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.filter_list, color: AppColors.green, size: 26),
                SizedBox(width: 10),
                Text(
                  'Filter Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Categories',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final cat in sortedCategories)
                    ListTile(
                      leading: CategoryIcon(
                        category: cat,
                        color: AppColors.categoryColors[cat],
                        size: 24,
                      ),
                      title: Text(cat[0].toUpperCase() + cat.substring(1)),
                      trailing: Checkbox(
                        value: tempCategories.contains(cat),
                        activeColor: AppColors.green,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              tempCategories.add(cat);
                            } else {
                              tempCategories.remove(cat);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (tempCategories.contains(cat)) {
                            tempCategories.remove(cat);
                          } else {
                            tempCategories.add(cat);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Divider(height: 24),
            const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(16),
                isSelected: [
                  tempType == null,
                  tempType == 'Income',
                  tempType == 'Expense',
                ],
                onPressed: (index) {
                  setState(() {
                    if (index == 0) tempType = null;
                    if (index == 1) tempType = 'Income';
                    if (index == 2) tempType = 'Expense';
                  });
                },
                color: AppColors.textSecondary,
                selectedColor: Colors.white,
                fillColor: AppColors.green,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('All'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Income'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Expense'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'categories': <String>{},
                      'type': null,
                    });
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, {
                    'categories': tempCategories,
                    'type': tempType,
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
