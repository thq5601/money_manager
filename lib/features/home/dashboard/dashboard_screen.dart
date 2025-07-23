import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:money_manager/widgets/dashboard_card.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/core/services/profile_manager.dart';
import 'package:money_manager/core/services/profile_service.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> transactions = const [
    {
      'title': 'Grocery Shopping',
      'amount': -54.99,
      'date': '2024-06-01',
      'icon': Icons.shopping_cart,
      'color': AppColors.red,
    },
    {
      'title': 'Salary',
      'amount': 1500.00,
      'date': '2024-05-30',
      'icon': Icons.attach_money,
      'color': AppColors.green,
    },
    {
      'title': 'Electricity Bill',
      'amount': -75.20,
      'date': '2024-05-28',
      'icon': Icons.flash_on,
      'color': AppColors.orange,
    },
    {
      'title': 'Coffee',
      'amount': -3.50,
      'date': '2024-05-27',
      'icon': Icons.local_cafe,
      'color': AppColors.purple,
    },
  ];

  String _formatVND(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      color: AppColors.cardBackground,
      child: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: user == null
                ? null
                : FirebaseFirestore.instance
                      .collection('transactions')
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
            builder: (context, snapshot) {
              double totalIncome = 0;
              double totalExpense = 0;
              double totalBalance = 0;
              if (snapshot.hasData) {
                for (final doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final amount = (data['amount'] ?? 0).toDouble();
                  if (amount > 0) {
                    totalIncome += amount;
                  } else {
                    totalExpense += amount;
                  }
                }
                totalBalance = totalIncome + totalExpense;
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // (Welcome User section removed)
                    // Total Balance Card
                    Center(
                      child: _glassCard(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: AppColors.green,
                                    size: 32,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _formatVND(totalBalance),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green,
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Income & Expenses Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.green.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.arrow_downward,
                                  color: AppColors.green,
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Income',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatVND(totalIncome),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.red.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.arrow_upward,
                                  color: AppColors.red,
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Expenses',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatVND(totalExpense.abs()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    // Transaction History header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Transaction list with glass effect and animation
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseAuth.instance.currentUser == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('transactions')
                                .where(
                                  'userId',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid,
                                )
                                .orderBy('dateCreated', descending: true)
                                .limit(4)
                                .snapshots(),
                      builder: (context, snapshot) {
                        if (FirebaseAuth.instance.currentUser == null) {
                          return const SizedBox();
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: \\${snapshot.error}'),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'No recent transactions',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final amount = data['amount'] ?? 0;
                            final type = data['type'] ?? 'Expense';
                            final category = data['category'];
                            final desc = data['description'] ?? '';
                            final icon = _categoryIconForFilter(category);
                            final color =
                                AppColors.categoryColors[category] ??
                                (type == 'Income'
                                    ? AppColors.success
                                    : AppColors.error);
                            final ts = data['dateCreated'];
                            String dateStr = '';
                            if (ts is Timestamp) {
                              dateStr = DateFormat(
                                'yyyy-MM-dd',
                              ).format(ts.toDate());
                            }
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 400 + index * 100,
                              ),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 30),
                                    child: _glassCard(
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 2,
                                            ),
                                        leading: CircleAvatar(
                                          backgroundColor: color.withOpacity(
                                            0.13,
                                          ),
                                          child: Icon(icon, color: color),
                                        ),
                                        title: Text(
                                          desc,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          dateStr,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        trailing: Text(
                                          (amount > 0 ? '+' : '-') +
                                              _formatVND((amount as num).abs()),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: type == 'Income'
                                                ? AppColors.green
                                                : AppColors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }, // closes builder
          ), // closes StreamBuilder
          // Floating Action Button with soft shadow
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  // Widget _buildBalanceChart() {
  //   // Placeholder for a chart. Replace with a real chart widget if needed.
  //   return Container(
  //     height: 120,
  //     margin: const EdgeInsets.symmetric(vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.15),
  //       borderRadius: BorderRadius.circular(18),
  //     ),
  //     child: const Center(
  //       child: Text(
  //         'Balance Chart Placeholder',
  //         style: TextStyle(
  //           color: AppColors.textSecondary,
  //           fontSize: 16,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
