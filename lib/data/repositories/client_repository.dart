import 'package:uuid/uuid.dart';
import '../datasources/database_service.dart';
import '../models/client.dart';

class ClientRepository {
  final DatabaseService _db = DatabaseService.instance;
  final _uuid = const Uuid();

  Future<List<Client>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('clients', orderBy: 'name ASC');
    return maps.map((map) => Client.fromMap(map)).toList();
  }

  Future<Client?> getByUuid(String uuid) async {
    final db = await _db.database;
    final maps = await db.query(
      'clients',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return Client.fromMap(maps.first);
  }

  Future<Client> create({
    required String name,
    String? phone,
    String? address,
    String? photoPath,
    String? notes,
  }) async {
    final db = await _db.database;
    final now = DateTime.now();
    final client = Client(
      uuid: _uuid.v4(),
      name: name,
      phone: phone,
      address: address,
      photoPath: photoPath,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('clients', client.toMap()..remove('id'));
    return client;
  }

  Future<Client> update(Client client) async {
    final db = await _db.database;
    final updated = client.copyWith(updatedAt: DateTime.now());
    await db.update(
      'clients',
      updated.toMap()..remove('id'),
      where: 'uuid = ?',
      whereArgs: [client.uuid],
    );
    return updated;
  }

  Future<void> delete(String uuid) async {
    final db = await _db.database;
    await db.delete('clients', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<List<Client>> search(String query) async {
    final db = await _db.database;
    final maps = await db.query(
      'clients',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Client.fromMap(map)).toList();
  }

  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM clients');
    return result.first['count'] as int;
  }
}
