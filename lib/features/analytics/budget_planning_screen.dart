import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_manager/core/services/budget_service.dart';
import 'package:money_manager/core/models/budget.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:money_manager/core/widgets/category_icon.dart';
import 'package:flutter/services.dart';

class VndInputFormatter extends TextInputFormatter {
  final NumberFormat format = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final number = int.parse(digits);
    final newText = format.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class BudgetPlanningScreen extends StatefulWidget {
  const BudgetPlanningScreen({super.key});

  @override
  State<BudgetPlanningScreen> createState() => _BudgetPlanningScreenState();
}

class _BudgetPlanningScreenState extends State<BudgetPlanningScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to set budgets.'));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: AppColors.green, size: 26),
                const SizedBox(width: 10),
                const Text(
                  'Budget Planning',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.green),
              tooltip: 'Reset all limits',
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;
                final budgetsSnap = await FirebaseFirestore.instance
                    .collection('budgets')
                    .where('userId', isEqualTo: user.uid)
                    .get();
                final format = NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                );
                double totalLimit = 0;
                for (final doc in budgetsSnap.docs) {
                  final data = doc.data();
                  final limit = (data['limit'] ?? 0).toDouble();
                  totalLimit += limit;
                }
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset All Budgets'),
                    content: Text(
                      'Are you sure you want to delete all budget data?\n\nCurrent total limit: ${format.format(totalLimit)}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final batch = FirebaseFirestore.instance.batch();
                  for (final doc in budgetsSnap.docs) {
                    batch.delete(doc.reference);
                  }
                  await batch.commit();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All budget data has been permanently deleted. Previous total limit: \\${format.format(totalLimit)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.red[400],
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      body: StreamBuilder<List<Budget>>(
        stream: BudgetService.getBudgetsForUser(user.uid),
        builder: (context, snapshot) {
          final budgets = snapshot.data ?? [];
          // Filter out income categories
          final incomeCategories = ['salary', 'freelance', 'otherincome'];
          // Build a list of category-budget pairs
          final categoryBudgetPairs = AppColors.categoryColors.keys
              .where(
                (category) => !incomeCategories.contains(
                  category.toLowerCase().replaceAll(' ', ''),
                ),
              )
              .map((category) {
                final budget = budgets.firstWhere(
                  (b) => b.category == category,
                  orElse: () => Budget(
                    id: '',
                    userId: user.uid,
                    category: category,
                    limit: 0,
                  ),
                );
                return MapEntry(category, budget);
              })
              .toList();
          // Sort: categories reaching/exceeding 100% first, then >=80%, then the rest
          categoryBudgetPairs.sort((a, b) {
            double aPercent = 0;
            double bPercent = 0;
            if (a.value.limit > 0) {
              final spentA =
                  budgets
                          .firstWhere(
                            (bud) => bud.category == a.key,
                            orElse: () => Budget(
                              id: '',
                              userId: user.uid,
                              category: a.key,
                              limit: 0,
                            ),
                          )
                          .limit >
                      0
                  ? _controllers[a.key]?.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        ) ??
                        '0'
                  : '0';
              aPercent = double.tryParse(spentA) ?? 0;
              aPercent = aPercent / a.value.limit;
            }
            if (b.value.limit > 0) {
              final spentB =
                  budgets
                          .firstWhere(
                            (bud) => bud.category == b.key,
                            orElse: () => Budget(
                              id: '',
                              userId: user.uid,
                              category: b.key,
                              limit: 0,
                            ),
                          )
                          .limit >
                      0
                  ? _controllers[b.key]?.text.replaceAll(
                          RegExp(r'[^0-9]'),
                          '',
                        ) ??
                        '0'
                  : '0';
              bPercent = double.tryParse(spentB) ?? 0;
              bPercent = bPercent / b.value.limit;
            }
            // Priority: >=100% first, then >=80%, then the rest
            int aPriority = aPercent >= 1.0 ? 2 : (aPercent >= 0.8 ? 1 : 0);
            int bPriority = bPercent >= 1.0 ? 2 : (bPercent >= 0.8 ? 1 : 0);
            if (aPriority != bPriority) {
              return bPriority.compareTo(aPriority);
            }
            // If same priority, sort by limit descending
            return b.value.limit.compareTo(a.value.limit);
          });
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Set your monthly spending limits for each category:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 18),
              ...categoryBudgetPairs.map((entry) {
                final category = entry.key;
                final budget = entry.value;
                _controllers[category] ??= TextEditingController(
                  text: budget.limit > 0 ? budget.limit.toStringAsFixed(0) : '',
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors
                                        .categoryColors[category]!
                                        .withValues(alpha: 0.13),
                                    child: CategoryIcon(
                                      category: category,
                                      color: AppColors.categoryColors[category],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    category[0].toUpperCase() +
                                        category.substring(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _controllers[category],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [VndInputFormatter()],
                                      decoration: InputDecoration(
                                        labelText: budget.limit > 0
                                            ? 'Change Limit (VND)'
                                            : 'Monthly Limit (VND)',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final raw = _controllers[category]!.text
                                          .replaceAll(RegExp(r'[^0-9]'), '');
                                      final value = raw.isNotEmpty
                                          ? double.parse(raw)
                                          : 0.0;
                                      if (value > 0) {
                                        final docId = budget.id.isNotEmpty
                                            ? budget.id
                                            : '${user.uid}_$category';
                                        final newBudget = Budget(
                                          id: docId,
                                          userId: user.uid,
                                          category: category,
                                          limit: value,
                                        );
                                        await BudgetService.setBudget(
                                          newBudget,
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Budget saved!'),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _BudgetProgress(
                                userId: user.uid,
                                category: category,
                                limit: budget.limit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final String userId;
  final String category;
  final double limit;
  const _BudgetProgress({
    required this.userId,
    required this.category,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    if (limit <= 0) return const SizedBox();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        double spent = 0;
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0).toDouble();
            if (amount < 0) spent += amount.abs();
          }
        }
        final percent = (spent / limit).clamp(0.0, 1.0);
        final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
        // Color logic: green < 80%, orange 80-99%, red >= 100%
        Color progressColor;
        if (percent < 0.8) {
          progressColor = AppColors.green;
        } else if (percent < 1.0) {
          progressColor = Colors.orange;
        } else {
          progressColor = AppColors.red;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.transparent,
                  color: progressColor,
                  minHeight: 10,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
              child: Text(
                'Spent: ${format.format(spent)} / ${format.format(limit)}',
              ),
            ),
          ],
        );
      },
    );
  }
}
