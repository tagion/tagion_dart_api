import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract interface class IPathProvider<T> {
  Future<T?> getApplpicationDocumentsPath();
}

// App path prodiver that uses adapter pattern to wrap the path_provider package
class PathProvider implements IPathProvider<String> {
  PathProvider();

  @override
  Future<String> getApplpicationDocumentsPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
