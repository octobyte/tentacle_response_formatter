library http_exception.tool.grind;

import 'dart:io' as io;
import 'package:grinder/grinder.dart';
import 'package:linter/src/linter.dart';
import 'package:linter/src/formatter.dart';
import 'package:linter/src/io.dart';
import 'package:linter/src/config.dart';
import 'package:analyzer/src/generated/engine.dart';

main(List<String> args) => grind(args);

@Task('Run analyzer to check for hints/errors/warnings')
void analyze(GrinderContext c) {
  PubApplication tuneup = new PubApplication('tuneup');
  tuneup.run(['check']);
}

@Task('Run linter to check the source')
void lint() {
  linterTask('tool/lintcfg.yaml');
}

@Task('Run all checks (analyze, lint)')
@Depends(analyze, lint, test)
void check() {}

@Task('Run all tests')
void test(GrinderContext context) {
  Tests.runCliTests();
}

// TODO(zoechi) use this from bwu_utils when it's released
/// Run linter using on the package.
/// Use the configuration file referenced by [configFilePath]
///   for example 'tool/lintcfg.yaml'.
void linterTask(String configFilePath) {
  final config =
      new LintConfig.parse(new io.File('tool/lintcfg.yaml').readAsStringSync());
  final lintOptions = new LinterOptions()..configure(config);
  final linter = new DartLinter(lintOptions);
  List<io.File> filesToLint = [];
  filesToLint.addAll(collectFiles(io.Directory.current.absolute.path));

  List<AnalysisErrorInfo> errors = linter.lintFiles(filesToLint);

  final commonRoot = io.Directory.current.absolute.path;
  ReportFormatter reporter = new ReportFormatter(
      errors, lintOptions.filter, outSink,
      fileCount: filesToLint.length,
      fileRoot: commonRoot,
      showStatistics: true);
  reporter.write();
  final linterErrorCount = (reporter as DetailedReporter).errorCount;
  if (linterErrorCount != 0) {
    context.fail('Linter reports $linterErrorCount errors');
  }
}
