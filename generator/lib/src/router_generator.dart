import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:router/annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen/src/output_helpers.dart';

class RouterGenerator extends Generator {
  TypeChecker get typeChecker => TypeChecker.fromRuntime(RouterConfig);

  TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final values = <String>{};

    for (var annotatedElement in library.annotatedWith(typeChecker)) {
      final generatedValue = generateForAnnotatedElement(annotatedElement.element, annotatedElement.annotation, buildStep);
      await for (var value in normalizeGeneratorOutput(generatedValue)) {
        assert(value == null || (value.length == value.trim().length));
        values.add(value);
      }
    }
    return values.join('\n\n');
  }

  String generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    return parseClz(element, annotation);
  }

  String parseClz(Element element, ConstantReader annotation) {
    final pageUrl = annotation?.peek('path')?.stringValue;
    assert(pageUrl != null);
    assert(element is ClassElement);

    final sb = StringBuffer();

    final clzElement = element as ClassElement;
    final clzName = clzElement.displayName;

    final package = clzElement.location.components[0];
    sb.write("import '$package';\n");
    sb.write("import 'package:flutter/widgets.dart';\n");

    sb.write('''Map<String, Widget Function(BuildContext context)> router = {
      '$pageUrl': (ctx) {
        final args = ModalRoute.of(ctx).settings.arguments as Map<String, dynamic> ?? {};
    ''');

    final constructors = clzElement.constructors;
    final fields = clzElement.fields.where((element) => getMethodAnnotation(element) != null).toList();

    final checker = parseAutowiredCheck(fields);
    if (checker != null && checker.length > 0) {
      sb.write(checker);
    }

    final cons = parseConstructor(clzName, constructors, fields);
    if (cons != null && cons.length > 0) {
      sb.write(cons);
    }

    sb.write('},\n');
    sb.write('};\n');

    return sb.toString();
  }

  String parseAutowiredCheck(List<FieldElement> fields) {
    final sb = StringBuffer();

    for (final field in fields) {
      final fieldName = field.displayName;
      final ann = getFieldAnnotated(field);
      final isRequired = ann?.peek("isRequired")?.boolValue ?? false;
      if (isRequired) {
        sb.write("assert(args['$fieldName'] != null);\n");
      }
    }

    return sb.toString();
  }

  String parseConstructor(String clzName, List<ConstructorElement> constructors, List<FieldElement> fields) {
    final sb = StringBuffer();
    sb.write('return $clzName(');

    if (fields.isNotEmpty) {
      assert(constructors.length == 1);

      final parameters = constructors[0].parameters;
      final requiredParameters = parameters.where((element) => element.isNotOptional).toList();
      final optionalParameters = parameters.where((element) => element.isOptional).toList();

      for (final parameter in requiredParameters) {
        final paramterName = parameter.displayName;
        final field = fields.firstWhere((element) => element.displayName == paramterName, orElse: () => null);
        if (field == null) {
          sb.write('null, ');
        } else {
          sb.write("args['$paramterName'], ");
        }
      }

      for (final parameter in optionalParameters) {
        final paramterName = parameter.displayName;
        final field = fields.firstWhere((element) => element.displayName == paramterName, orElse: () => null);
        if (field == null) {
          sb.write('$paramterName: null, ');
        } else {
          sb.write("$paramterName: args['$paramterName'], ");
        }
      }
    }

    sb.write(');\n');

    return sb.toString();
  }

  ConstantReader getMethodAnnotation(FieldElement method) {
    final annot = _typeChecker(Autowired).firstAnnotationOf(method, throwOnUnresolved: false);
    if (annot != null) return ConstantReader(annot);
    return null;
  }

  ConstantReader getFieldAnnotated(FieldElement element) {
    final ann = _typeChecker(Autowired).firstAnnotationOf(element);
    if (ann != null) return ConstantReader(ann);

    return null;
  }
}

Builder generatorFactoryBuilder(BuilderOptions options) => LibraryBuilder(RouterGenerator(), generatedExtension: '.router');
