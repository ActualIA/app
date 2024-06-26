import 'dart:io';

import 'package:flutter/foundation.dart';
import 'mock_directory.dart';
import 'mock_file.dart';

const file ROOT = "mockRoot";
typedef Dir = Map<String, dynamic>;
typedef file = String;

class MockFileSys {
  Dir FILES = {};
  int _depth = 0;

  MockDir deleteDir(MockDir dir) {
    List<String> path = dir.path.split("/");
    removeLastIf(path, (p) => p[p.length - 1].isEmpty);
    int i = 0;
    MockDir? deleted;
    Dir sub = FILES;
    while (i < path.length) {
      if (i == path.length - 1 && sub.containsKey(path[i])) {
        deleted = MockDir(dir.path, this);
        sub.remove(path[i]);
        break;
      } else {
        sub = sub[path[i]];
        i++;
      }
    }
    if (deleted == null) {
      throw FileSystemException("Could not delete dir: ${dir.path}");
    }
    return deleted;
  }

  void removeLastIf(List<String> path, bool Function(List<String>) cond) {
    if (cond(path)) {
      path.removeAt(path.length - 1);
    }
  }

  void addDir(MockDir dir) {
    Dir createSubDir(List<String> consumer, int depth) {
      consumer.removeAt(0);
      if (consumer.isEmpty) {
        _depth = depth;
        return {};
      } else {
        return createSubDir(consumer, depth++);
      }
    }

    List<String> path = dir.path.split('/');
    removeLastIf(path, (p) => p[p.length - 1].isEmpty);
    bool exist = true;
    int depth = 0;
    Dir subFiles = FILES;
    while (exist && depth < path.length) {
      if (subFiles.containsKey(path[depth])) {
        subFiles = subFiles[path[depth]];
        depth++;
      } else {
        exist = false;
        subFiles[path[depth]] = createSubDir(path.sublist(depth), depth++);
      }
    }
  }

  void addFile(MockFile file, String content) {
    dynamic createSubDir(List<String> consumer, int depth) {
      if (consumer.isEmpty) {
        _depth = depth;
        return content;
      } else {
        String head = consumer[0];
        consumer.removeAt(0);
        return {head: createSubDir(consumer, ++depth)};
      }
    }

    List<String> path = file.path.split('/');
    removeLastIf(path, (p) => p[p.length - 1].isEmpty);
    bool exist = true;
    int depth = 0;
    Dir subFiles = FILES;
    while (exist && depth < path.length) {
      if (subFiles.containsKey(path[depth])) {
        if (depth == path.length - 1 &&
            subFiles[path[depth]].runtimeType == String) {
          break;
        } else {
          subFiles = subFiles[path[depth]];
        }
        depth++;
      } else {
        exist = false;
        subFiles[path[depth]] = createSubDir(path.sublist(depth + 1), depth);
      }
    }
  }

  bool pathExist(List<String> path) {
    removeLastIf(path, (p) => p[p.length - 1].isEmpty);
    bool exist = true;
    int i = 0;
    Dir subFiles = FILES;
    if (_depth < path.length - 1) {
      return false;
    }
    while (exist && i < path.length) {
      if (subFiles.containsKey(path[i])) {
        if (i + 1 == path.length) {
          break;
        } else {
          subFiles = subFiles[path[i]];
        }
        i++;
      } else {
        exist = false;
      }
    }
    return exist;
  }

  bool dirExist(MockDir dir) {
    List<String> path = dir.path.split("/");
    return pathExist(path);
  }

  bool fileExist(MockFile file) {
    List<String> path = file.path.split("/");
    return pathExist(path);
  }

  String readFile(MockFile file) {
    List<String> path = file.path.split("/");
    removeLastIf(path, (p) => p[p.length - 1].isEmpty);
    int i = 0;
    String? content;
    Dir sub = FILES;
    while (i < path.length) {
      if (sub[path[i]].runtimeType == String && i == path.length - 1) {
        content = sub[path[i]];
        break;
      } else {
        sub = sub[path[i]];
        i++;
      }
    }
    if (content == null) {
      throw FileSystemException("${file.path} does not exist");
    }
    return content;
  }

  List<MockFile> listAllFiles() {
    List<MockFile> listFiles(Dir dir, String path) {
      List<MockFile> files = List.empty(growable: true);

      for (var entry in dir.keys) {
        if (dir[entry] is String) {
          files.add(MockFile("$path/$entry", this));
        } else if (dir[entry] is Dir) {
          files = listFiles(dir[entry], path.isEmpty ? entry : "$path/$entry");
        }
      }

      return files;
    }

    return listFiles(FILES, "");
  }
}
