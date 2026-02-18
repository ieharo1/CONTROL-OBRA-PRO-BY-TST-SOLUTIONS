import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../../data/models/debt.dart';
import '../../../data/repositories/debt_repository.dart';
import '../../../data/repositories/payment_repository.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final String debtUuid;
  const PaymentFormScreen({super.key, required this.debtUuid});

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _method = 'Efectivo';
  DateTime _date = DateTime.now();
  Debt? _debt;
  bool _isLoading = true;
  double _remainingBalance = 0;

  final _methods = ['Efectivo', 'Transferencia', 'MercadoPago', 'PayPal', 'Otro'];

  @override
  void initState() {
    super.initState();
    _loadDebt();
  }

  Future<void> _loadDebt() async {
    setState(() => _isLoading = true);
    try {
      final debtRepo = ref.read(debtRepositoryProvider);
      final paymentRepo = ref.read(paymentRepositoryProvider);
      _debt = await debtRepo.getByUuid(widget.debtUuid);
      if (_debt != null) {
        final totalPaid = await paymentRepo.getTotalPaidForDebt(widget.debtUuid);
        _remainingBalance = _debt!.totalAmount - totalPaid;
        _amountController.text = _remainingBalance.toStringAsFixed(2);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_debt == null) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      await ref.read(paymentsProvider.notifier).createPayment(
            debtUuid: widget.debtUuid,
            amount: amount,
            method: _method,
            date: _date,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );

      final paymentRepo = ref.read(paymentRepositoryProvider);
      final totalPaid = await paymentRepo.getTotalPaidForDebt(widget.debtUuid);
      final newStatus = totalPaid >= _debt!.totalAmount ? DebtStatus.paid : DebtStatus.partial;
      await ref.read(debtsProvider.notifier).updateStatus(widget.debtUuid, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago registrado')));
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
      appBar: AppBar(title: const Text('Registrar Pago')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _debt == null
              ? const Center(child: Text('Deuda no encontrada'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Saldo Pendiente', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('\$${_remainingBalance.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.red)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(labelText: 'Monto *', prefixIcon: Icon(Icons.attach_money)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Monto requerido';
                            final amount = double.tryParse(v);
                            if (amount == null || amount <= 0) return 'Monto inválido';
                            if (amount > _remainingBalance) return 'Monto mayor al saldo';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _method,
                          decoration: const InputDecoration(labelText: 'Método de Pago', prefixIcon: Icon(Icons.payment)),
                          items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (v) => setState(() => _method = v!),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Fecha'),
                          subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                          onTap: _selectDate,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(labelText: 'Notas (opcional)', prefixIcon: Icon(Icons.note)),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _savePayment,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                            child: const Text('Registrar Pago'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
