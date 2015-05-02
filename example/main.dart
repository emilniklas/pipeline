import 'package:pipeline/pipeline.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Test implements Middleware<HttpRequest> {

  Future<HttpRequest> pipe(HttpRequest httpRequest) async {

    print('passing Test');

    httpRequest.response.write('cool');

    return httpRequest;
  }

  Future close() async {
    print('closing Test');
  }
}

class ReadLine implements Middleware<String> {

  String buffer;

  Future<String> pipe(List<int> units) async {

    String character = UTF8.decode(units);

    buffer += character;

    if (character != '\n') return null;

    String line = buffer;

    buffer = '';

    return line;
  }

  Future close() async {}
}

class Responder implements Middleware<HttpRequest> {

  Future<HttpRequest> pipe(HttpRequest httpRequest) async {

    print('passing Responder');

    httpRequest.response.write('stuff');

    return httpRequest;
  }

  Future close() async {
    print('closing Responder');
  }
}

main() async {

  HttpServer httpServer = await HttpServer.bind('localhost', 1337);

  //  Pipeline pipeline = new Pipeline.fromStream(httpServer, middleware: [
  //    new Test(),
  //    new Responder(),
  //  ]);

  Pipeline<HttpRequest> pipeline = new Pipeline();

  httpServer.pipe(pipeline);

  pipeline.middleware.addAll([
    new Test(),
    new Responder(),
  ]);

//  pipeline.first.then((HttpRequest request) {
//
//    request.response.write('first');
//    request.response.close();
//  });

  pipeline.skip(1).listen((HttpRequest request) {

    request.response.close();
  });

  //  pipeline.listen((HttpRequest fin) {
  //
  //    fin.response.close();
  //  });
}