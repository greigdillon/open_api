import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:openapi_code_builder/openapi_code_builder.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

final _logger = Logger('main');

void main() {
  PrintAppender.setupLogging();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OpenApiGenerator(),
    );
  }
}

class OpenApiGenerator extends StatefulWidget {
  @override
  _OpenApiGeneratorState createState() => _OpenApiGeneratorState();
}

class _OpenApiGeneratorState extends State<OpenApiGenerator> {
  final _input = TextEditingController();
  final _output = TextEditingController();

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/petstore.schema.yaml').then((value) {
      _input.text = value;
      _updateInput(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monoFont = GoogleFonts.ubuntuMono();
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenAPI Generator'),
      ),
      body: Column(
        children: [
          Markdown(
            onTapLink: (text, href, title) {
              launch(href!);
            },
            shrinkWrap: true,
            data: '''
# OpenAPI Generator

Generates dart code for client AND server applications from OpenAPI 3.0 
yaml schema file. Typically this is used in a project using
build_runner. This is just a quick example what kind of code is generated :-)

See [GitHub project for details](https://github.com/hpoul/openapi_dart).
          ''',
          ),
          Expanded(
            child: Row(
              children: [
                CodeWidget(
                  labelText: 'OpenApi 3.0 yaml',
                  controller: _input,
                  onChanged: _updateInput,
                  style: monoFont,
                ),
                Container(
                  width: 4,
                  height: double.infinity,
                  color: Theme.of(context).primaryColor,
                ),
                CodeWidget(
                  labelText: 'Generated Dart Client/Server stubs',
                  controller: _output,
                  onChanged: _updateInput,
                  style: monoFont,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateInput(String value) async {
    try {
      final api = OpenApiCodeBuilderUtils.loadApiFromYaml(value);
      final generator =
          OpenApiLibraryGenerator(api, 'ExampleApi', 'example.dart');
      final out = OpenApiCodeBuilderUtils.formatLibrary(generator.generate(),
          useNullSafetySyntax: true);
      _output.text = out;
      _logger.info('Updated output.');
    } catch (e, stackTrace) {
      _logger.warning('Error while generating library.', e, stackTrace);
    }
  }
}

class CodeWidget extends StatefulWidget {
  const CodeWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.style,
    this.labelText,
  }) : super(key: key);

  final TextEditingController controller;
  final void Function(String changed) onChanged;
  final TextStyle? style;
  final String? labelText;

  @override
  _CodeWidgetState createState() => _CodeWidgetState();
}

class _CodeWidgetState extends State<CodeWidget> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: scrollController,
          child: TextField(
            decoration: InputDecoration(
              labelText: widget.labelText,
              border: OutlineInputBorder(),
            ),
            scrollController: scrollController,
            enabled: true,
            controller: widget.controller,
            maxLines: null,
            onChanged: widget.onChanged,
            style: widget.style,
          ),
        ),
      ),
    );
  }
}
