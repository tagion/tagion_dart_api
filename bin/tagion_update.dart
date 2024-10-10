import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

const String checksumFile = "checksum.json";
const String ownerName = "tagion";
const String repoName = "tagion";

const List<String> artifacts = [
  "aarch64-linux-android",
  "armv7a-linux-android",
  "x86_64-linux-android",
  "arm64-apple-ios",
  "x86_64-apple-ios-simulator"
];

const _versionArg = 'version';
const _gitHashArg = 'git-hash';
const _gitTypeArg = 'git';

String? version;
String? gitHash;
bool isGitType = false;

// TODO Implement the following steps:
// 1. Compare dowloaded binaries with the checksums in the checksum.json file.
// 2. Add function to dowload a specific release by tag.

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(_versionArg, help: 'Specifies the version of the release.')
    ..addOption(_gitHashArg, help: 'Specifies the Git hash of the release.')
    ..addFlag(_gitTypeArg, negatable: false, help: 'Indicates that the release type is Git.');

  // Parse the arguments
  final argResults = parser.parse(arguments);

  // Accessing the parsed arguments
  version = argResults[_versionArg];
  gitHash = argResults[_gitHashArg];
  isGitType = argResults[_gitTypeArg];

  String tempDir = await createTempDir();
  stdout.writeln("Created temporary directory: $tempDir");

  var releaseData = await getLatestReleaseData();
  String releaseTag = releaseData['tag_name'];
  stdout.writeln("Latest release: $releaseTag");

  var assets = releaseData['assets'];

  // Download and extract each artifact
  for (String artifactName in artifacts) {
    String? downloadUrl = getDownloadUrlForArtifact(assets, artifactName);
    if (downloadUrl != null) {
      stdout.writeln("Downloading $artifactName from $downloadUrl...");
      await downloadAndUnzipArtifact(artifactName, downloadUrl, tempDir);
    } else {
      stderr.writeln("Artifact $artifactName not found in the release.");
      await deleteTempDir(tempDir);
      exit(1);
    }
  }

  stdout.writeln("Copying binaries to the pub cache directory...");
  await copyBinaries(tempDir);
  stdout.writeln("Binaries copied successfully!");
  await deleteTempDir(tempDir);
  stdout.writeln("Deleted temporary directory: $tempDir");
  stdout.writeln("All done!");
}

Future<String> createTempDir() async {
  String rootDir = Directory.current.path;
  String tempDir = path.join(rootDir, 'temp_${DateTime.now().millisecondsSinceEpoch}');
  await Directory(tempDir).create(recursive: true);
  return tempDir;
}

Future<Map<String, dynamic>> getLatestReleaseData() async {
  var response = await http.get(
    Uri.parse("https://api.github.com/repos/$ownerName/$repoName/releases/latest"),
    headers: {
      'Accept': 'application/vnd.github.v3+json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to fetch latest release data.");
  }

  return jsonDecode(response.body);
}

String? getDownloadUrlForArtifact(List<dynamic> assets, String artifactName) {
  for (var asset in assets) {
    if (asset['name'] == "$artifactName.zip") {
      return asset['browser_download_url'];
    }
  }
  return null;
}

Future<void> downloadAndUnzipArtifact(String artifactName, String url, String tempDir) async {
  String zipFilePath = path.join(tempDir, "$artifactName.zip");
  var response = await http.get(Uri.parse(url), headers: {});

  await File(zipFilePath).writeAsBytes(response.bodyBytes);
  await Process.run('unzip', [zipFilePath, '-d', path.join(tempDir, artifactName)]);
}

// Resolve pub cache directory depending no the platform.
String resolvePubCacheDirPath() {
  final homeDirPath = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (Platform.isWindows) {
    return path.join(homeDirPath!, 'AppData', 'Roaming', 'Pub', 'Cache');
  } else if (Platform.isMacOS) {
    return path.join(homeDirPath!, '.pub-cache');
  } else if (Platform.isLinux) {
    return path.join(homeDirPath!, '.pub-cache');
  } else {
    throw Exception("Unsupported platform.");
  }
}

String getCurrentVersion() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml file not found.');
    exit(1);
  }
  final pubspecContent = pubspecFile.readAsStringSync();
  final yamlMap = loadYaml(pubspecContent);
  final version = yamlMap['dependencies']['tagion_dart_api'];
  return version.replaceFirst('^', '');
}

