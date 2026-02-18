import 'package:uuid/uuid.dart';
import '../datasources/database_service.dart';
import '../models/debt.dart';

class DebtRepository {
  final DatabaseService _db = DatabaseService.instance;
  final _uuid = const Uuid();

  Future<List<Debt>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('debts', orderBy: 'createdAt DESC');
    return maps.map((map) => Debt.fromMap(map)).toList();
  }

  Future<List<Debt>> getByClientUuid(String clientUuid) async {
    final db = await _db.database;
    final maps = await db.query(
      'debts',
      where: 'clientUuid = ?',
      whereArgs: [clientUuid],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Debt.fromMap(map)).toList();
  }

  Future<Debt?> getByUuid(String uuid) async {
    final db = await _db.database;
    final maps = await db.query(
      'debts',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Debt.fromMap(maps.first);
  }

  Future<List<Debt>> getByStatus(DebtStatus status) async {
    final db = await _db.database;
    final maps = await db.query(
      'debts',
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Debt.fromMap(map)).toList();
  }

  Future<List<Debt>> getOverdue() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'debts',
      where: 'dueDate < ? AND status != ?',
      whereArgs: [now, DebtStatus.paid.index],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Debt.fromMap(map)).toList();
  }

  Future<Debt> create({
    required String clientUuid,
    required String concept,
    required double amount,
    double interest = 0,
    required DateTime date,
    required DateTime dueDate,
  }) async {
    final db = await _db.database;
    final now = DateTime.now();
    final debt = Debt(
      uuid: _uuid.v4(),
      clientUuid: clientUuid,
      concept: concept,
      amount: amount,
      interest: interest,
      date: date,
      dueDate: dueDate,
      status: DebtStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('debts', debt.toMap()..remove('id'));
    return debt;
  }

  Future<Debt> update(Debt debt) async {
    final db = await _db.database;
    final updated = debt.copyWith(updatedAt: DateTime.now());
    await db.update(
      'debts',
      updated.toMap()..remove('id'),
      where: 'uuid = ?',
      whereArgs: [debt.uuid],
    );
    return updated;
  }

  Future<Debt> updateStatus(String uuid, DebtStatus status) async {
    final debt = await getByUuid(uuid);
    if (debt == null) throw Exception('Debt not found');
    return update(debt.copyWith(status: status));
  }

  Future<void> delete(String uuid) async {
    final db = await _db.database;
    await db.delete('debts', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<double> getTotalPending() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount + interest) as total FROM debts WHERE status != ?',
      [DebtStatus.paid.index],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTotalOverdue() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      'SELECT SUM(amount + interest) as total FROM debts WHERE dueDate < ? AND status != ?',
      [now, DebtStatus.paid.index],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTotalCollectedThisMonth() async {
    final db = await _db.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();
    
    final result = await db.rawQuery(
      '''SELECT SUM(p.amount) as total FROM payments p 
         INNER JOIN debts d ON p.debtUuid = d.uuid 
         WHERE p.date >= ? AND p.date <= ?''',
      [startOfMonth, endOfMonth],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<int> countOverdueClients() async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT clientUuid) as count FROM debts WHERE dueDate < ? AND status != ?',
      [now, DebtStatus.paid.index],
    );
    return result.first['count'] as int;
  }
}
