import 'category.dart';

class Transaction {
  final String id;
  final String title;
  final int amount; // Disimpan sebagai int karena Rupiah tanpa desimal
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Transaction copyWith({
    String? id,
    String? title,
    int? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    bool clearNote = false, // Flag eksplisit untuk mengosongkan note
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'categoryId': category.id,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    List<TransactionCategory>? customCategories,
  }) {
    final catId = json['categoryId'] as String? ?? 'exp_other';
    
    // Handle amount: bisa int atau double (backward compatibility)
    final rawAmount = json['amount'];
    int amount;
    if (rawAmount is int) {
      amount = rawAmount;
    } else if (rawAmount is double) {
      amount = rawAmount.round();
    } else {
      throw FormatException('Invalid amount type: ${rawAmount.runtimeType}');
    }
    
    final type = TransactionType.values.byName(json['type'] as String);

    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: amount,
      type: type,
      category: TransactionCategory.getById(
        catId,
        customCategories: customCategories,
        fallbackType: type,
      ),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
