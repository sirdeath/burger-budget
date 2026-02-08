import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_constants.dart';

class ManifestData {
  const ManifestData({
    required this.version,
    required this.updatedAt,
    required this.dbUrl,
    required this.sha256Hash,
    required this.sizeBytes,
  });

  final int version;
  final String updatedAt;
  final String dbUrl;
  final String sha256Hash;
  final int sizeBytes;

  factory ManifestData.fromJson(Map<String, dynamic> json) {
    return ManifestData(
      version: json['version'] as int,
      updatedAt: json['updatedAt'] as String,
      dbUrl: json['dbUrl'] as String,
      sha256Hash: json['sha256'] as String,
      sizeBytes: json['sizeBytes'] as int,
    );
  }
}

class RemoteManifestDatasource {
  const RemoteManifestDatasource({http.Client? client})
      : _client = client;

  final http.Client? _client;

  http.Client get _httpClient => _client ?? http.Client();

  Future<ManifestData> fetchManifest() async {
    final response = await _httpClient.get(
      Uri.parse(AppConstants.manifestUrl),
    );
    if (response.statusCode != 200) {
      throw HttpException(
        'Manifest fetch failed: ${response.statusCode}',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ManifestData.fromJson(json);
  }

  Future<String> downloadDatabase(String url) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw HttpException(
        'DB download failed: ${response.statusCode}',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final tempPath = '${dir.path}/${AppConstants.tempDbFileName}';
    await File(tempPath).writeAsBytes(response.bodyBytes, flush: true);
    return tempPath;
  }

  bool verifySha256(String filePath, String expectedHash) {
    final bytes = File(filePath).readAsBytesSync();
    final digest = sha256.convert(bytes);
    return digest.toString() == expectedHash;
  }
}
