import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/client_repository.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  DebtStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas'),
        actions: [
          PopupMenuButton<DebtStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) => setState(() => _statusFilter = status),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Todos')),
              const PopupMenuItem(value: DebtStatus.pending, child: Text('Pendientes')),
              const PopupMenuItem(value: DebtStatus.partial, child: Text('Parciales')),
              const PopupMenuItem(value: DebtStatus.paid, child: Text('Pagadas')),
              const PopupMenuItem(value: DebtStatus.overdue, child: Text('Vencidas')),
            ],
          ),
        ],
      ),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (debts) {
          final filteredDebts = _statusFilter == null
              ? debts
              : debts.where((d) => d.status == _statusFilter).toList();

          if (filteredDebts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(_statusFilter == null ? 'No hay deudas' : 'No hay deudas con este filtro'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/debt/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva Deuda'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.read(debtsProvider.notifier).loadDebts(),
            child: FutureBuilder<List<Client>>(
              future: ref.read(clientRepositoryProvider).getAll(),
              builder: (context, snapshot) {
                final clients = snapshot.data ?? [];
                final clientMap = {for (var c in clients) c.uuid: c};

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDebts.length,
                  itemBuilder: (context, index) {
                    final debt = filteredDebts[index];
                    final client = clientMap[debt.clientUuid];
                    final isOverdue = debt.status != DebtStatus.paid && debt.dueDate.isBefore(DateTime.now());

                    return Card(
                      color: isOverdue ? Colors.red.shade50 : null,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(debt.concept),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (client != null) Text('Cliente: ${client.name}'),
                            Text(
                              'Vence: ${DateFormat.yMd().format(debt.dueDate)}',
                              style: TextStyle(
                                color: isOverdue ? Colors.red : null,
                                fontWeight: isOverdue ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(debt.totalAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getStatusColor(debt.status.name),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.getStatusColor(debt.status.name),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                debt.status.name.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: client != null,
                        onTap: () => context.push('/debt/${debt.uuid}'),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/debt/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
