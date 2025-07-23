import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String? category;
  final Color? color;
  final double size;
  const CategoryIcon({
    Key? key,
    required this.category,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(_categoryIconForFilter(category), color: color, size: size);
  }
}

IconData _categoryIconForFilter(String? category) {
  switch (category) {
    case 'salary':
      return Icons.attach_money;
    case 'freelance':
      return Icons.laptop_mac;
    case 'investment':
      return Icons.trending_up;
    case 'business':
      return Icons.business_center;
    case 'otherIncome':
      return Icons.account_balance_wallet;
    case 'food':
      return Icons.restaurant_menu;
    case 'transportation':
      return Icons.directions_car;
    case 'shopping':
      return Icons.shopping_bag;
    case 'entertainment':
      return Icons.movie;
    case 'healthcare':
      return Icons.local_hospital;
    case 'education':
      return Icons.school;
    case 'housing':
      return Icons.home;
    case 'utilities':
      return Icons.lightbulb;
    case 'insurance':
      return Icons.security;
    case 'otherExpense':
      return Icons.more_horiz;
    default:
      return Icons.category;
  }
}
