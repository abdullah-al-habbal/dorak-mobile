import 'dart:io';

const roles = <String>{
  'screen',
  'widget',
  'sheet',
  'token',
  'theme',
  'entity',
  'dto',
  'endpoints',
  'repository',
  'provider',
  'notifier',
  'barrel',
  'client',
  'interceptor',
  'exception',
};

final roleRegex = RegExp(r'^[a-z0-9_]+\.([a-z0-9]+)\.dart$');

void main(List<String> args) {
  final root = Directory.current;
  final dirs = <Directory>[
    for (final scope in ['apps', 'packages'])
      if (Directory('${root.path}/$scope').existsSync())
        Directory('${root.path}/$scope'),
  ];

  final violations = <String>[];
  for (final scope in dirs) {
    for (final entity in scope.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path; 
      if (path.contains('/generated/')) continue;
      if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) continue;
      if (!path.contains('/lib/')) continue;

      final parts = path.split('/lib/');
      final libRel = parts[1];
      final segments = libRel.split('/');
      if (segments.length == 1) continue; 

      final name = segments.last;
      final isApp = path.startsWith('${root.path}/apps/');
      final isDesignSystem = path.startsWith(
        '${root.path}/packages/design_system/',
      );
      final isCore = path.startsWith('${root.path}/packages/core/');

      final match = roleRegex.firstMatch(name);
      final role = match?.group(1);

      if (role == null || !roles.contains(role)) {
        violations.add(
          '$path: file lacks a valid role suffix (${roles.join('|')})',
        );
        continue;
      }

      if (role == 'screen' && !isApp) {
        violations.add('$path: .screen.dart allowed only in apps/*/lib');
      }
      if ((role == 'token' || role == 'theme') && !isDesignSystem) {
        violations.add('$path: .token.dart/.theme.dart allowed only in design_system');
      }
      if ((role == 'repository' ||
              role == 'dto' ||
              role == 'entity' ||
              role == 'notifier' ||
              role == 'endpoints') &&
          !isCore &&
          !isApp) {
        violations.add('$path: role $role allowed only in packages/core or apps/*/lib');
      }
    }
  }

  if (violations.isEmpty) {
    print('Taxonomy check passed.');
    return;
  }

  for (final v in violations) {
    stderr.writeln('TAXONOMY: $v');
  }
  stderr.writeln('Taxonomy check failed: ${violations.length} violation(s).');
  exitCode = 1;
}
