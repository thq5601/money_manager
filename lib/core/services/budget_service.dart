import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget.dart';

class BudgetService {
  static final _budgetRef = FirebaseFirestore.instance.collection('budgets');

  static Future<void> setBudget(Budget budget) async {
    await _budgetRef.doc(budget.id).set(budget.toMap());
  }

  static Future<void> deleteBudget(String id) async {
    await _budgetRef.doc(id).delete();
  }

  static Stream<List<Budget>> getBudgetsForUser(String userId) {
    return _budgetRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Budget.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  static Future<Budget?> getBudgetForCategory(
    String userId,
    String category,
  ) async {
    final snap = await _budgetRef
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Budget.fromMap(doc.data(), doc.id);
  }
}
