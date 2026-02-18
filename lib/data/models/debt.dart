enum DebtStatus { pending, partial, paid, overdue }

class Debt {
  final int? id;
  final String uuid;
  final String clientUuid;
  final String concept;
  final double amount;
  final double interest;
  final DateTime date;
  final DateTime dueDate;
  final DebtStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    this.id,
    required this.uuid,
    required this.clientUuid,
    required this.concept,
    required this.amount,
    this.interest = 0,
    required this.date,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalAmount => amount + interest;

  Debt copyWith({
    int? id,
    String? uuid,
    String? clientUuid,
    String? concept,
    double? amount,
    double? interest,
    DateTime? date,
    DateTime? dueDate,
    DebtStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      clientUuid: clientUuid ?? this.clientUuid,
      concept: concept ?? this.concept,
      amount: amount ?? this.amount,
      interest: interest ?? this.interest,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'clientUuid': clientUuid,
      'concept': concept,
      'amount': amount,
      'interest': interest,
      'date': date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      clientUuid: map['clientUuid'] as String,
      concept: map['concept'] as String,
      amount: (map['amount'] as num).toDouble(),
      interest: (map['interest'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(map['date'] as String),
      dueDate: DateTime.parse(map['dueDate'] as String),
      status: DebtStatus.values[map['status'] as int],
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Debt.fromJson(Map<String, dynamic> json) => Debt.fromMap(json);
}
