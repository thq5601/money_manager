import 'package:flutter/material.dart';
import 'package:money_manager/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_manager/core/widgets/category_icon.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TransactionScreen extends StatelessWidget {
  final String searchQuery;
  final Set<String> selectedCategories;
  final String? selectedType;

  const TransactionScreen({
    Key? key,
    this.searchQuery = '',
    this.selectedCategories = const {},
    this.selectedType,
  }) : super(key: key);

  String _formatVND(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
  }

  Color _categoryColor(String? category, String type) {
    if (category != null && AppColors.categoryColors.containsKey(category)) {
      return AppColors.categoryColors[category]!;
    }
    return type == 'Income' ? AppColors.success : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view transactions.'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('dateCreated', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        // Client-side filtering
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final desc = (data['description'] ?? '').toString().toLowerCase();
          final matchesQuery =
              searchQuery.isEmpty || desc.contains(searchQuery.toLowerCase());
          final matchesCategory =
              selectedCategories.isEmpty ||
              selectedCategories.contains(data['category']);
          final matchesType =
              selectedType == null || data['type'] == selectedType;
          return matchesQuery && matchesCategory && matchesType;
        }).toList();
        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: AppColors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first transaction!',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          );
        }
        // Group by date (yyyy-MM-dd)
        final Map<String, List<QueryDocumentSnapshot>> grouped = {};
        for (final doc in filteredDocs) {
          final ts = doc['dateCreated'] as Timestamp;
          final dateStr = DateFormat('yyyy-MM-dd').format(ts.toDate());
          grouped.putIfAbsent(dateStr, () => []).add(doc);
        }
        final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          itemCount: dates.length,
          itemBuilder: (context, dateIdx) {
            final date = dates[dateIdx];
            final txs = grouped[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4,
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ...txs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final amount = data['amount'] ?? 0;
                  final type = data['type'] ?? 'Expense';
                  final category = data['category'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Slidable(
                      key: ValueKey(doc.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              await FirebaseFirestore.instance
                                  .collection('transactions')
                                  .doc(doc.id)
                                  .delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transaction deleted'),
                                  ),
                                );
                              }
                            },
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _categoryColor(category, type),
                            child: CategoryIcon(
                              category: category,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            data['description'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            (amount > 0 ? '+' : '-') +
                                _formatVND((amount as num).abs()),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: type == 'Income'
                                  ? AppColors.success
                                  : AppColors.error,
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
        );
      },
    );
  }
}
