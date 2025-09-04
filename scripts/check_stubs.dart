#!/usr/bin/env dart

/// Script to check for stubbed files in the Krushak project
/// This script will detect files that contain TODO markers,
/// unimplemented methods, or obvious placeholders
///
/// Usage: dart scripts/check_stubs.dart

import 'dart:io';

final List<String> stubPatterns = [
  r'TODO:',
  r'FIXME:',
  r'throw.*Error.*[Nn]ot implemented',
  r'throw.*UnimplementedError',
  r'// TODO',
  r'// FIXME',
  r'NotImplemented',
  r'placeholder.*implementation',
  r'stub.*implementation',
];

final List<String> excludeDirectories = [
  'build',
  '.dart_tool',
  'android',
  'ios',
  'linux',
  'macos',
  'web',
  'windows',
  '.git',
  'scripts', // Exclude this script itself
];

final List<String> excludeFiles = ['pubspec.lock', '.packages'];

void main() async {
  print('🔍 Checking for stubbed files in Krushak project...\n');

  final issues = <String>[];
  final directory = Directory('.');

  await _scanDirectory(directory, issues);

  if (issues.isEmpty) {
    print('✅ No stubbed files found! All implementations appear complete.');
    exit(0);
  } else {
    print('❌ Found ${issues.length} stubbed file(s):\n');
    for (final issue in issues) {
      print('  $issue');
    }
    print('\n💡 These files need to be either implemented or removed.');
    exit(1);
  }
}

Future<void> _scanDirectory(Directory directory, List<String> issues) async {
  await for (final entity in directory.list()) {
    if (entity is Directory) {
      final dirName = entity.path.split(Platform.pathSeparator).last;
      if (!excludeDirectories.contains(dirName)) {
        await _scanDirectory(entity, issues);
      }
    } else if (entity is File) {
      final fileName = entity.path.split(Platform.pathSeparator).last;

      // Only check Dart files and exclude certain files
      if (fileName.endsWith('.dart') && !excludeFiles.contains(fileName)) {
        await _scanFile(entity, issues);
      }
    }
  }
}

Future<void> _scanFile(File file, List<String> issues) async {
  try {
    final content = await file.readAsString();
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      for (final pattern in stubPatterns) {
        final regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(line)) {
          final relativePath = file.path.replaceFirst(
            Directory.current.path,
            '',
          );
          issues.add('$relativePath:${i + 1} - $line');
        }
      }
    }
  } catch (e) {
    // Skip files that can't be read
  }
}
