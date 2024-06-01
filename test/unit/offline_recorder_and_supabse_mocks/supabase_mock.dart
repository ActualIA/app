import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeDeletePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final FakeDB db;
  final T? selection;

  FakeDeletePostgrestFilterBuilder({required this.db, this.selection});

  @override
  Future<Table> then<Table>(FutureOr<Table> Function(T t) func,
      {Function? onError}) async {
    try {
      return func(selection as T);
    } catch (e) {
      debugPrint("[ERROR] in then: $e");
      return Future.value(null);
    }
  }

  @override
  FakePostgrestFilterBuilder<T> eq(String field, Object val) {
    debugPrint("[DEBUG] call to equal");
    T newSelection = (selection == null
        ? db.getRows(column: field, equal: val) ?? []
        : db.getRowsFromTable(
                table: selection! as Table,
                col: field,
                cond: (obj) => obj == val) ??
            []) as T;
    if (newSelection == []) {
      debugPrint(
          "No row matching the parameter $field and $val has been found, or parameter are invalid");
    }
    db.setProvidersTable(
        table: db
                .getRows()
                ?.where((row) => !(newSelection as Table).contains(row))
                .toList() ??
            []);
    return FakePostgrestFilterBuilder<T>(
        providerDB: db, selection: newSelection);
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final FakeDB providerDB;
  final T? selection;

  FakePostgrestFilterBuilder({required this.providerDB, this.selection});

  @override
  Future<Table> then<Table>(FutureOr<Table> Function(T t) func,
      {Function? onError}) async {
    try {
      return func(selection as T);
    } catch (e) {
      debugPrint("[ERROR] in then: $e");
      return Future.value(null);
    }
  }

  @override
  FakePostgrestFilterBuilder<T> eq(String field, Object val) {
    T newSelection = (selection == null
        ? providerDB.getRows(column: field, equal: val) ?? []
        : providerDB.getRowsFromTable(
                table: selection! as Table,
                col: field,
                cond: (obj) => obj == val) ??
            []) as T;
    if (newSelection == []) {
      debugPrint(
          "No row matching the parameter $field and $val has been found, or parameter are invalid");
    }
    return FakePostgrestFilterBuilder<T>(
        providerDB: providerDB, selection: newSelection);
  }

  @override
  PostgrestFilterBuilder<T> gte(String column, Object value) {
    T newSelection = (selection == null
        ? providerDB.getRows(column: column, equal: value) ?? []
        : providerDB.getRowsFromTable(
                table: selection! as Table,
                col: column,
                cond: (obj) {
                  switch (column) {
                    case "date":
                      DateTime d1 = DateTime.parse(obj as String);
                      DateTime d2 = DateTime.parse(value as String);
                      return d1.isAfter(d2) || d1.isAtSameMomentAs(d2);
                    default:
                      return false;
                  }
                }) ??
            []) as T;
    if (newSelection == []) {
      debugPrint(
          "No row matching the parameter $column and $value has been found, or parameter are invalid");
    }
    return FakePostgrestFilterBuilder(
        providerDB: providerDB, selection: newSelection);
  }

  @override
  PostgrestFilterBuilder<T> lt(String column, Object value) {
    T newSelection = (selection == null
        ? providerDB.getRows(column: column, equal: value) ?? []
        : providerDB.getRowsFromTable(
                table: selection! as Table,
                col: column,
                cond: (obj) {
                  switch (column) {
                    case "date":
                      DateTime d1 = DateTime.parse(obj as String);
                      DateTime d2 = DateTime.parse(value as String);
                      return d1.isBefore(d2);
                    default:
                      return false;
                  }
                }) ??
            []) as T;
    if (newSelection == []) {
      debugPrint(
          "No row matching the parameter $column and $value has been found, or parameter are invalid");
    }
    return FakePostgrestFilterBuilder(
        providerDB: providerDB, selection: newSelection);
  }

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = false,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    return FakePostgrestFilterBuilder(
        providerDB: providerDB, selection: selection);
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    if (selection == null) {
      debugPrint("Nothing to select from");
      return FakePostgrestFilterBuilder(providerDB: providerDB);
    } else if ((selection! as Table).length > 1) {
      debugPrint("More than one element in selection");
      return FakePostgrestFilterBuilder(providerDB: providerDB);
    } else {
      return FakePostgrestFilterBuilder(providerDB: providerDB);
    }
  }
}

class FakeQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final Table table;
  final FakeDB db;

  FakeQueryBuilder({required this.table, required this.db});

  @override
  PostgrestFilterBuilder upsert(Object values,
      {String? onConflict,
      bool ignoreDuplicates = false,
      bool defaultToNull = true}) {
    debugPrint("[DEBUG] call to upsert");
    Table newTable = table.toList();
    Table val;
    try {
      val = values as Table;
    } catch (e) {
      val = [values as Row];
    }
    newTable.addAll(val);
    db.setProvidersTable(table: newTable);
    return FakePostgrestFilterBuilder(providerDB: db);
  }

  @override
  PostgrestFilterBuilder<Table> select([String s = ""]) {
    return FakePostgrestFilterBuilder<Table>(providerDB: db, selection: table);
  }

  @override
  PostgrestFilterBuilder<Table> delete() {
    debugPrint("[DEBUG] call to delete");
    return FakeDeletePostgrestFilterBuilder(db: db, selection: table);
  }
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  User? get currentUser => const User(
      id: "1234",
      appMetadata: <String, dynamic>{},
      userMetadata: <String, dynamic>{},
      aud: "aud",
      createdAt: "createdAt");
}

typedef Row = Map<String, dynamic>;
typedef Table = List<Row>;

class FakeDB extends Fake implements SupabaseClient {
  Table _providersTables;
  Table _newsTable;

  FakeDB([this._providersTables = const [], this._newsTable = const []]);

  Table get providersTable => _providersTables;
  void setProvidersTable({required Table table}) => _providersTables = table;

  void addRow(Row row) {
    _providersTables.add(row);
  }

  Table? getRowsFromTable(
      {required Table table, String? col, bool Function(Object val)? cond}) {
    debugPrint("[DEBUG] get from table: $table");
    if (col == null) {
      debugPrint("[DEBUG] get row column null, return: $table");
      return table;
    } else if (cond != null) {
      bool columnExist = table.isEmpty ? false : table[0].containsKey(col);
      if (!columnExist) {
        debugPrint("$col does not exist in table");
        return null;
      }
      Table res = [];
      for (var row in table) {
        if (row.containsKey(col) && cond(row[col])) {
          res.add(row);
        }
      }
      debugPrint("[DEBUG] get row res: $res");
      return res;
    } else {
      debugPrint(
          "If column not null, then equal should not be null, cond is: $cond");
      return null;
    }
  }

  Table? getRows({String? column, Object? equal}) {
    if (column == null) {
      debugPrint("[DEBUG] get row column null, return: $_providersTables");
      return _providersTables;
    } else if (equal != null) {
      bool columnExist = providersTable.isEmpty
          ? false
          : providersTable[0].containsKey(column);
      if (!columnExist) {
        debugPrint("$column does not exist in table");
        return null;
      }
      Table res = [];
      for (var row in _providersTables) {
        if (row.containsKey(column) && row[column] == equal) {
          res.add(row);
        }
      }
      debugPrint("[DEBUG] get row res: $res");
      return res;
    } else {
      debugPrint(
          "If column not null, then equal should not be null, equal is: $equal");
      return null;
    }
  }

  @override
  SupabaseQueryBuilder from(String table) {
    switch (table) {
      case "providers":
        return FakeQueryBuilder(table: _providersTables, db: this);
      case "news":
        return FakeQueryBuilder(table: _newsTable, db: this);
      default:
        return FakeQueryBuilder(table: _newsTable, db: this);
    }
  }

  @override
  GoTrueClient get auth {
    return FakeGoTrueClient();
  }
}
