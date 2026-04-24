// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> replaceDatabaseIfUpdated() async {
  final databasePath = await getDatabasesPath();
  final dbPath = join(databasePath, 'dulang.db');

  // Verifique se o banco de dados já existe
  if (await databaseExists(dbPath)) {
    await deleteDatabase(dbPath); // Apaga o banco existente
  }

  // Copie o novo banco de dados do bundle de recursos para o local correto
  final newDbPath = 'assets/sqlite_db_files/dulang.db';
  final byteData = await File(newDbPath).readAsBytes();
  final file = File(dbPath);
  await file.writeAsBytes(byteData);
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
