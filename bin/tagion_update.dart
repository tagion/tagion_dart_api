import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

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

  stdout.writeln('Version: $version');
  stdout.writeln('Git hash: $gitHash');
  stdout.writeln('Is Git type: $isGitType');

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

  await copyBinaries(tempDir);
  await deleteTempDir(tempDir);
  stdout.writeln("Deleted temporary directory: $tempDir");

  // await runExternalScript("./update_checksum.sh");

  // String runId = releaseData['id'].toString();
  // await runExternalScript("./update_run_id_github.sh", [runId]);
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

String resolveHostedPackageDirPath(String pubCacheDirPath) {
  return path.join(pubCacheDirPath, 'hosted', 'pub.dev', 'tagion_dart_api-$version');
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
  );

  await copyFile(
      path.join(tempDir, 'armv7a-linux-android', 'armv7a-linux-android', 'lib',
          'libmobile.so'), // TODO: rename back to libtauonapi.so
      path.join(androidJniLibsDirPath, 'armeabi-v7a'),
      'libtauonapi.so');

  await copyFile(
      path.join(tempDir, 'x86_64-linux-android', 'x86_64-linux-android', 'lib',
          'libmobile.so'), // TODO: rename back to libtauonapi.so
      path.join(androidJniLibsDirPath, 'x86-64'),
      'libtauonapi.so');

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

Future<void> copyFile(String source, String destination, String fileName) async {
  // await Directory(destination).create(recursive: true); // TODO: remove later
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

Future<void> runExternalScript(String script, [List<String>? args]) async {
  await Process.run('chmod', ['+x', script]);
  await Process.run(script, args ?? []);
}