String resolveHostedPackageDirPath(String pubCacheDirPath) {
  String resolvedVersion = version ?? getCurrentVersion();
  return path.join(pubCacheDirPath, 'hosted', 'pub.dev', 'tagion_dart_api-$resolvedVersion');
}

String resolveGitPackageDirPath(String pubCacheDirPath) {
  return path.join(pubCacheDirPath, 'git', 'tagion_dart_api-$gitHash');
}

Future<void> copyBinaries(String tempDir) async {
  String pubCacheDirPath = resolvePubCacheDirPath();
  String hostedPubCacheDirPath =
      isGitType ? resolveGitPackageDirPath(pubCacheDirPath) : resolveHostedPackageDirPath(pubCacheDirPath);
  String androidJniLibsDirPath = path.join(hostedPubCacheDirPath, 'android', 'src', 'main', 'jniLibs');

  // Android binaries
  await copyFile(
      path.join(tempDir, 'aarch64-linux-android', 'aarch64-linux-android', 'lib',
          'libmobile.so'), // TODO: rename back to libtauonapi.so
      path.join(androidJniLibsDirPath, 'arm64-v8a'),
      'libtauonapi.so',
      createDir: true);

  await copyFile(
      path.join(tempDir, 'armv7a-linux-android', 'armv7a-linux-android', 'lib',
          'libmobile.so'), // TODO: rename back to libtauonapi.so
      path.join(androidJniLibsDirPath, 'armeabi-v7a'),
      'libtauonapi.so',
      createDir: true);

  await copyFile(
      path.join(tempDir, 'x86_64-linux-android', 'x86_64-linux-android', 'lib',
          'libmobile.so'), // TODO: rename back to libtauonapi.so
      path.join(androidJniLibsDirPath, 'x86-64'),
      'libtauonapi.so',
      createDir: true);

  // iOS binaries
  String iosFrameworkDirPath = path.join(hostedPubCacheDirPath, 'ios', 'libtauonapi.xcframework');

  await copyFile(
      path.join(tempDir, 'arm64-apple-ios', 'libmobile.dylib'), // TODO: rename back to libtauonapi.dylib
      path.join(iosFrameworkDirPath, 'ios-arm64', 'libtauonapi.framework'),
      'libtauonapi');
  await modifyIOSBinary(path.join(iosFrameworkDirPath, 'ios-arm64', 'libtauonapi.framework'));

  await copyFile(
      path.join(tempDir, 'x86_64-apple-ios-simulator', 'libmobile.dylib'), // TODO: rename back to libtauonapi.dylib
      path.join(iosFrameworkDirPath, 'ios-x86_64-simulator', 'libtauonapi.framework'),
      'libtauonapi');
  await modifyIOSBinary(path.join(iosFrameworkDirPath, 'ios-x86_64-simulator', 'libtauonapi.framework'));
}

Future<void> copyFile(String source, String destination, String fileName, {bool createDir = false}) async {
  if (createDir) {
    await Directory(destination).create(recursive: true);
  }
  await File(source).copy('$destination/$fileName');
}

Future<void> modifyIOSBinary(String iosBinaryPath) async {
  await Process.run('lipo', ['-create', 'libmobile.dylib', '-output', 'libtauonapi'],
      workingDirectory: iosBinaryPath); // TODO: rename back to libtauonapi.dylib
  await Process.run('install_name_tool', ['-id', '@rpath/libtauonapi.framework/libtauonapi', 'libtauonapi'],
      workingDirectory: iosBinaryPath);
  await Process.run('rm', ['-rf', 'libmobile.dylib'],
      workingDirectory: iosBinaryPath); // TODO: rename back to libtauonapi.dylib
}

Future<void> deleteTempDir(String tempDir) async {
  await Directory(tempDir).delete(recursive: true);
}
