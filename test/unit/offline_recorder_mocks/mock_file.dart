import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'mock_filesystem.dart';

class MockFile extends Fake implements File {
  late final String _path;
  late MockFileSys files;
  late final int _size;

  MockFile(String path, this.files, {int size = 0}) {
    _path = path;
    _size = size;
  }

  @override
  Future<bool> exists() async {
    return files.fileExist(this);
  }

  @override
  String get path => _path;

  @override
  int get size => _size;

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return files.readFile(this);
  }

  @override
  FileStat statSync() {
    return MockFileStat(size: _size);
  }

  @override
  Future<File> writeAsString(String contents,
      {FileMode mode = FileMode.write,
      Encoding encoding = utf8,
      bool flush = false}) async {
    files.addFile(this, contents);
    return this;
  }
}

class MockFileStat extends Fake implements FileStat {
  late final int _size;

  MockFileStat({int size = 0}) {
    _size = size;
  }

  @override
  int get size => _size;
}
