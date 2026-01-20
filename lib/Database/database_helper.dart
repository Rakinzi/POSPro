import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/pos_offline.db';
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        status TEXT DEFAULT 'pending',
        error_message TEXT
      )
    ''');

    // Create offline sales table
    await db.execute('''
      CREATE TABLE offline_sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        party_id INTEGER,
        customer_phone TEXT,
        sale_date TEXT NOT NULL,
        discount_amount REAL NOT NULL,
        discount_percent REAL NOT NULL,
        total_amount REAL NOT NULL,
        due_amount REAL NOT NULL,
        vat_amount REAL NOT NULL,
        vat_percent REAL NOT NULL,
        vat_id INTEGER,
        change_amount REAL NOT NULL,
        is_paid INTEGER NOT NULL,
        payment_type TEXT NOT NULL,
        rounded_option TEXT NOT NULL,
        rounding_amount REAL NOT NULL,
        unrounded_total_amount REAL NOT NULL,
        discount_type TEXT NOT NULL,
        shipping_charge REAL NOT NULL,
        note TEXT,
        products TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create offline purchases table
    await db.execute('''
      CREATE TABLE offline_purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        party_id INTEGER NOT NULL,
        vat_id INTEGER,
        purchase_date TEXT NOT NULL,
        discount_amount REAL NOT NULL,
        discount_percent REAL NOT NULL,
        total_amount REAL NOT NULL,
        vat_amount REAL NOT NULL,
        vat_percent REAL NOT NULL,
        due_amount REAL NOT NULL,
        change_amount REAL NOT NULL,
        is_paid INTEGER NOT NULL,
        payment_type TEXT NOT NULL,
        discount_type TEXT NOT NULL,
        shipping_charge REAL NOT NULL,
        products TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create offline products table
    await db.execute('''
      CREATE TABLE offline_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_data TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create cached sales table
    await db.execute('''
      CREATE TABLE cached_sales (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create cached products table
    await db.execute('''
      CREATE TABLE cached_products (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create cached meta table
    await db.execute('''
      CREATE TABLE cached_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create user credentials table for offline login
    await db.execute('''
      CREATE TABLE user_credentials (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        token TEXT,
        user_data TEXT,
        is_setup INTEGER DEFAULT 0,
        currency_symbol TEXT,
        currency_name TEXT,
        last_login TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add user credentials table for offline login
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_credentials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          token TEXT,
          user_data TEXT,
          is_setup INTEGER DEFAULT 0,
          currency_symbol TEXT,
          currency_name TEXT,
          last_login TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE offline_sales ADD COLUMN image_path TEXT');
      await db.execute('ALTER TABLE offline_products ADD COLUMN image_path TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cached_sales (
          id INTEGER PRIMARY KEY,
          data TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cached_products (
          id INTEGER PRIMARY KEY,
          data TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS cached_meta (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }
  }

  // Sync Queue Operations
  Future<int> addToSyncQueue({
    required String operationType,
    required String endpoint,
    required String data,
  }) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'operation_type': operationType,
      'endpoint': endpoint,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> markSyncItemAsCompleted(int id) async {
    final db = await database;
    await db.update(
      'sync_queue',
      {'status': 'completed'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSyncItemRetry(int id, String errorMessage) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE sync_queue
      SET retry_count = retry_count + 1,
          error_message = ?
      WHERE id = ?
    ''', [errorMessage, id]);
  }

  Future<void> deleteSyncItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // Offline Sales Operations
  Future<int> saveOfflineSale(Map<String, dynamic> saleData) async {
    final db = await database;
    saleData['created_at'] = DateTime.now().toIso8601String();
    saleData['synced'] = 0;
    return await db.insert('offline_sales', saleData);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedSales() async {
    final db = await database;
    return await db.query(
      'offline_sales',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markSaleAsSynced(int id) async {
    final db = await database;
    await db.update(
      'offline_sales',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Offline Purchase Operations
  Future<int> saveOfflinePurchase(Map<String, dynamic> purchaseData) async {
    final db = await database;
    purchaseData['created_at'] = DateTime.now().toIso8601String();
    purchaseData['synced'] = 0;
    return await db.insert('offline_purchases', purchaseData);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedPurchases() async {
    final db = await database;
    return await db.query(
      'offline_purchases',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markPurchaseAsSynced(int id) async {
    final db = await database;
    await db.update(
      'offline_purchases',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Offline Product Operations
  Future<int> saveOfflineProduct(String productData, {String? imagePath}) async {
    final db = await database;
    return await db.insert('offline_products', {
      'product_data': productData,
      'image_path': imagePath,
      'created_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUnsyncedProducts() async {
    final db = await database;
    return await db.query(
      'offline_products',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markProductAsSynced(int id) async {
    final db = await database;
    await db.update(
      'offline_products',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get count of pending sync items
  Future<int> getPendingSyncCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        (SELECT COUNT(*) FROM sync_queue WHERE status = 'pending') +
        (SELECT COUNT(*) FROM offline_sales WHERE synced = 0) +
        (SELECT COUNT(*) FROM offline_purchases WHERE synced = 0) +
        (SELECT COUNT(*) FROM offline_products WHERE synced = 0) as total
    ''');
    return result.first['total'] as int;
  }

  // Clear all synced data
  Future<void> clearSyncedData() async {
    final db = await database;
    await db.delete('sync_queue', where: 'status = ?', whereArgs: ['completed']);
    await db.delete('offline_sales', where: 'synced = ?', whereArgs: [1]);
    await db.delete('offline_purchases', where: 'synced = ?', whereArgs: [1]);
    await db.delete('offline_products', where: 'synced = ?', whereArgs: [1]);
  }

  // Cached Sales Operations
  Future<void> upsertCachedSales(List<Map<String, dynamic>> sales) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (final sale in sales) {
      final id = sale['id'];
      if (id == null) continue;
      batch.insert(
        'cached_sales',
        {
          'id': id,
          'data': jsonEncode(sale),
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedSales() async {
    final db = await database;
    return await db.query('cached_sales', orderBy: 'updated_at DESC');
  }

  // Cached Products Operations
  Future<void> upsertCachedProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (final product in products) {
      final id = product['id'];
      if (id == null) continue;
      batch.insert(
        'cached_products',
        {
          'id': id,
          'data': jsonEncode(product),
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedProducts() async {
    final db = await database;
    return await db.query('cached_products', orderBy: 'updated_at DESC');
  }

  Future<void> setCachedMeta(String key, String value) async {
    final db = await database;
    await db.insert(
      'cached_meta',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCachedMeta(String key) async {
    final db = await database;
    final rows = await db.query('cached_meta', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<List<dynamic>> getCachedList(String key) async {
    final value = await getCachedMeta(key);
    if (value == null || value.isEmpty) return [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) return decoded;
    } catch (_) {}
    return [];
  }

  Future<void> setCachedList(String key, List<dynamic> list) async {
    await setCachedMeta(key, jsonEncode(list));
  }

  Future<Map<String, dynamic>?> findCachedItem(String key, dynamic id, {String idField = 'id'}) async {
    final list = await getCachedList(key);
    for (final item in list) {
      if (item is Map && item[idField].toString() == id.toString()) {
        return Map<String, dynamic>.from(item);
      }
    }
    return null;
  }

  Future<void> upsertCachedListItem(String key, Map<String, dynamic> item, {String idField = 'id'}) async {
    final list = await getCachedList(key);
    final id = item[idField];
    bool updated = false;
    for (int i = 0; i < list.length; i++) {
      final existing = list[i];
      if (existing is Map && existing[idField].toString() == id.toString()) {
        list[i] = item;
        updated = true;
        break;
      }
    }
    if (!updated) {
      list.insert(0, item);
    }
    await setCachedList(key, list);
  }

  Future<void> removeCachedListItem(String key, dynamic id, {String idField = 'id'}) async {
    final list = await getCachedList(key);
    list.removeWhere((item) => item is Map && item[idField].toString() == id.toString());
    await setCachedList(key, list);
  }

  // User Credentials Operations for Offline Login
  Future<int> saveUserCredentials({
    required String email,
    required String passwordHash,
    String? token,
    String? userData,
    int isSetup = 0,
    String? currencySymbol,
    String? currencyName,
  }) async {
    final db = await database;

    // Check if user already exists
    final existing = await db.query(
      'user_credentials',
      where: 'email = ?',
      whereArgs: [email],
    );

    final data = {
      'email': email,
      'password_hash': passwordHash,
      'token': token,
      'user_data': userData,
      'is_setup': isSetup,
      'currency_symbol': currencySymbol,
      'currency_name': currencyName,
      'last_login': DateTime.now().toIso8601String(),
    };

    if (existing.isNotEmpty) {
      // Update existing user
      return await db.update(
        'user_credentials',
        data,
        where: 'email = ?',
        whereArgs: [email],
      );
    } else {
      // Insert new user
      data['created_at'] = DateTime.now().toIso8601String();
      return await db.insert('user_credentials', data);
    }
  }

  Future<Map<String, dynamic>?> getUserCredentials(String email) async {
    final db = await database;
    final results = await db.query(
      'user_credentials',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> validateOfflineCredentials(String email, String passwordHash) async {
    final user = await getUserCredentials(email);
    if (user == null) return false;
    return user['password_hash'] == passwordHash;
  }

  Future<void> updateLastLogin(String email) async {
    final db = await database;
    await db.update(
      'user_credentials',
      {'last_login': DateTime.now().toIso8601String()},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<void> deleteUserCredentials(String email) async {
    final db = await database;
    await db.delete('user_credentials', where: 'email = ?', whereArgs: [email]);
  }
}
