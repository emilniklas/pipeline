import 'dart:async';
import 'dart:io';
import 'package:pipeline/pipeline.dart';

main() async {

  await for (String line in await everyLineNumbered(new File('example/main.dart'))) {

    print(line);
  }
}

Future<Pipeline<String>> everyLineNumbered(File file) async => new Pipeline.fromStream(
    new Stream.fromIterable(await file.readAsBytes()),
    middleware: [
      new ReadLine(),
      new PrependLineNumber(),
    ]
);

class ReadLine implements Middleware<int> {

  String buffer = '';

  Future<String> pipe(int unit) async {

    String character = new String.fromCharCode(unit);

    // If the character isn't a newline, remove this item from the pipeline
    if (character != '\n') {

      buffer += character;

      return null;
    }

    String line = buffer;

    buffer = '';

    return line;
  }

  Future close() async {
  }
}

class PrependLineNumber implements Middleware<String> {

  int _number = 0;

  Future<String> pipe(String line) async {

    _number++;

    return '$_number: $line';
  }

  Future close() async {
    // Tear down method

    // Silly example
    _number = -1;
  }
}
