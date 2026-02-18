import 'package:uuid/uuid.dart';
import '../datasources/database_service.dart';
import '../models/payment.dart';

class PaymentRepository {
  final DatabaseService _db = DatabaseService.instance;
  final _uuid = const Uuid();

  Future<List<Payment>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('payments', orderBy: 'date DESC');
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<List<Payment>> getByDebtUuid(String debtUuid) async {
    final db = await _db.database;
    final maps = await db.query(
      'payments',
      where: 'debtUuid = ?',
      whereArgs: [debtUuid],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<Payment?> getByUuid(String uuid) async {
    final db = await _db.database;
    final maps = await db.query(
      'payments',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }

  Future<Payment> create({
    required String debtUuid,
    required double amount,
    required String method,
    DateTime? date,
    String? notes,
  }) async {
    final db = await _db.database;
    final now = DateTime.now();
    final payment = Payment(
      uuid: _uuid.v4(),
      debtUuid: debtUuid,
      amount: amount,
      method: method,
      date: date ?? now,
      notes: notes,
      createdAt: now,
    );
    await db.insert('payments', payment.toMap()..remove('id'));
    return payment;
  }

  Future<void> delete(String uuid) async {
    final db = await _db.database;
    await db.delete('payments', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<double> getTotalPaidForDebt(String debtUuid) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM payments WHERE debtUuid = ?',
      [debtUuid],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}
