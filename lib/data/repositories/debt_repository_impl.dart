import 'package:cobranza_pro/data/datasources/database_service.dart';
import 'package:cobranza_pro/data/models/debt_model.dart';
import 'package:cobranza_pro/domain/entities/debt_status.dart';
import 'package:cobranza_pro/domain/entities/entities.dart';
import 'package:cobranza_pro/domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  @override
  Future<List<Debt>> getAllDebts() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('debts', orderBy: 'dueDate DESC');
    return maps.map((m) => DebtModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<List<Debt>> getDebtsByClientId(String clientId) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('debts', where: 'clientUuid = ?', whereArgs: [clientId]);
    return maps.map((m) => DebtModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<List<Debt>> getDebtsByStatus(DebtStatus status) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('debts', where: 'status = ?', whereArgs: [status.name]);
    return maps.map((m) => DebtModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<Debt?> getDebtById(String id) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('debts', where: 'uuid = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return DebtModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<Debt> createDebt(Debt debt) async {
    final db = await DatabaseService.instance.database;
    final model = DebtModel.fromEntity(debt);
    await db.insert('debts', model.toMap());
    return debt;
  }

  @override
  Future<Debt> updateDebt(Debt debt) async {
    final db = await DatabaseService.instance.database;
    final model = DebtModel.fromEntity(debt);
    await db.update('debts', model.toMap(), where: 'uuid = ?', whereArgs: [debt.id]);
    return debt;
  }

  @override
  Future<void> deleteDebt(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('debts', where: 'uuid = ?', whereArgs: [id]);
  }

  @override
  Future<double> getTotalPending() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('debts', where: 'status IN (?, ?, ?)', whereArgs: ['pending', 'partial', 'overdue']);
    double total = 0;
    for (final m in maps) {
      total += (m['amount'] as num).toDouble() + (m['interest'] as num).toDouble();
    }
    return total;
  }

  @override
  Future<double> getTotalOverdue() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('debts', where: 'status = ?', whereArgs: ['overdue']);
    double total = 0;
    for (final m in maps) {
      total += (m['amount'] as num).toDouble() + (m['interest'] as num).toDouble();
    }
    return total;
  }

  @override
  Future<double> getTotalCollectedThisMonth() async {
    final db = await DatabaseService.instance.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final maps = await db.query('payments', where: 'date >= ?', whereArgs: [startOfMonth]);
    double total = 0;
    for (final m in maps) {
      total += (m['amount'] as num).toDouble();
    }
    return total;
  }

  @override
  Future<int> getOverdueClientsCount() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('debts', where: 'status = ?', whereArgs: ['overdue']);
    final clientIds = maps.map((m) => m['clientUuid'] as String).toSet();
    return clientIds.length;
  }
}
