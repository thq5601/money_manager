import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_colors.dart';

class AppBarActions {
  static List<Widget> getActions({
    required int currentIndex,
    required Function()? onStartSearch,
    required Function()? onShowFilterDialog,
    required Function()? onRefreshAnalytics,
    required List<dynamic> budgetWarnings,
    required Function(List<dynamic>) onShowBudgetWarningsDialog,
  }) {
    if (currentIndex == 1) {
      return [
        IconButton(
          onPressed: onStartSearch,
          icon: const Icon(Icons.search),
          color: AppColors.textSecondary,
        ),
        IconButton(
          onPressed: onShowFilterDialog,
          icon: const Icon(Icons.filter_list),
          color: AppColors.textSecondary,
        ),
      ];
    }
    if (currentIndex == 2) {
      return [
        IconButton(
          onPressed: onRefreshAnalytics,
          icon: const Icon(Icons.refresh),
          color: AppColors.textSecondary,
        ),
      ];
    }
    if (currentIndex == 0) {
      return [
        Stack(
          children: [
            IconButton(
              onPressed: budgetWarnings.isNotEmpty
                  ? () => onShowBudgetWarningsDialog(budgetWarnings)
                  : null,
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.textSecondary,
            ),
            if (budgetWarnings.isNotEmpty)
              const Positioned(
                right: 8,
                top: 8,
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ];
    }
    return const [];
  }
}
