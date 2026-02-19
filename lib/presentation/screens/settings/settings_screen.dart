import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/datasources/database_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Respaldar Datos'),
            subtitle: const Text('Exportar base de datos'),
            onTap: () => _exportBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar Datos'),
            subtitle: const Text('Importar respaldo'),
            onTap: () => _importBackup(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final dbService = DatabaseService.instance;
      final jsonData = await dbService.exportDatabase();
      final file = await dbService.getBackupFile();
      await file.writeAsString(jsonData);
      
      if (context.mounted) {
        await Share.shareXFiles([XFile(file.path)], text: 'Control Obra Pro Backup');
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Respaldo creado')));
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar Datos'),
        content: const Text('¿Está seguro? Esto reemplazará todos los datos actuales.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restaurar')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Funcionalidad de importación en desarrollo')));
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
