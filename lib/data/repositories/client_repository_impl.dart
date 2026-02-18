import 'package:cobranza_pro/data/datasources/database_service.dart';
import 'package:cobranza_pro/data/models/client_model.dart';
import 'package:cobranza_pro/domain/entities/entities.dart';
import 'package:cobranza_pro/domain/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  @override
  Future<List<Client>> getAllClients() async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('clients', orderBy: 'name ASC');
    return maps.map((m) => ClientModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<Client?> getClientById(String id) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query('clients', where: 'uuid = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ClientModel.fromMap(maps.first).toEntity();
  }

  @override
  Future<List<Client>> searchClients(String query) async {
    final db = await DatabaseService.instance.database;
    final maps = await db.query(
      'clients',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps.map((m) => ClientModel.fromMap(m).toEntity()).toList();
  }

  @override
  Future<Client> createClient(Client client) async {
    final db = await DatabaseService.instance.database;
    final model = ClientModel.fromEntity(client);
    await db.insert('clients', model.toMap());
    return client;
  }

  @override
  Future<Client> updateClient(Client client) async {
    final db = await DatabaseService.instance.database;
    final model = ClientModel.fromEntity(client);
    await db.update('clients', model.toMap(), where: 'uuid = ?', whereArgs: [client.id]);
    return client;
  }

  @override
  Future<void> deleteClient(String id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('clients', where: 'uuid = ?', whereArgs: [id]);
  }
}
