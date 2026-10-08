import 'package:path/path.dart' as p;

/// Global arguments placed before the subcommand of every scripted `flutter`
/// run. `--no-version-check` disables the SDK update check regardless of
/// cached tool state or the parent environment, so its banner never enters
/// machine-readable stdout such as JSON reporter or `--machine` output.
const List<String> flutterGlobalArguments = <String>['--no-version-check'];

/// The arguments a scripted run of [command] receives:
/// [flutterGlobalArguments] first for a Flutter executable, then [args].
List<String> scriptedArguments(String command, List<String> args) {
  final String name = p.basename(command).toLowerCase();
  final bool flutter = name == 'flutter' || name == 'flutter.bat';
  return <String>[if (flutter) ...flutterGlobalArguments, ...args];
}
