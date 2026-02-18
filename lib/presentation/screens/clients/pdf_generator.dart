import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../data/models/client.dart';
import '../../../data/models/debt.dart';
import '../../../data/repositories/payment_repository.dart';

Future<void> generateClientPdf(BuildContext context, Client client, List<Debt> debts) async {
  final pdf = pw.Document();
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final dateFormat = DateFormat.yMd();

  final paymentRepo = PaymentRepository();

  List<List<dynamic>> debtRows = [];
  double totalPending = 0;
  double totalPaid = 0;

  for (final debt in debts) {
    final payments = await paymentRepo.getByDebtUuid(debt.uuid);
    double paidAmount = payments.fold(0, (sum, p) => sum + p.amount);
    double pendingAmount = debt.totalAmount - paidAmount;

    totalPending += pendingAmount;
    totalPaid += paidAmount;

    debtRows.add([
      debt.concept,
      dateFormat.format(debt.date),
      dateFormat.format(debt.dueDate),
      currencyFormat.format(debt.totalAmount),
      currencyFormat.format(paidAmount),
      currencyFormat.format(pendingAmount),
      debt.status.name.toUpperCase(),
    ]);
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('COBRANZA PRO BY TST SOLUTIONS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Reporte de Cliente', style: const pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Datos del Cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Nombre: ${client.name}')),
                  pw.Expanded(child: pw.Text('Telefono: ${client.phone ?? "N/A"}')),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Direccion: ${client.address ?? "N/A"}'),
              if (client.notes != null && client.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Notas: ${client.notes}'),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Historial de Deudas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellPadding: const pw.EdgeInsets.all(4),
          cellAlignment: pw.Alignment.centerLeft,
          headers: ['Concepto', 'Fecha', 'Vence', 'Total', 'Pagado', 'Pendiente', 'Estado'],
          data: debtRows,
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(8)),
          child: pw.Column(
            children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total Pendiente:'), pw.Text(currencyFormat.format(totalPending), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]),
              pw.SizedBox(height: 4),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Total Pagado:'), pw.Text(currencyFormat.format(totalPaid))]),
            ],
          ),
        ),
      ],
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text('Generado con COBRANZA PRO BY TST SOLUTIONS', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
