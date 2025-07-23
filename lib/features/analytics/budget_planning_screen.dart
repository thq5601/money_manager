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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.only(
            top: 16,
            left: 8,
            right: 20,
            bottom: 12,
          ),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.green,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                splashRadius: 22,
              ),
              const Text(
                'Budget Planning',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
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
                        'Are you sure you want to reset all budget limits to 0?\n\nCurrent total limit: \\${format.format(totalLimit)}',
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
                      batch.update(doc.reference, {'limit': 0});
                    }
                    await batch.commit();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tất cả hạn mức đã được đặt lại về 0 ₫ (trước đó: \\${format.format(totalLimit)})',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Budget>>(
        stream: BudgetService.getBudgetsForUser(user.uid),
        builder: (context, snapshot) {
          final budgets = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Set your monthly spending limits for each category:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 18),
              ...AppColors.categoryColors.keys.map((category) {
                final budget = budgets.firstWhere(
                  (b) => b.category == category,
                  orElse: () => Budget(
                    id: '',
                    userId: user.uid,
                    category: category,
                    limit: 0,
                  ),
                );
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
                                        labelText: 'Monthly Limit (VND)',
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[200],
                color: percent < 1.0 ? AppColors.green : AppColors.red,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Spent: ${format.format(spent)} / ${format.format(limit)}',
              style: TextStyle(
                color: percent < 1.0 ? AppColors.green : AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
