library generator;

import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';

import 'src/router_generator.dart';
import 'package:glob/glob.dart';

Builder routerBuilder(BuilderOptions options) => generatorFactoryBuilder(options);

Builder routerCombiningBuilder(BuilderOptions options) => RouterCombiningBuilder();

class RouterCombiningBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final assetIds = await buildStep.findAssets(Glob('**.router')).toList();
    StringBuffer content = StringBuffer();
    StringBuffer import = StringBuffer();

    content.write('Map<String, Widget Function(BuildContext context)> router = {\n');

    final importReg = RegExp(r"(import 'package:.+.dart';\n)");
    final contentReg = RegExp(r"('.+': \(ctx\) \{(\n|.)+\},)");

    for (final id in assetIds) {
      final data = await buildStep.readAsString(id);
      importReg.allMatches(data).forEach((element) {
        import.write(element.group(1));
      });
      contentReg.allMatches(data).forEach((element) {
        content.write(element.group(1));
        content.write('\n');
      });
    }

    content.write('};');
    final file = File('lib/router.dart');
    if (!file.existsSync()) {
      print('********create file************');
      file.createSync();
    }

    var importStr = import.toString();
    importStr = importStr.split('\n').toSet().join('\n');
    importStr += '\n';

    file.writeAsStringSync(importStr);

    file.writeAsStringSync(content.toString(), mode: FileMode.append);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.router_table.dart']
      };
}
