import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:money_manager/features/analytics/piechart.dart';
import 'package:money_manager/features/analytics/summary_card.dart';
import 'package:money_manager/core/widgets/category_icon.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool showExpense = true;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view analytics.'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        // Filter transactions to only those in the selected month
        final monthDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final ts = data['dateCreated'];
          if (ts is Timestamp) {
            final date = ts.toDate();
            return date.year == _selectedMonth.year &&
                date.month == _selectedMonth.month;
          }
          return false;
        }).toList();
        double totalIncome = 0;
        double totalExpense = 0;
        final Map<String, double> incomeByCategory = {};
        final Map<String, double> expenseByCategory = {};
        for (final doc in monthDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['amount'] ?? 0).toDouble();
          final category = data['category'] ?? 'other';
          if (amount > 0) {
            totalIncome += amount;
            incomeByCategory[category] =
                (incomeByCategory[category] ?? 0) + amount;
          } else {
            totalExpense += amount;
            expenseByCategory[category] =
                (expenseByCategory[category] ?? 0) + amount.abs();
          }
        }
        final netBalance = totalIncome - totalExpense.abs();
        final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
        final expensePieData = <String, double>{};
        expenseByCategory.forEach((cat, amt) {
          if (amt > 0)
            expensePieData[cat[0].toUpperCase() + cat.substring(1)] = amt;
        });
        final incomePieData = <String, double>{};
        incomeByCategory.forEach((cat, amt) {
          if (amt > 0)
            incomePieData[cat[0].toUpperCase() + cat.substring(1)] = amt;
        });
        final colorMap = <String, Color>{};
        expenseByCategory.forEach((cat, _) {
          colorMap[cat[0].toUpperCase() + cat.substring(1)] =
              AppColors.categoryColors[cat] ?? Colors.grey;
        });
        incomeByCategory.forEach((cat, _) {
          colorMap[cat[0].toUpperCase() + cat.substring(1)] =
              AppColors.categoryColors[cat] ?? Colors.grey;
        });
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with month selector
              Row(
                children: [
                  const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await showMonthPicker(
                        context: context,
                        initialDate: _selectedMonth,
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedMonth = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_selectedMonth.month.toString().padLeft(2, '0')}/${_selectedMonth.year}',
                            style: const TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Net Balance Summary with glassmorphism
              Container(
                decoration: BoxDecoration(
                  color: netBalance < 0
                      ? AppColors.red.withOpacity(0.08)
                      : AppColors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (netBalance < 0 ? AppColors.red : AppColors.green)
                          .withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Net Balance',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: netBalance < 0
                              ? AppColors.red
                              : AppColors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        format.format(netBalance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: netBalance < 0
                              ? AppColors.red
                              : AppColors.green,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Income & Expenses Row
              Row(
                children: [
                  Expanded(
                    child: AnalyticsSummaryCard(
                      label: 'Income',
                      amount: totalIncome,
                      color: AppColors.green,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnalyticsSummaryCard(
                      label: 'Expenses',
                      amount: totalExpense.abs(),
                      color: AppColors.red,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Switch button for pie chart
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        showExpense = true;
                      });
                    },
                    icon: Icon(
                      Icons.pie_chart_rounded,
                      color: showExpense ? AppColors.red : Colors.grey,
                    ),
                    label: Text(
                      'Expense Breakdown',
                      style: TextStyle(
                        color: showExpense ? AppColors.red : Colors.grey,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: showExpense
                          ? AppColors.red.withOpacity(0.08)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        showExpense = false;
                      });
                    },
                    icon: Icon(
                      Icons.pie_chart_rounded,
                      color: !showExpense ? AppColors.green : Colors.grey,
                    ),
                    label: Text(
                      'Income Breakdown',
                      style: TextStyle(
                        color: !showExpense ? AppColors.green : Colors.grey,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: !showExpense
                          ? AppColors.green.withOpacity(0.08)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: showExpense && expensePieData.isNotEmpty
                    ? AnalyticsPieChart(
                        key: const ValueKey('expense'),
                        chartKey: const ValueKey('expense'),
                        label: 'Expense Breakdown',
                        icon: Icons.pie_chart_rounded,
                        iconColor: AppColors.red,
                        dataMap: expensePieData,
                        colorMap: colorMap,
                      )
                    : !showExpense && incomePieData.isNotEmpty
                    ? AnalyticsPieChart(
                        key: const ValueKey('income'),
                        chartKey: const ValueKey('income'),
                        label: 'Income Breakdown',
                        icon: Icons.pie_chart_rounded,
                        iconColor: AppColors.green,
                        dataMap: incomePieData,
                        colorMap: colorMap,
                      )
                    : const SizedBox.shrink(),
              ),
              Row(
                children: const [
                  Icon(Icons.trending_up, color: AppColors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Income by Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...incomeByCategory.entries.map(
                (e) => _categoryTile(e.key, e.value, AppColors.green),
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Icon(Icons.trending_down, color: AppColors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Expenses by Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...expenseByCategory.entries.map(
                (e) => _categoryTile(e.key, e.value, AppColors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(String label, double amount, Color color, IconData icon) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              format.format(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile(String category, double amount, Color color) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.13),
        child: CategoryIcon(category: category, color: color),
      ),
      title: Text(category[0].toUpperCase() + category.substring(1)),
      trailing: Text(
        format.format(amount),
        style: TextStyle(fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
}) async {
  DateTime? selected;
  await showDialog(
    context: context,
    builder: (context) {
      int year = initialDate.year;
      int month = initialDate.month;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          if (month == 1) {
                            year--;
                            month = 12;
                          } else {
                            month--;
                          }
                        });
                      },
                    ),
                    Text(
                      '$month/$year',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          if (month == 12) {
                            year++;
                            month = 1;
                          } else {
                            month++;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final now = DateTime.now();
                        selected = DateTime(now.year, now.month);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        selected = DateTime(year, month);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return selected;
}
