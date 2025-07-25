import 'package:flutter/material.dart';
import 'package:money_manager/core/widgets/category_icon.dart';
import 'package:intl/intl.dart';

final currencyFormatVND = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

class BudgetWarningDialog {
  static void show(BuildContext context, List<dynamic> warnings) {
    if (warnings.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Budget Warnings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 340,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: warnings.length,
              separatorBuilder: (_, __) => const Divider(height: 18),
              itemBuilder: (context, i) {
                final w = warnings[i];
                final color = w.percent >= 1.0 ? Colors.red : Colors.orange;
                final format = currencyFormatVND;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.13),
                      child: CategoryIcon(category: w.category, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.category[0].toUpperCase() +
                                w.category.substring(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            w.percent >= 1.0
                                ? 'Above limit!'
                                : 'Reached more than 80% of limit',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Expensed: ${format.format(w.spent)} / ${format.format(w.limit)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
