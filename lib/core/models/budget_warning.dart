class BudgetWarning {
  final String category;
  final double spent;
  final double limit;
  final double percent;
  BudgetWarning({
    required this.category,
    required this.spent,
    required this.limit,
    required this.percent,
  });
}
