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
  'storage',
  'navigator',
  'bloc',
  'event',
  'state',
  'router',
};

const blocRoles = <String>{'bloc', 'event', 'state'};

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
      // Third-party plugin sources are symlinked under the desktop ephemeral
      // dirs once any plugin with a desktop implementation is added. They are
      // not first-party code and the taxonomy does not govern them.
      if (path.contains('/.plugin_symlinks/')) continue;
      if (path.contains('/ephemeral/')) continue;
      if (path.contains('/build/') || path.contains('/.dart_tool/')) continue;
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
      final isFeaturePackage = path.startsWith('${root.path}/packages/feature_');

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
      if (role == 'storage' && !isCore) {
        violations.add('$path: .storage.dart allowed only in packages/core');
      }
      if (role == 'navigator') {
        final isStub =
            path.startsWith('${root.path}/apps/business_app/') ||
                path.startsWith('${root.path}/apps/stylist_app/');
        if (!isApp || !isStub) {
          violations.add(
            '$path: .navigator.dart is DEPRECATED (legacy route-flow '
            'coordinators) — allowed only in the untouched business_app / '
            'stylist_app stubs; use go_router (.router.dart) instead',
          );
        }
      }
      if (blocRoles.contains(role) && !isApp && !isFeaturePackage) {
        violations.add(
          '$path: role $role allowed only in apps/*/lib or packages/feature_*/lib',
        );
      }
      if (role == 'router' && !isApp) {
        violations.add('$path: .router.dart allowed only in apps/*/lib');
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
