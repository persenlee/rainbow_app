import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NetworkImageCacheManager extends BaseCacheManager {
  static const key = "network_image_caches";

  static NetworkImageCacheManager _instance;

  factory NetworkImageCacheManager() {
    if (_instance == null) {
      _instance = new NetworkImageCacheManager._();
    }
    return _instance;
  }

  NetworkImageCacheManager._() : super(key);

  Future<String> getFilePath() async {
    var directory = await getApplicationDocumentsDirectory();

    return p.join(directory.path, key);
  }

  Future<int> cacheSize() async {
    String folderPath =await getFilePath();
    Stream<FileSystemEntity> files = Directory(folderPath).list(recursive: true,followLinks: false);
    int size = (await files.length ~/ 1024);
    return size;
  }

  clean() async {
    String folderPath =await getFilePath();
    Directory dir = Directory(folderPath);
    bool exist = await dir.exists();
    if (exist) {
      dir.delete();
    }
  }
}