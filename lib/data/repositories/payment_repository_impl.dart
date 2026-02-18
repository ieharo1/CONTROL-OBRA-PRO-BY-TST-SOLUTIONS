import 'package:cobranza_pro/data/datasources/database_service.dart';
import 'package:cobranza_pro/data/models/payment_model.dart';
import 'package:cobranza_pro/domain/entities/entities.dart';
import 'package:cobranza_pro/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  @override
  Future<List<Payment>> getAllPayments() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('payments', orderBy: 'date DESC');
    return maps.map((m) => PaymentModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByDebtId(String debtId) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('payments', where: 'debtUuid = ?', whereArgs: [debtId]);
    return maps.map((m) => PaymentModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<Payment?> getPaymentById(String id) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('payments', where: 'uuid = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PaymentModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    final db = await DatabaseService.instance.database;
    final model = PaymentModel.fromEntity(payment);
    await db.insert('payments', model.toMap());
    return payment;
  }

  @override
  Future<void> deletePayment(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('payments', where: 'uuid = ?', whereArgs: [id]);
  }

  @override
  Future<double> getTotalPaidForDebt(String debtId) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('payments', where: 'debtUuid = ?', whereArgs: [debtId]);
    double total = 0;
    for (final m in maps) {
      total += (m['amount'] as num).toDouble();
    }
    return total;
  }
}
