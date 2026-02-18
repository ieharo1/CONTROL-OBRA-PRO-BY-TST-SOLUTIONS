import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../../data/models/debt.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/debt_repository.dart';

class DebtFormScreen extends ConsumerStatefulWidget {
  final String? debtUuid;
  final String? preselectedClientUuid;

  const DebtFormScreen({super.key, this.debtUuid, this.preselectedClientUuid});

  @override
  ConsumerState<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends ConsumerState<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conceptController = TextEditingController();
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();
  String? _selectedClientUuid;
  DateTime _date = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  bool _isEditing = false;
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _selectedClientUuid = widget.preselectedClientUuid;
    _loadClients();
    if (widget.debtUuid != null) {
      _isEditing = true;
      _loadDebt();
    }
  }

  Future<void> _loadClients() async {
    final clients = await ref.read(clientRepositoryProvider).getAll();
    setState(() => _clients = clients);
  }

  Future<void> _loadDebt() async {
    setState(() => _isLoading = true);
    try {
      final debt = await ref.read(debtRepositoryProvider).getByUuid(widget.debtUuid!);
      if (debt != null && mounted) {
        _conceptController.text = debt.concept;
        _amountController.text = debt.amount.toString();
        _interestController.text = debt.interest.toString();
        _selectedClientUuid = debt.clientUuid;
        _date = debt.date;
        _dueDate = debt.dueDate;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(bool isDueDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _dueDate : _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) _dueDate = picked;
        else _date = picked;
      });
    }
  }

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un cliente')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(debtsProvider.notifier);
      final amount = double.parse(_amountController.text);
      final interest = double.tryParse(_interestController.text) ?? 0;

      if (_isEditing) {
        final repo = ref.read(debtRepositoryProvider);
        final existing = await repo.getByUuid(widget.debtUuid!);
        if (existing != null) {
          await notifier.updateDebt(existing.copyWith(
            concept: _conceptController.text.trim(),
            amount: amount,
            interest: interest,
            dueDate: _dueDate,
          ));
        }
      } else {
        await notifier.createDebt(
          clientUuid: _selectedClientUuid!,
          concept: _conceptController.text.trim(),
          amount: amount,
          interest: interest,
          date: _date,
          dueDate: _dueDate,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Deuda actualizada' : 'Deuda creada')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Deuda' : 'Nueva Deuda')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedClientUuid,
                      decoration: const InputDecoration(labelText: 'Cliente *', prefixIcon: Icon(Icons.person)),
                      items: _clients.map((c) => DropdownMenuItem(value: c.uuid, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() => _selectedClientUuid = v),
                      validator: (v) => v == null ? 'Seleccione un cliente' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _conceptController,
                      decoration: const InputDecoration(labelText: 'Concepto *', prefixIcon: Icon(Icons.description)),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Concepto requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Monto *', prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Monto requerido';
                        if (double.tryParse(v) == null) return 'Monto inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _interestController,
                      decoration: const InputDecoration(labelText: 'Interés (opcional)', prefixIcon: Icon(Icons.percent)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Fecha de creación'),
                      subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                      onTap: () => _selectDate(false),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: const Text('Fecha límite de pago'),
                      subtitle: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                      onTap: () => _selectDate(true),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDebt,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(_isEditing ? 'Actualizar' : 'Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
