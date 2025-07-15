import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/dashboard_card.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:money_manager/core/services/profile_manager.dart';
import 'package:money_manager/core/services/profile_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name from Firestore (no avatar), improved UI
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: FutureBuilder<UserProfile?>(
                    future: ProfileManager.getCurrentProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _glassCard(
                          child: Container(
                            width: double.infinity,
                            height: 70,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: Container(
                              width: 120,
                              height: 24,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        );
                      }
                      final profile = snapshot.data;
                      final name = profile?.fullName ?? 'User';
                      return _glassCard(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 18,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome Back,',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'Total balance: ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Divider(
                    color: Colors.black.withOpacity(0.07),
                    thickness: 1.2,
                    height: 0,
                  ),
                ),
                // Glassmorphism Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _glassCard(
                        child: DashboardCard(
                          title: 'Income',
                          amount: '\$1,500.00',
                          amountColor: AppColors.green,
                          icon: Icons.arrow_downward,
                          iconColor: AppColors.green,
                          onTap: () {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _glassCard(
                        child: DashboardCard(
                          title: 'Expenses',
                          amount: '\$800.69',
                          amountColor: AppColors.red,
                          icon: Icons.arrow_upward,
                          iconColor: AppColors.red,
                          onTap: () {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
                const SizedBox(height: 36),
                // Chart placeholder
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + index * 100),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 30),
                            child: _glassCard(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 2,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: tx['color'].withOpacity(
                                    0.13,
                                  ),
                                  child: Icon(tx['icon'], color: tx['color']),
                                ),
                                title: Text(
                                  tx['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  tx['date'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Text(
                                  (tx['amount'] > 0 ? '+' : '-') +
                                      '\$' +
                                      tx['amount'].abs().toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: tx['amount'] > 0
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
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
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
