import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/client.dart';
import '../../../data/models/debt.dart';
import 'pdf_generator.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientUuid;

  const ClientDetailScreen({super.key, required this.clientUuid});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  Client? _client;
  List<Debt> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clientRepo = ref.read(clientRepositoryProvider);
      final debtRepo = ref.read(debtRepositoryProvider);
      
      _client = await clientRepo.getByUuid(widget.clientUuid);
      _debts = await debtRepo.getByClientUuid(widget.clientUuid);
      
      for (var debt in _debts) {
        if (debt.status != DebtStatus.paid && debt.dueDate.isBefore(DateTime.now())) {
          final updated = debt.copyWith(status: DebtStatus.overdue);
          await debtRepo.update(updated);
        }
      }
      _debts = await debtRepo.getByClientUuid(widget.clientUuid);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteClient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: const Text('¿Está seguro que desea eliminar este cliente? Se eliminarán todas sus deudas y pagos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(clientsProvider.notifier).deleteClient(widget.clientUuid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente eliminado')));
        context.go('/clients');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(_client?.name ?? 'Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _client != null ? () => generateClientPdf(context, _client!, _debts) : null,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/client/${widget.clientUuid}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _client == null
              ? const Center(child: Text('Cliente no encontrado'))
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
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppTheme.primaryColor,
                                  backgroundImage: _client!.photoPath != null
                                      ? FileImage(File(_client!.photoPath!))
                                      : null,
                                  child: _client!.photoPath == null
                                      ? Text(
                                          _client!.name[0].toUpperCase(),
                                          style: const TextStyle(fontSize: 32, color: Colors.white),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_client!.name, style: Theme.of(context).textTheme.titleLarge),
                                      if (_client!.phone != null)
                                        Text(_client!.phone!, style: TextStyle(color: Colors.grey[600])),
                                      if (_client!.address != null)
                                        Text(_client!.address!, style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_client!.notes != null && _client!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Notas', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(_client!.notes!),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Deudas (${_debts.length})', style: Theme.of(context).textTheme.titleMedium),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/debt/new?clientUuid=${widget.clientUuid}'),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Nueva Deuda'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_debts.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    const Text('No hay deudas registradas'),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...(_debts.map((debt) {
                            final isOverdue = debt.status != DebtStatus.paid && debt.dueDate.isBefore(DateTime.now());
                            return Card(
                              color: isOverdue ? Colors.red.shade50 : null,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(debt.concept),
                                subtitle: Text(
                                  'Vence: ${DateFormat.yMd().format(debt.dueDate)}',
                                  style: TextStyle(
                                    color: isOverdue ? Colors.red : null,
                                    fontWeight: isOverdue ? FontWeight.bold : null,
                                  ),
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
                                onTap: () => context.push('/debt/${debt.uuid}'),
                              ),
                            );
                          })),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/debt/new?clientUuid=${widget.clientUuid}'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Deuda'),
      ),
    );
  }
}
