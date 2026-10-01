import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class DependencyEdge {
  const DependencyEdge({
    required this.from,
    required this.to,
    required this.kind,
    required this.uri,
  });

  final String from;
  final String to;
  final String kind;
  final String uri;

  Map<String, Object?> toJson() => <String, Object?>{
    'from': from,
    'to': to,
    'kind': kind,
    'uri': uri,
  };
}

class RootExport {
  const RootExport({
    required this.uri,
    required this.target,
    required this.shownNames,
    required this.explicitShow,
  });

  final String uri;
  final String target;
  final List<String> shownNames;
  final bool explicitShow;
}

/// Dart package graph built from analyzer-resolved library elements.
class ResolvedPackageGraph {
  ResolvedPackageGraph._({
    required this.root,
    required this.packageName,
    required this.libraries,
    required this.edges,
    required this.rootExports,
    required this.rootSymbols,
    required this.identifiersByLibrary,
    required this.unresolvedDirectives,
  });

  final String root;
  final String packageName;
  final Map<String, LibraryElement> libraries;
  final List<DependencyEdge> edges;
  final List<RootExport> rootExports;
  final Map<String, Element> rootSymbols;
  final Map<String, Map<String, int>> identifiersByLibrary;
  final List<String> unresolvedDirectives;

  static Future<ResolvedPackageGraph> load(String packageRoot) async {
    final String root = p.normalize(p.absolute(packageRoot));
    final String libRoot = p.join(root, 'lib');
    final File pubspec = File(p.join(root, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw FormatException('Missing pubspec.yaml under $root');
    }
    final Object? pubspecYaml = loadYaml(pubspec.readAsStringSync());
    if (pubspecYaml is! YamlMap || pubspecYaml['name'] is! String) {
      throw const FormatException('pubspec.yaml must declare package name');
    }
    final String packageName = pubspecYaml['name'] as String;
    final List<String> sourcePaths =
        Directory(libRoot)
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((File file) => file.path.endsWith('.dart'))
            .map((File file) => p.normalize(p.absolute(file.path)))
            .toList()
          ..sort();
    final AnalysisContextCollection contexts = AnalysisContextCollection(
      includedPaths: <String>[libRoot],
      sdkPath: _lockedDartSdkPath(root),
    );
    try {
      final Map<String, LibraryElement> libraries = <String, LibraryElement>{};
      final Map<String, ResolvedUnitResult> units =
          <String, ResolvedUnitResult>{};
      final Map<String, Map<String, int>> identifiersByLibrary =
          <String, Map<String, int>>{};
      for (final String path in sourcePaths) {
        final AnalysisContext context = contexts.contextFor(path);
        final SomeResolvedUnitResult result = await context.currentSession
            .getResolvedUnit(path);
        if (result is! ResolvedUnitResult) {
          throw FormatException('Analyzer did not resolve $path');
        }
        units[path] = result;
        final _IdentifierCountVisitor identifierVisitor =
            _IdentifierCountVisitor();
        result.unit.accept(identifierVisitor);
        identifiersByLibrary[_relativeLibPath(path, root)] =
            Map<String, int>.unmodifiable(identifierVisitor.counts);
        final LibraryElement library = result.libraryElement;
        final String? libraryPath = _pathForLibraryUri(
          library.uri,
          root,
          packageName,
        );
        if (libraryPath != null) libraries[libraryPath] = library;
      }

      final List<DependencyEdge> edges = <DependencyEdge>[];
      final List<String> unresolved = <String>[];
      for (final MapEntry<String, LibraryElement> entry in libraries.entries) {
        final String from = _relativeLibPath(entry.key, root);
        for (final LibraryFragment fragment in entry.value.fragments) {
          for (final LibraryImport directive in fragment.libraryImports) {
            final LibraryElement? target = directive.importedLibrary;
            if (target == null) {
              unresolved.add('$from imports ${directive.uri}');
              continue;
            }
            final String? targetPath = _pathForLibraryUri(
              target.uri,
              root,
              packageName,
            );
            if (targetPath == null) continue;
            edges.add(
              DependencyEdge(
                from: from,
                to: _relativeLibPath(targetPath, root),
                kind: 'import',
                uri: directive.uri is DirectiveUriWithRelativeUriString
                    ? (directive.uri as DirectiveUriWithRelativeUriString)
                          .relativeUriString
                    : directive.uri.toString(),
              ),
            );
          }
          for (final LibraryExport directive in fragment.libraryExports) {
            final LibraryElement? target = directive.exportedLibrary;
            if (target == null) {
              unresolved.add('$from exports ${directive.uri}');
              continue;
            }
            final String? targetPath = _pathForLibraryUri(
              target.uri,
              root,
              packageName,
            );
            if (targetPath == null) continue;
            edges.add(
              DependencyEdge(
                from: from,
                to: _relativeLibPath(targetPath, root),
                kind: 'export',
                uri: directive.uri is DirectiveUriWithRelativeUriString
                    ? (directive.uri as DirectiveUriWithRelativeUriString)
                          .relativeUriString
                    : directive.uri.toString(),
              ),
            );
          }
        }
      }
      edges.sort((DependencyEdge a, DependencyEdge b) {
        final int from = a.from.compareTo(b.from);
        if (from != 0) return from;
        final int kind = a.kind.compareTo(b.kind);
        if (kind != 0) return kind;
        final int to = a.to.compareTo(b.to);
        return to != 0 ? to : a.uri.compareTo(b.uri);
      });

      final String rootEntrypoint = p.join(libRoot, 'animal_island_ui.dart');
      final ResolvedUnitResult? rootUnit = units[rootEntrypoint];
      if (rootUnit == null) {
        throw const FormatException('Missing lib/animal_island_ui.dart');
      }
      final Map<String, LibraryExport> resolvedRootExports =
          <String, LibraryExport>{};
      for (final LibraryFragment fragment
          in rootUnit.libraryElement.fragments) {
        for (final LibraryExport export in fragment.libraryExports) {
          final DirectiveUri uri = export.uri;
          if (uri is DirectiveUriWithRelativeUriString) {
            resolvedRootExports[uri.relativeUriString] = export;
          }
        }
      }
      final List<RootExport> rootExports = <RootExport>[];
      for (final Directive directive in rootUnit.unit.directives) {
        if (directive is! ExportDirective) continue;
        final String? uri = directive.uri.stringValue;
        if (uri == null) {
          unresolved.add('Root has a non-literal export directive');
          continue;
        }
        final LibraryExport? resolved = resolvedRootExports[uri];
        final LibraryElement? target = resolved?.exportedLibrary;
        final String? targetPath = target == null
            ? null
            : _pathForLibraryUri(target.uri, root, packageName);
        if (targetPath == null) {
          unresolved.add('Root export $uri did not resolve into this package');
          continue;
        }
        final List<ShowCombinator> shows = directive.combinators
            .whereType<ShowCombinator>()
            .toList();
        final bool explicitShow =
            shows.length == 1 && directive.combinators.length == 1;
        rootExports.add(
          RootExport(
            uri: uri,
            target: _relativeLibPath(targetPath, root),
            shownNames: shows.isEmpty
                ? const <String>[]
                : (shows.single.shownNames
                      .map((SimpleIdentifier name) => name.name)
                      .toList()
                    ..sort()),
            explicitShow: explicitShow,
          ),
        );
      }
      rootExports.sort((RootExport a, RootExport b) => a.uri.compareTo(b.uri));
      final Map<String, Element> rootSymbols =
          Map<String, Element>.unmodifiable(
            rootUnit.libraryElement.exportNamespace.definedNames2,
          );
      return ResolvedPackageGraph._(
        root: root,
        packageName: packageName,
        libraries: Map<String, LibraryElement>.unmodifiable(libraries),
        edges: List<DependencyEdge>.unmodifiable(edges),
        rootExports: List<RootExport>.unmodifiable(rootExports),
        rootSymbols: rootSymbols,
        identifiersByLibrary: Map<String, Map<String, int>>.unmodifiable(
          identifiersByLibrary,
        ),
        unresolvedDirectives: List<String>.unmodifiable(unresolved..sort()),
      );
    } finally {
      await contexts.dispose();
    }
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'package': packageName,
    'root_exports': rootExports
        .map(
          (RootExport export) => <String, Object?>{
            'uri': export.uri,
            'target': export.target,
            'show': export.shownNames,
            'explicit_show': export.explicitShow,
          },
        )
        .toList(),
    'root_symbols': rootSymbols.keys.toList()..sort(),
    'edges': edges.map((DependencyEdge edge) => edge.toJson()).toList(),
    'unresolved_directives': unresolvedDirectives,
  };
}

String _lockedDartSdkPath(String packageRoot) {
  final List<String> configuredRoots = <String?>[
    Platform.environment['N04_FLUTTER_HOME'],
    Platform.environment['FLUTTER_ROOT'],
  ].whereType<String>().where((String value) => value.isNotEmpty).toList();
  final List<String> normalizedRoots = configuredRoots
      .map((String value) => p.normalize(p.absolute(value)))
      .toSet()
      .toList();
  if (normalizedRoots.length > 1) {
    throw const FormatException(
      'Conflicting N04_FLUTTER_HOME and FLUTTER_ROOT SDK roots',
    );
  }

  String? flutterRoot = normalizedRoots.isEmpty ? null : normalizedRoots.single;
  if (flutterRoot == null) {
    final File packageConfig = File(
      p.join(packageRoot, '.dart_tool', 'package_config.json'),
    );
    if (packageConfig.existsSync()) {
      final Object? decoded = jsonDecode(packageConfig.readAsStringSync());
      if (decoded is Map && decoded['flutterRoot'] is String) {
        final Uri rootUri = Uri.parse(decoded['flutterRoot'] as String);
        if (rootUri.scheme != 'file') {
          throw const FormatException(
            'package_config.json flutterRoot must be a file URI',
          );
        }
        flutterRoot = rootUri.toFilePath(windows: Platform.isWindows);
      }
    }
  }
  if (flutterRoot == null || flutterRoot.isEmpty) {
    throw const FormatException(
      'Cannot identify the locked Flutter root for analyzer SDK resolution',
    );
  }

  final String sdkPath = p.normalize(
    p.absolute(p.join(flutterRoot, 'bin', 'cache', 'dart-sdk')),
  );
  final String dartExecutable = p.join(
    sdkPath,
    'bin',
    Platform.isWindows ? 'dart.exe' : 'dart',
  );
  if (!Directory(flutterRoot).existsSync() ||
      !File(p.join(sdkPath, 'version')).existsSync() ||
      !File(dartExecutable).existsSync()) {
    throw FormatException(
      'Locked Dart SDK is missing or incomplete under $sdkPath',
    );
  }
  return sdkPath;
}

class _IdentifierCountVisitor extends RecursiveAstVisitor<void> {
  final Map<String, int> counts = <String, int>{};

