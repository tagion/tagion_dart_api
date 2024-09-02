import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class IPathProvider<T> {
  Future<T?> getApplpicationDocumentsPath();
}

class PathProvider implements IPathProvider<String> {
  PathProvider();

  @override
  Future<String> getApplpicationDocumentsPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
