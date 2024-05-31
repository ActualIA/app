import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_file.dart';
import 'mock_filesystem.dart';

class MockDir extends Fake implements Directory {
  late final String _path;
  late MockFileSys files;
  late final int _size;

  MockDir(String path, this.files, {int size = 0}) {
    _path = path;
    files.addDir(this);
    _size = size;
  }

  @override
  Future<Directory> create({bool recursive = false}) async {
    files.addDir(this);
    return this;
  }

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async {
    return files.deleteDir(this);
  }

  @override
  Future<bool> exists() async {
    return files.dirExist(this);
  }

  @override
  Stream<FileSystemEntity> list(
      {bool recursive = false, bool followLinks = true}) {
    return Stream.fromIterable(files.listAllFiles());
  }

  @override
  String get path => _path;

  @override
  FileStat statSync() {
    return MockFileStat(size: _size);
  }
}
