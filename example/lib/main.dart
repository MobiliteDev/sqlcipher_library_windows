import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sqlcipher_library_windows/sqlcipher_library_windows.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton(
                onPressed: testSQLCipherOnWindows, child: Text("Test"))
          ],
        ),
      ),
    );
  }

  late sql.Database _db;

  /// Create crypted database on Windows
  void testSQLCipherOnWindows() async {
    if (Platform.isWindows == false) {
    } else {
      open.overrideFor(OperatingSystem.windows, openSQLCipherOnWindows);
    }

    //Create DB with password

    final String password = "test";
    //Local DB file path
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String filename = "$appDocPath${Platform.pathSeparator}testDB.sqlite";

    _db = sql.sqlite3.open(filename, mode: sql.OpenMode.readWriteCreate);
    if (_db.handle.address > 0) {
      print("Database created here: $filename");
      _db.execute("PRAGMA key = '$password'");
      print("Database password set: $password");
    }
    getVersion();

    createSchema();
    insertRows();
    readRows();
  }

  ///Create Schema
  void createSchema() {
    // Create a table and insert some data
    _db.execute('''
    CREATE TABLE IF NOT EXISTS artists  (
      id INTEGER NOT NULL PRIMARY KEY,
      name TEXT NOT NULL
    );
  ''');
  }

  ///create rows
  void insertRows() {
    // Prepare a statement to run it multiple times:
    final dynamic stmt = _db.prepare('INSERT INTO artists (name) VALUES (?)');
    stmt
      ..execute(['The Beatles'])
      ..execute(['Led Zeppelin'])
      ..execute(['The Who'])
      ..execute(['Nirvana']);

    // Dispose a statement when you don't need it anymore to clean up resources.
    stmt.dispose();
  }

  ///Read rows
  void readRows() {
    // You can run select statements with PreparedStatement.select, or directly
    // on the database:
    final sql.ResultSet resultSet =
        _db.select('SELECT * FROM artists WHERE name LIKE ?', ['The %']);

    // You can iterate on the result set in multiple ways to retrieve Row objects
    // one by one.
    resultSet.forEach((element) {
      print(element);
    });
    for (final sql.Row row in resultSet) {
      print('Artist[id: ${row['id']}, name: ${row['name']}]');
    }
  }

  ///Get Sqlite Version and SQLCipher version
  void getVersion() {
    final sql.ResultSet resultSet = _db.select("SELECT sqlite_version()");
    resultSet.forEach((element) {
      print(element);
    });

    final sql.ResultSet resultSet2 = _db.select("PRAGMA cipher_version");
    resultSet2.forEach((element) {
      print(element);
    });
  }
}