  @override
  void visitNamedType(NamedType node) {
    counts.update(
      node.name.lexeme,
      (int count) => count + 1,
      ifAbsent: () => 1,
    );
    super.visitNamedType(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    counts.update(node.name, (int count) => count + 1, ifAbsent: () => 1);
    super.visitSimpleIdentifier(node);
  }
}

String? _pathForLibraryUri(Uri uri, String root, String packageName) {
  if (uri.scheme == 'file') return p.normalize(p.absolute(uri.toFilePath()));
  if (uri.scheme != 'package' || uri.pathSegments.isEmpty) return null;
  if (uri.pathSegments.first != packageName) return null;
  return p.normalize(p.join(root, 'lib', p.joinAll(uri.pathSegments.skip(1))));
}

String? resolvedLibraryPath(ResolvedPackageGraph graph, Uri? uri) {
  if (uri == null) return null;
  final String? mapped = _pathForLibraryUri(uri, graph.root, graph.packageName);
  if (mapped == null) return null;
  for (final String path in graph.libraries.keys) {
    if (p.equals(path, mapped)) return path;
  }
  return null;
}

String _relativeLibPath(String absolutePath, String root) =>
    p.relative(absolutePath, from: p.join(root, 'lib')).replaceAll('\\', '/');

String absoluteLibPath(String root, String relativePath) => p.normalize(
  p.join(root, 'lib', p.joinAll(relativePath.replaceAll('\\', '/').split('/'))),
);

List<String> rootSurfaceViolations(ResolvedPackageGraph graph) {
  final List<String> violations = <String>[];
  final Set<String> shown = <String>{};
  for (final RootExport export in graph.rootExports) {
    if (!export.explicitShow) {
      violations.add(
        'Root export ${export.uri} must use exactly one show list',
      );
    }
    final LibraryElement? target =
        graph.libraries[absoluteLibPath(graph.root, export.target)];
    final Set<String> targetNames =
        target?.exportNamespace.definedNames2.keys.toSet() ?? <String>{};
    final String? componentOwner = _componentOwner(export.target);
    final String targetPath = _normalizeLibraryPath(export.target);
    final String? primaryName = componentOwner == null
        ? null
        : _primaryComponentType(export.target, componentOwner);
    final Element? targetPrimary = primaryName == null
        ? null
        : target?.exportNamespace.definedNames2[primaryName];
    final bool targetDeclaresPrimary =
        targetPrimary?.kind == ElementKind.CLASS &&
        resolvedElementSourcePath(graph, targetPrimary) == targetPath;
    if (componentOwner != null &&
        targetDeclaresPrimary &&
        !export.shownNames.contains(primaryName)) {
      violations.add(
        'Component target $targetPath must show its directly declared primary type $primaryName',
      );
    }
    for (final String name in export.shownNames) {
      if (!targetNames.contains(name)) {
        violations.add('Root show name $name is absent from ${export.target}');
      }
      shown.add(name);
      final Element? element = graph.rootSymbols[name];
      final String? libraryPath = resolvedLibraryPath(
        graph,
        element?.library?.uri,
      );
      final String? sourcePath = resolvedElementSourcePath(graph, element);
      final bool directDeclaration = sourcePath == targetPath;

      if (componentOwner == null) {
        if (sourcePath != targetPath || !directDeclaration) {
          violations.add(
            'Root show name $name must be declared in non-component target $targetPath',
          );
        }
      } else {
        final String ownerPrefix = 'src/components/$componentOwner/';
        final String? declarationOwner = sourcePath == null
            ? null
            : _componentOwner(sourcePath);
        if (sourcePath == null ||
            declarationOwner != componentOwner ||
            libraryPath == null ||
            !_relativeLibPath(
              libraryPath,
              graph.root,
            ).startsWith(ownerPrefix)) {
          violations.add(
            'Root show name $name must resolve within component owner $componentOwner',
          );
        }
        if (name == primaryName &&
            (element?.kind != ElementKind.CLASS || !directDeclaration)) {
          violations.add(
            'Primary component type $name must be a class declared in $targetPath',
          );
        }
        if (primaryName != null &&
            !export.shownNames.contains(primaryName) &&
            !directDeclaration) {
          violations.add(
            'Root show name $name must be declared in component target $targetPath when its primary type is not shown',
          );
        }
      }
      if (element is TypeAliasElement && element.aliasedType is InterfaceType) {
        violations.add(
          'Resolved root symbol $name must not be a class type alias',
        );
      }
    }
  }
  final Set<String> actual = graph.rootSymbols.keys.toSet();
  for (final String name in shown.difference(actual).toList()..sort()) {
    violations.add(
      'Shown symbol $name is absent from the resolved root namespace',
    );
  }
  for (final String name in actual.difference(shown).toList()..sort()) {
    violations.add(
      'Resolved root symbol $name is not in any explicit show list',
    );
  }
  return violations..sort();
}

/// Returns every resolved export directive reachable from a root target.
/// Duplicate directives remain duplicated so policy comparison can reject them.
List<DependencyEdge> rootReachableExportEdges(ResolvedPackageGraph graph) {
  final Map<String, List<DependencyEdge>> exportsBySource =
      <String, List<DependencyEdge>>{};
  for (final DependencyEdge edge in graph.edges) {
    if (edge.kind == 'export') {
      exportsBySource
          .putIfAbsent(edge.from, () => <DependencyEdge>[])
          .add(edge);
    }
  }
  final List<String> pending = graph.rootExports
      .map((RootExport export) => _normalizeLibraryPath(export.target))
      .toList();
  final Set<String> visited = <String>{};
  final List<DependencyEdge> reachable = <DependencyEdge>[];
  while (pending.isNotEmpty) {
    final String source = pending.removeLast();
    if (!visited.add(source)) continue;
    for (final DependencyEdge edge
        in exportsBySource[source] ?? const <DependencyEdge>[]) {
      reachable.add(edge);
      pending.add(edge.to);
    }
  }
  reachable.sort((DependencyEdge a, DependencyEdge b) {
    final int from = a.from.compareTo(b.from);
    if (from != 0) return from;
    final int to = a.to.compareTo(b.to);
    if (to != 0) return to;
    final int kind = a.kind.compareTo(b.kind);
    return kind != 0 ? kind : a.uri.compareTo(b.uri);
  });
  return reachable;
}

String? resolvedElementSourcePath(
  ResolvedPackageGraph graph,
  Element? element,
) {
  if (element == null) return null;
  final Uri? sourceUri = element.firstFragment.libraryFragment?.source.uri;
  if (sourceUri == null) return null;
  final String? absolute = _pathForLibraryUri(
    sourceUri,
    graph.root,
    graph.packageName,
  );
  final String libRoot = p.join(graph.root, 'lib');
  if (absolute == null || !p.isWithin(libRoot, absolute)) return null;
  return _relativeLibPath(absolute, graph.root);
}

String _normalizeLibraryPath(String path) =>
    path.replaceAll('\\', '/').replaceFirst(RegExp(r'^lib/'), '');

String? _componentOwner(String path) {
  final Match? match = RegExp(r'^src/components/([^/]+)/').firstMatch(path);
  return match?.group(1);
}

String? _primaryComponentType(String target, String owner) {
  final String normalized = _normalizeLibraryPath(target);
  final String prefix = 'src/components/$owner/';
  if (!normalized.startsWith(prefix)) return null;
  final String stem = p.basenameWithoutExtension(normalized);
  final String pascal = stem
      .split(RegExp(r'[_-]+'))
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join();
  return 'Animal$pascal';
}

List<Map<String, Object?>> publicApiTypeLeaks(ResolvedPackageGraph graph) {
  final List<Map<String, Object?>> leaks = <Map<String, Object?>>[];
  final Set<String> seen = <String>{};
  void checkType(String apiSymbol, String member, DartType type) {
    final InstantiatedTypeAliasElement? alias = type.alias;
    if (alias != null) {
      _checkPackageTypeName(
        graph,
        alias.element,
        apiSymbol,
        member,
        leaks,
        seen,
      );
      for (final DartType argument in alias.typeArguments) {
        checkType(apiSymbol, member, argument);
      }
    }
    if (type is InterfaceType) {
      _checkPackageTypeName(
        graph,
        type.element,
        apiSymbol,
        member,
        leaks,
        seen,
      );
      for (final DartType argument in type.typeArguments) {
        checkType(apiSymbol, member, argument);
      }
    } else if (type is FunctionType) {
      checkType(apiSymbol, '$member return', type.returnType);
      for (final FormalParameterElement parameter in type.formalParameters) {
        checkType(
          apiSymbol,
          '$member callback ${parameter.name}',
          parameter.type,
        );
      }
    } else if (type is RecordType) {
      for (final RecordTypeField field in <RecordTypeField>[
        ...type.positionalFields,
        ...type.namedFields,
      ]) {
        checkType(apiSymbol, member, field.type);
      }
    } else if (type is TypeParameterType) {
      checkType(apiSymbol, member, type.bound);
    }
  }

  void checkCallable(
    String apiSymbol,
    String member,
    ExecutableElement callable,
  ) {
    checkType(apiSymbol, '$member return', callable.returnType);
    for (final FormalParameterElement parameter in callable.formalParameters) {
      checkType(
        apiSymbol,
        '$member parameter ${parameter.name}',
        parameter.type,
      );
    }
  }

  for (final MapEntry<String, Element> entry in graph.rootSymbols.entries) {
    final String apiSymbol = entry.key;
    final Element element = entry.value;
    if (element is InterfaceElement) {
      final List<InterfaceType> hierarchy = <InterfaceType>[
        if (element.supertype != null) element.supertype!,
        ...element.mixins,
        ...element.interfaces,
      ];
      for (final InterfaceType type in hierarchy) {
        checkType(apiSymbol, 'supertype', type);
      }
      for (final ConstructorElement constructor in element.constructors) {
        if (!(constructor.name ?? '').startsWith('_')) {
          checkCallable(apiSymbol, constructor.displayName, constructor);
        }
      }
      for (final FieldElement field in element.fields) {
        final String? name = field.name;
        if (name != null && !name.startsWith('_')) {
          checkType(apiSymbol, name, field.type);
        }
      }
      for (final ExecutableElement member in <ExecutableElement>[
        ...element.methods,
        ...element.getters,
        ...element.setters,
      ]) {
        final String? name = member.name;
        if (name != null && !name.startsWith('_')) {
          checkCallable(apiSymbol, name, member);
        }
      }
    } else if (element is TopLevelFunctionElement) {
      checkCallable(apiSymbol, apiSymbol, element);
    } else if (element is TopLevelVariableElement) {
      checkType(apiSymbol, apiSymbol, element.type);
    } else if (element is TypeAliasElement) {
      checkType(apiSymbol, apiSymbol, element.aliasedType);
    } else if (element is ExtensionElement) {
      checkType(apiSymbol, 'extended type', element.extendedType);
      for (final ExecutableElement member in <ExecutableElement>[
        ...element.methods,
        ...element.getters,
        ...element.setters,
      ]) {
        final String? name = member.name;
        if (name != null && !name.startsWith('_')) {
          checkCallable(apiSymbol, name, member);
        }
      }
    }
  }
  return leaks;
}

void _checkPackageTypeName(
  ResolvedPackageGraph graph,
  Element typeElement,
  String apiSymbol,
  String member,
  List<Map<String, Object?>> leaks,
  Set<String> seen,
) {
  final LibraryElement? library = typeElement.library;
  if (library == null) return;
  final String? sourcePath = resolvedLibraryPath(graph, library.uri);
  if (sourcePath == null) return;
  final String source = 'lib/${_relativeLibPath(sourcePath, graph.root)}';
  final String? name = typeElement.name;
  if (name == null) return;
  final Element? exported = graph.rootSymbols[name];
  final String? exportedPath = resolvedLibraryPath(
    graph,
    exported?.library?.uri,
  );
  if (exportedPath == sourcePath) return;
  final String key = '$apiSymbol::$member::$name::$sourcePath';
  if (!seen.add(key)) return;
  leaks.add(<String, Object?>{
    'api_symbol': apiSymbol,
    'member': member,
    'type': name,
    'source': source,
  });
}

List<List<String>> stronglyConnectedLibraries(ResolvedPackageGraph graph) {
  final Map<String, List<String>> adjacency = <String, List<String>>{
    for (final String path in graph.libraries.keys)
      _relativeLibPath(path, graph.root): <String>[],
  };
  for (final DependencyEdge edge in graph.edges) {
    adjacency.putIfAbsent(edge.from, () => <String>[]).add(edge.to);
    adjacency.putIfAbsent(edge.to, () => <String>[]);
  }
  for (final List<String> targets in adjacency.values) {
    targets.sort();
  }
  final Map<String, int> indices = <String, int>{};
  final Map<String, int> lowLinks = <String, int>{};
  final List<String> stack = <String>[];
  final Set<String> onStack = <String>{};
  final List<List<String>> components = <List<String>>[];
  var nextIndex = 0;
  void visit(String node) {
    indices[node] = nextIndex;
    lowLinks[node] = nextIndex;
    nextIndex++;
    stack.add(node);
    onStack.add(node);
    for (final String target in adjacency[node]!) {
      if (!indices.containsKey(target)) {
        visit(target);
        lowLinks[node] = lowLinks[node]!.compareTo(lowLinks[target]!) < 0
            ? lowLinks[node]!
            : lowLinks[target]!;
      } else if (onStack.contains(target)) {
        lowLinks[node] = lowLinks[node]!.compareTo(indices[target]!) < 0
            ? lowLinks[node]!
            : indices[target]!;
      }
    }
    if (lowLinks[node] != indices[node]) return;
    final List<String> component = <String>[];
    while (stack.isNotEmpty) {
      final String item = stack.removeLast();
      onStack.remove(item);
      component.add(item);
      if (item == node) break;
    }
    final bool selfCycle =
        component.length == 1 && adjacency[component.single]!.contains(node);
    if (component.length > 1 || selfCycle) {
      components.add(component..sort());
    }
  }

  final List<String> nodes = adjacency.keys.toList()..sort();
  for (final String node in nodes) {
    if (!indices.containsKey(node)) visit(node);
  }
  components.sort(
    (List<String> a, List<String> b) => a.first.compareTo(b.first),
  );
  return components;
}

String renderPublicApiAllowlist(ResolvedPackageGraph graph) {
  final List<String> symbols = graph.rootSymbols.keys.toList()..sort();
  return <String>[
    'format: animal_island_ui.public_api_allowlist.v1',
    'entrypoint: lib/animal_island_ui.dart',
    'symbols:',
    ...symbols.map((String symbol) => '  - $symbol'),
    '',
  ].join('\n');
}

Future<String> generatePublicApiProjections({
  bool checkOnly = false,
  String? packageRoot,
}) async {
  final String root = p.normalize(
    p.absolute(packageRoot ?? Directory.current.path),
  );
  final ResolvedPackageGraph graph = await ResolvedPackageGraph.load(root);
  final String allowlist = renderPublicApiAllowlist(graph);
  final Map<String, Object?> api = <String, Object?>{
    'version': _packageVersion(root),
    'entrypoint': 'lib/animal_island_ui.dart',
    'exports': _publicApiExports(graph),
  };
  final JsonEncoder encoder = const JsonEncoder.withIndent('  ');
  final String contentWithoutHash = encoder.convert(api);
  final String hash = sha256
      .convert(utf8.encode(contentWithoutHash))
      .toString();
  api['sha256'] = hash;
  final String catalog = '${encoder.convert(api)}\n';

  final File allowlistFile = File(
    p.join(root, 'catalog', 'public_api.allowlist.yaml'),
  );
  if (checkOnly) {
    if (!allowlistFile.existsSync() ||
        allowlistFile.readAsStringSync().replaceAll('\r\n', '\n') !=
            allowlist) {
      throw StateError('catalog/public_api.allowlist.yaml is out of sync');
    }
  } else {
    allowlistFile.writeAsStringSync(allowlist);
  }
  final File catalogFile = File(p.join(root, 'catalog', 'public_api.json'));
  if (checkOnly) {
    if (!catalogFile.existsSync() ||
        catalogFile.readAsStringSync().replaceAll('\r\n', '\n').trim() !=
            catalog.trim()) {
      throw StateError('catalog/public_api.json is out of sync');
    }
  } else {
    catalogFile.writeAsStringSync(catalog);
  }
  return hash;
}

String _packageVersion(String root) {
  final Object? decoded = loadYaml(
    File(p.join(root, 'pubspec.yaml')).readAsStringSync(),
  );
  if (decoded is YamlMap && decoded['version'] is String) {
    return decoded['version'] as String;
  }
  return '1.0.0';
}

Map<String, Object?> _publicApiExports(ResolvedPackageGraph graph) {
  final Map<String, Object?> exports = <String, Object?>{};
  for (final RootExport rootExport in graph.rootExports) {
    final String absolute = absoluteLibPath(graph.root, rootExport.target);
    final LibraryElement? library = graph.libraries[absolute];
    if (library == null) continue;
    final Map<String, Object?> symbols = <String, Object?>{
      'classes': <String, Object?>{},
      'enums': <String, Object?>{},
      'topLevelVariables': <String, Object?>{},
      'functions': <String, Object?>{},
    };
    for (final String name in rootExport.shownNames) {
      final Element? element = library.exportNamespace.definedNames2[name];
      if (element is ClassElement) {
        final List<String> constructors =
            element.constructors
                .where(
                  (ConstructorElement constructor) =>
                      !(constructor.name ?? '').startsWith('_'),
                )
                .map((ConstructorElement constructor) {
                  final String display = constructor.displayName;
                  return display.endsWith('.new')
                      ? display.substring(0, display.length - 4)
                      : display;
                })
                .toSet()
                .toList()
              ..sort();
        final List<String> fields =
            element.fields
                .where(
                  (FieldElement field) =>
                      field.name != null && !field.name!.startsWith('_'),
                )
                .map((FieldElement field) => field.name!)
                .toSet()
                .toList()
              ..sort();
        (symbols['classes']! as Map<String, Object?>)[name] = <String, Object?>{
          'constructors': constructors,
          'fields': fields,
        };
      } else if (element is EnumElement) {
        final List<String> constants =
            element.constants
                .map((FieldElement constant) => constant.name)
                .whereType<String>()
                .toList()
              ..sort();
        (symbols['enums']! as Map<String, Object?>)[name] = constants;
      } else if (element is TopLevelVariableElement) {
        (symbols['topLevelVariables']! as Map<String, Object?>)[name] = element
            .type
            .getDisplayString();
      } else if (element is TopLevelFunctionElement) {
        final List<String> parameters = element.formalParameters.map((
          FormalParameterElement parameter,
        ) {
          final StringBuffer buffer = StringBuffer();
          parameter.appendToWithoutDelimiters(buffer);
          return buffer.toString();
        }).toList();
        (symbols['functions']!
            as Map<String, Object?>)[name] = <String, Object?>{
          'returnType': element.returnType.getDisplayString(),
          'parameters': parameters,
        };
      }
    }
    final String key = 'lib/${rootExport.target}';
    final Map<String, Object?>? previous =
        exports[key] as Map<String, Object?>?;
    if (previous == null) {
      exports[key] = symbols;
    } else {
      for (final String category in symbols.keys) {
        (previous[category]! as Map<String, Object?>).addAll(
          symbols[category]! as Map<String, Object?>,
        );
      }
    }
  }
  final List<String> paths = exports.keys.toList()..sort();
  return <String, Object?>{
    for (final String path in paths)
      path: _sortApiCategories(exports[path]! as Map<String, Object?>),
  };
}

Map<String, Object?> _sortApiCategories(Map<String, Object?> categories) {
  const List<String> order = <String>[
    'classes',
    'enums',
    'topLevelVariables',
    'functions',
  ];
  return <String, Object?>{
    for (final String category in order)
      category: _sortMap(categories[category]! as Map<String, Object?>),
  };
}

Map<String, Object?> _sortMap(Map<String, Object?> value) {
  final List<String> keys = value.keys.toList()..sort();
  return <String, Object?>{for (final String key in keys) key: value[key]};
}
