import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final bool isSearching;
  final TextEditingController? searchController;
  final VoidCallback? onSearchChanged;
  final VoidCallback? onStopSearch;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.actions,
    this.isSearching = false,
    this.searchController,
    this.onSearchChanged,
    this.onStopSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSearching && searchController != null && onStopSearch != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  border: InputBorder.none,
                ),
                onChanged: (_) => onSearchChanged?.call(),
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: onStopSearch),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
