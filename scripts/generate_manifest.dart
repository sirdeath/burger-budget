#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// GitHub Pages manifest.json 생성 스크립트
///
/// Usage:
///   dart run scripts/generate_manifest.dart [version]
///
/// Example:
///   dart run scripts/generate_manifest.dart 2
///
/// DB 파일을 gh-pages/data/menu_v{version}.db 에 복사하고
/// manifest.json을 자동 생성합니다.
void main(List<String> args) {
  final version = args.isNotEmpty ? int.parse(args[0]) : _detectNextVersion();
  final baseUrl = 'https://sirdeath.github.io/burger-budget';

  final sourceDb = File('assets/menu_seed.db');
  if (!sourceDb.existsSync()) {
    print('Error: assets/menu_seed.db not found');
    exit(1);
  }

  // Copy DB to gh-pages
  final targetDb = File('gh-pages/data/menu_v$version.db');
  Directory('gh-pages/data').createSync(recursive: true);
  sourceDb.copySync(targetDb.path);
  print('Copied: ${targetDb.path}');

  // Compute SHA-256
  final bytes = targetDb.readAsBytesSync();
  final hash = sha256.convert(bytes).toString();

  // Generate manifest
  final manifest = {
    'version': version,
    'updatedAt': DateTime.now().toUtc().toIso8601String(),
    'dbUrl': '$baseUrl/data/menu_v$version.db',
    'sha256': hash,
    'sizeBytes': bytes.length,
  };

  final manifestFile = File('gh-pages/manifest.json');
  manifestFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(manifest) + '\n',
  );
  print('Generated: ${manifestFile.path}');
  print('  version: $version');
  print('  sha256: $hash');
  print('  size: ${bytes.length} bytes');
}

int _detectNextVersion() {
  final manifestFile = File('gh-pages/manifest.json');
  if (manifestFile.existsSync()) {
    final json =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    return (json['version'] as int) + 1;
  }
  return 1;
}
