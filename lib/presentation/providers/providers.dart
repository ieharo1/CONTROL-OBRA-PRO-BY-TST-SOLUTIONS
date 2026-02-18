import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/client.dart';
import '../../data/models/debt.dart';
import '../../data/models/payment.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/debt_repository.dart';
import '../../data/repositories/payment_repository.dart';

final clientRepositoryProvider = Provider((ref) => ClientRepository());
final debtRepositoryProvider = Provider((ref) => DebtRepository());
final paymentRepositoryProvider = Provider((ref) => PaymentRepository());

final clientsProvider = StateNotifierProvider<ClientsNotifier, AsyncValue<List<Client>>>((ref) {
  return ClientsNotifier(ref.watch(clientRepositoryProvider));
});

class ClientsNotifier extends StateNotifier<AsyncValue<List<Client>>> {
  final ClientRepository _repository;

  ClientsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadClients();
  }

  Future<void> loadClients() async {
    state = const AsyncValue.loading();
    try {
      final clients = await _repository.getAll();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Client> createClient({
    required String name,
    String? phone,
    String? address,
    String? photoPath,
    String? notes,
  }) async {
    final client = await _repository.create(
      name: name,
      phone: phone,
      address: address,
      photoPath: photoPath,
      notes: notes,
    );
    await loadClients();
    return client;
  }

  Future<void> updateClient(Client client) async {
    await _repository.update(client);
    await loadClients();
  }

  Future<void> deleteClient(String uuid) async {
    await _repository.delete(uuid);
    await loadClients();
  }

  Future<List<Client>> search(String query) async {
    return _repository.search(query);
  }
}

final debtsProvider = StateNotifierProvider<DebtsNotifier, AsyncValue<List<Debt>>>((ref) {
  return DebtsNotifier(ref.watch(debtRepositoryProvider));
});

class DebtsNotifier extends StateNotifier<AsyncValue<List<Debt>>> {
  final DebtRepository _repository;

  DebtsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDebts();
  }

  Future<void> loadDebts() async {
    state = const AsyncValue.loading();
    try {
      final debts = await _repository.getAll();
      state = AsyncValue.data(debts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Debt> createDebt({
    required String clientUuid,
    required String concept,
    required double amount,
    double interest = 0,
    required DateTime date,
    required DateTime dueDate,
  }) async {
    final debt = await _repository.create(
      clientUuid: clientUuid,
      concept: concept,
      amount: amount,
      interest: interest,
      date: date,
      dueDate: dueDate,
    );
    await loadDebts();
    return debt;
  }

  Future<void> updateDebt(Debt debt) async {
    await _repository.update(debt);
    await loadDebts();
  }

  Future<void> deleteDebt(String uuid) async {
    await _repository.delete(uuid);
    await loadDebts();
  }

  Future<void> updateStatus(String uuid, DebtStatus status) async {
    await _repository.updateStatus(uuid, status);
    await loadDebts();
  }

  Future<List<Debt>> getByClientUuid(String clientUuid) async {
    return _repository.getByClientUuid(clientUuid);
  }

  Future<List<Debt>> getOverdue() async {
    return _repository.getOverdue();
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, AsyncValue<List<Payment>>>((ref) {
  return PaymentsNotifier(ref.watch(paymentRepositoryProvider));
});

class PaymentsNotifier extends StateNotifier<AsyncValue<List<Payment>>> {
  final PaymentRepository _repository;

  PaymentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    state = const AsyncValue.loading();
    try {
      final payments = await _repository.getAll();
      state = AsyncValue.data(payments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Payment> createPayment({
    required String debtUuid,
    required double amount,
    required String method,
    DateTime? date,
    String? notes,
  }) async {
    final payment = await _repository.create(
      debtUuid: debtUuid,
      amount: amount,
      method: method,
      date: date,
      notes: notes,
    );
    await loadPayments();
    return payment;
  }

  Future<void> deletePayment(String uuid) async {
    await _repository.delete(uuid);
    await loadPayments();
  }

  Future<List<Payment>> getByDebtUuid(String debtUuid) async {
    return _repository.getByDebtUuid(debtUuid);
  }

  Future<double> getTotalPaidForDebt(String debtUuid) async {
    return _repository.getTotalPaidForDebt(debtUuid);
  }
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final debtRepo = ref.watch(debtRepositoryProvider);
  return DashboardStats(
    totalPending: await debtRepo.getTotalPending(),
    totalOverdue: await debtRepo.getTotalOverdue(),
    totalCollectedThisMonth: await debtRepo.getTotalCollectedThisMonth(),
    overdueClientsCount: await debtRepo.countOverdueClients(),
  );
});

class DashboardStats {
  final double totalPending;
  final double totalOverdue;
  final double totalCollectedThisMonth;
  final int overdueClientsCount;

  DashboardStats({
    required this.totalPending,
    required this.totalOverdue,
    required this.totalCollectedThisMonth,
    required this.overdueClientsCount,
  });
}
