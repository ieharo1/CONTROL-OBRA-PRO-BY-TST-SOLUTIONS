import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/client.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final String debtUuid;
  const DebtDetailScreen({super.key, required this.debtUuid});

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen> {
  Debt? _debt;
  Client? _client;
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final debtRepo = ref.read(debtRepositoryProvider);
      final clientRepo = ref.read(clientRepositoryProvider);
      final paymentRepo = ref.read(paymentRepositoryProvider);

      _debt = await debtRepo.getByUuid(widget.debtUuid);
      if (_debt != null) {
        _client = await clientRepo.getByUuid(_debt!.clientUuid);
        _payments = await paymentRepo.getByDebtUuid(widget.debtUuid);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDebt() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Deuda'),
        content: const Text('¿Está seguro de eliminar esta deuda?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(debtsProvider.notifier).deleteDebt(widget.debtUuid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deuda eliminada')));
        context.pop();
      }
    }
  }

  Future<void> _markAsPaid() async {
    await ref.read(debtsProvider.notifier).updateStatus(widget.debtUuid, DebtStatus.paid);
    await _loadData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deuda marcada como pagada')));
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Deuda'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/debt/${widget.debtUuid}/edit')),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteDebt),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _debt == null
              ? const Center(child: Text('Deuda no encontrada'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(_debt!.concept, style: Theme.of(context).textTheme.titleLarge)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.getStatusColor(_debt!.status.name),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(_debt!.status.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                if (_client != null) ...[
                                  Text('Cliente: ${_client!.name}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Monto:'),
                                    Text(currencyFormat.format(_debt!.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (_debt!.interest > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Interés:'),
                                      Text(currencyFormat.format(_debt!.interest), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    Text(currencyFormat.format(_debt!.totalAmount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Fechas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Creación:'), Text(DateFormat.yMd().format(_debt!.date))]),
                                const SizedBox(height: 4),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Vencimiento:'), Text(DateFormat.yMd().format(_debt!.dueDate))]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pagos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (_debt!.status != DebtStatus.paid)
                              ElevatedButton.icon(
                                onPressed: () => context.push('/debt/${widget.debtUuid}/payment'),
                                icon: const Icon(Icons.add),
                                label: const Text('Registrar Pago'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_payments.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(child: Column(children: [Icon(Icons.payments, size: 48, color: Colors.grey[400]), const SizedBox(height: 8), const Text('No hay pagos registrados')])),
                            ),
                          )
                        else
                          ...(_payments.map((payment) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.check_circle, color: Colors.green),
                                  title: Text(currencyFormat.format(payment.amount)),
                                  subtitle: Text('${DateFormat.yMd().format(payment.date)} - ${payment.method}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () async {
                                      await ref.read(paymentsProvider.notifier).deletePayment(payment.uuid);
                                      await _loadData();
                                    },
                                  ),
                                ),
                              ))),
                        if (_debt!.status != DebtStatus.paid) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _markAsPaid,
                              icon: const Icon(Icons.check),
                              label: const Text('Marcar como Pagada'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
