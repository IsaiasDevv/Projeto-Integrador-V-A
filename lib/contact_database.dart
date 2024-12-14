import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';

class ContactDatabase {
  static final ContactDatabase instance = ContactDatabase._init();

  static Database? _database;

  ContactDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Adicionando um método de upgrade
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE contacts (
        id $idType,
        name $textType,
        phone $textType,
        email $textType
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Essa função é chamada para atualizações do banco
    if (oldVersion < newVersion) {
      // Ações para upgrade do banco de dados, se necessário
    }
  }

  Future<Contact> createContact(Contact contact) async {
    final db = await instance.database;
    final id = await db.insert('contacts', contact.toMap());
    return contact.copyWith(id: id);
  }

  Future<Contact?> readContact(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'contacts',
      columns: ['id', 'name', 'phone', 'email'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Contact>> readAllContacts() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('contacts', orderBy: orderBy);
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  Future<int> updateContact(Contact contact) async {
    final db = await instance.database;
    return db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await instance.database;
    return db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
