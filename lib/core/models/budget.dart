class Budget {
  final String id;
  final String userId;
  final String category;
  final double limit;
  final String? note;

  Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'category': category,
    'limit': limit,
    'note': note,
  };

  factory Budget.fromMap(Map<String, dynamic> map, String id) => Budget(
    id: id,
    userId: map['userId'] ?? '',
    category: map['category'] ?? '',
    limit: (map['limit'] ?? 0).toDouble(),
    note: map['note'],
  );
}
