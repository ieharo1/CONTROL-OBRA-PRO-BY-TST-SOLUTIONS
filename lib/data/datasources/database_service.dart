import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cobranza_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        photoPath TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        clientUuid TEXT NOT NULL,
        concept TEXT NOT NULL,
        amount REAL NOT NULL,
        interest REAL DEFAULT 0,
        date TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        status INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (clientUuid) REFERENCES clients (uuid) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        debtUuid TEXT NOT NULL,
        amount REAL NOT NULL,
        method TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (debtUuid) REFERENCES debts (uuid) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_debts_client ON debts (clientUuid)');
    await db.execute('CREATE INDEX idx_debts_status ON debts (status)');
    await db.execute('CREATE INDEX idx_payments_debt ON payments (debtUuid)');
  }

  Future<String> exportDatabase() async {
    final db = await database;
    
    final clients = await db.query('clients');
    final debts = await db.query('debts');
    final payments = await db.query('payments');

    final data = {
      'clients': clients,
      'debts': debts,
      'payments': payments,
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
    };

    return jsonEncode(data);
  }

  Future<void> importDatabase(String jsonData) async {
    final db = await database;
    final data = jsonDecode(jsonData) as Map<String, dynamic>;

    await db.transaction((txn) async {
      await txn.delete('payments');
      await txn.delete('debts');
      await txn.delete('clients');

      final clients = data['clients'] as List;
      for (final client in clients) {
        await txn.insert('clients', Map<String, dynamic>.from(client));
      }

      final debts = data['debts'] as List;
      for (final debt in debts) {
        await txn.insert('debts', Map<String, dynamic>.from(debt));
      }

      final payments = data['payments'] as List;
      for (final payment in payments) {
        await txn.insert('payments', Map<String, dynamic>.from(payment));
      }
    });
  }

  Future<File> getBackupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return File('${directory.path}/cobranza_pro_backup_$timestamp.json');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
