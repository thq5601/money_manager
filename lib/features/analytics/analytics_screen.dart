import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/features/analytics/piechart.dart';
import 'package:money_manager/features/analytics/summary_card.dart';
import 'package:money_manager/core/widgets/category_icon.dart';
import 'dart:ui';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _analyticsMode = 'Day'; // 'Year', 'Month', 'Day'
  late int _selectedYear;
  late int _selectedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDate = DateTime(now.year, now.month, now.day);
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
        // Filter transactions based on analytics mode
        List<QueryDocumentSnapshot> filteredDocs;
        if (_analyticsMode == 'Year') {
          filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = data['dateCreated'];
            if (ts is Timestamp) {
              final date = ts.toDate();
              return date.year == _selectedYear;
            }
            return false;
          }).toList();
        } else if (_analyticsMode == 'Month') {
          filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = data['dateCreated'];
            if (ts is Timestamp) {
              final date = ts.toDate();
              return date.year == _selectedYear && date.month == _selectedMonth;
            }
            return false;
          }).toList();
        } else {
          filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final ts = data['dateCreated'];
            if (ts is Timestamp) {
              final date = ts.toDate();
              return date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
            }
            return false;
          }).toList();
        }
        double totalIncome = 0;
        double totalExpense = 0;
        final Map<String, double> incomeByCategory = {};
        final Map<String, double> expenseByCategory = {};
        for (final doc in filteredDocs) {
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
          if (amt > 0) {
            expensePieData[cat[0].toUpperCase() + cat.substring(1)] = amt;
          }
        });
        final incomePieData = <String, double>{};
        incomeByCategory.forEach((cat, amt) {
          if (amt > 0) {
            incomePieData[cat[0].toUpperCase() + cat.substring(1)] = amt;
          }
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
              // Header with Overview and analytics icon
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.analytics_rounded,
                    color: AppColors.green,
                    size: 32,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Analytics filter UI
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    color: AppColors.cardBackground,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          DropdownButton<String>(
                            value: _analyticsMode,
                            items: const [
                              DropdownMenuItem(
                                value: 'Year',
                                child: Text('Year'),
                              ),
                              DropdownMenuItem(
                                value: 'Month',
                                child: Text('Month'),
                              ),
                              DropdownMenuItem(
                                value: 'Day',
                                child: Text('Day'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _analyticsMode = val);
                            },
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            dropdownColor: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          if (_analyticsMode == 'Year')
                            DropdownButton<int>(
                              value: _selectedYear,
                              items:
                                  List.generate(
                                        12,
                                        (i) => DateTime.now().year - 6 + i,
                                      )
                                      .map(
                                        (y) => DropdownMenuItem(
                                          value: y,
                                          child: Text(y.toString()),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedYear = val);
                              },
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              dropdownColor: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            )
                          else if (_analyticsMode == 'Month')
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                final picked = await showMonthPicker(
                                  context: context,
                                  initialDate: DateTime(
                                    _selectedYear,
                                    _selectedMonth,
                                  ),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedYear = picked.year;
                                    _selectedMonth = picked.month;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear',
                                      style: const TextStyle(
                                        color: AppColors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_analyticsMode == 'Day')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedDate,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: AppColors.green,
                                              onPrimary: Colors.white,
                                              onSurface: AppColors.textPrimary,
                                            ),
                                            dialogBackgroundColor:
                                                AppColors.cardBackground,
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: AppColors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_selectedDate.day.toString().padLeft(2, '0')}/'
                                          '${_selectedDate.month.toString().padLeft(2, '0')}/'
                                          '${_selectedDate.year}',
                                          style: const TextStyle(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Net Balance Summary with glassmorphism and animated number
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              (netBalance < 0 ? AppColors.red : AppColors.green)
                                  .withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (netBalance < 0
                                          ? AppColors.red
                                          : AppColors.green)
                                      .withOpacity(0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 28,
                            horizontal: 18,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 32,
                                color: netBalance < 0
                                    ? AppColors.red
                                    : AppColors.green,
                              ),
                              const SizedBox(height: 8),
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
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: netBalance),
                                duration: const Duration(milliseconds: 900),
                                builder: (context, value, child) => Text(
                                  format.format(value),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: netBalance < 0
                                        ? AppColors.red
                                        : AppColors.green,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Income & Expenses Row with progress bars
              Builder(
                builder: (context) {
                  final total = totalIncome + totalExpense.abs();
                  final incomeProgress = total > 0 ? totalIncome / total : 0.5;
                  final expenseProgress = total > 0
                      ? totalExpense.abs() / total
                      : 0.5;
                  return Row(
                    children: [
                      Expanded(
                        child: AnalyticsSummaryCard(
                          label: 'Income',
                          amount: totalIncome,
                          color: AppColors.green,
                          icon: Icons.arrow_downward,
                          progress: incomeProgress,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnalyticsSummaryCard(
                          label: 'Expenses',
                          amount: totalExpense.abs(),
                          color: AppColors.red,
                          icon: Icons.arrow_upward,
                          progress: expenseProgress,
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Only show breakdown and by category if there are transactions
              if (filteredDocs.isNotEmpty) ...[
                const SizedBox(height: 32),
                // Switch button for pie chart
                AnalyticsPieSection(
                  expensePieData: expensePieData,
                  incomePieData: incomePieData,
                  colorMap: colorMap,
                ),
                Row(
                  children: const [
                    Icon(Icons.trending_up, color: AppColors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Income by Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...expenseByCategory.entries.map(
                  (e) => _categoryTile(e.key, e.value, AppColors.red),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _categoryTile(String category, double amount, Color color) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.13),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Select Month'),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Year: '),
                    DropdownButton<int>(
                      value: year,
                      items: List.generate(12, (i) => year - 6 + i)
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text(y.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => year = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Month grid
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(12, (i) {
                    final isSelected = (i + 1) == month;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.green
                            : AppColors.paleGrey,
                        foregroundColor: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isSelected ? 4 : 0,
                      ),
                      onPressed: () => setState(() => month = i + 1),
                      child: Text(
                        [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ][i],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
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
                        backgroundColor: AppColors.paleGrey,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        selected = DateTime(year, month);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

class AnalyticsPieSection extends StatefulWidget {
  final Map<String, double> expensePieData;
  final Map<String, double> incomePieData;
  final Map<String, Color> colorMap;

  const AnalyticsPieSection({
    Key? key,
    required this.expensePieData,
    required this.incomePieData,
    required this.colorMap,
  }) : super(key: key);

  @override
  State<AnalyticsPieSection> createState() => _AnalyticsPieSectionState();
}

class _AnalyticsPieSectionState extends State<AnalyticsPieSection> {
  bool showExpense = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: showExpense && widget.expensePieData.isNotEmpty
              ? AnalyticsPieChart(
                  key: const ValueKey('expense'),
                  chartKey: const ValueKey('expense'),
                  label: 'Expense Breakdown',
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppColors.red,
                  dataMap: widget.expensePieData,
                  colorMap: widget.colorMap,
                )
              : !showExpense && widget.incomePieData.isNotEmpty
              ? AnalyticsPieChart(
                  key: const ValueKey('income'),
                  chartKey: const ValueKey('income'),
                  label: 'Income Breakdown',
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppColors.green,
                  dataMap: widget.incomePieData,
                  colorMap: widget.colorMap,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
