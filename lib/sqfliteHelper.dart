import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 单例模式实例
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // 数据库引用
  Database? _database;

  // 工厂构造函数
  factory DatabaseHelper() {
    return _instance;
  }

  // 内部构造函数
  DatabaseHelper._internal();

  // 获取数据库实例
  Future<Database?> get database async {
    if (_database == null) {
      _database = await _initializeDatabase();
    }
    return _database;
  }

  // 初始化数据库
  Future<Database> _initializeDatabase() async {
    // 获取数据库路径
    String path = join(await getDatabasesPath(), 'my_database.db');

    // 打开数据库，如果数据库不存在则创建它 创建的是数据库
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 数据库创建时的回调函数
  Future<void> _onCreate(Database db, int version) async {
    print("_onCreate被调用");
    // 创建表
    await db.execute(
      'CREATE TABLE secret(id INTEGER PRIMARY KEY, secretValue TEXT,name TEXT)',
    );
  }

  // 插入数据
  Future<void> insertItem(Map secret) async {
    final db = await database;
    //插入前删完表里数据，保证只有一条
    await deleteItem();
    print('密钥值：${secret['secret']},文件名:${secret['name']}');
    await db?.insert(
      'secret',
      {'secretValue': secret['secret'], 'name': secret['name']},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 更新数据
  Future<void> updateItem(int id, String secret, String sign) async {
    final db = await database;
    await db?.update(
      'secret',
      {'secretValue': secret},
      // 根据 ID 匹配记录进行更新
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 查询数据
  Future<List<Map<String, dynamic>>> fetchItems() async {
    final db = await database;
    return await db?.query('secret') ?? [];
  }

  // 删除数据
  Future<void> deleteItem() async {
    final db = await database;
    await db?.delete('secret');
  }

//测试删表
  Future<void> deleteTable() async {
    // 获取数据库路径
    String path = join(await getDatabasesPath(), 'my_database.db');

    // 打开数据库
    Database database = await openDatabase(
      path,
      version: 1,
    );

    try {
      // 删除表
      await database.execute('DROP TABLE IF EXISTS secret');
      print('表删除成功');
    } catch (e) {
      print('删除表时出现错误：$e');
    } finally {
      // 关闭数据库连接
      // await database.close();
    }
  }

  //测试已有数据库情况下新建表
  // 新建表
  Future<void> createSecretTable() async {
    final db = await database;
    await db?.execute(
      'CREATE TABLE IF NOT EXISTS secret(id INTEGER PRIMARY KEY, secretValue TEXT, name TEXT)',
    );
  }
}
