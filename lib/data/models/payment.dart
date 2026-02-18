class Payment {
  final int? id;
  final String uuid;
  final String debtUuid;
  final double amount;
  final String method;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  Payment({
    this.id,
    required this.uuid,
    required this.debtUuid,
    required this.amount,
    required this.method,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  Payment copyWith({
    int? id,
    String? uuid,
    String? debtUuid,
    double? amount,
    String? method,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      debtUuid: debtUuid ?? this.debtUuid,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'debtUuid': debtUuid,
      'amount': amount,
      'method': method,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      debtUuid: map['debtUuid'] as String,
      amount: (map['amount'] as num).toDouble(),
      method: map['method'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory Payment.fromJson(Map<String, dynamic> json) => Payment.fromMap(json);
}
