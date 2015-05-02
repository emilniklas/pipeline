# pipeline

Easily transform any stream into a queue of middleware to treat each object in the stream.

## Usage

First, let's look at the middleware.

```dart
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
```

The `Middleware` interface contains `Future<T> pipe(T item)` and `Future close()`. The return value of the pipe 
method are sent to the next middleware in the pipeline. The return value can be either a value or a Future. The 
pipeline will wait before it sends it through to the next middleware.

If the return value is `null` or `Future<null>` the item will be dropped from the pipeline and will never reach the 
next middleware. This is useful for buffering data up to a specific point and then releasing through to the next 
middleware. 

This is a middleware that accepts data from a file stream, but only passes forward every line as it is processed.

```dart
class ReadLine implements Middleware<String> {

  String buffer;

  Future<String> pipe(List<int> units) async {

    String character = UTF8.decode(units);

    buffer += character;

    // If the character isn't a newline, remove this item from the pipeline
    if (character != '\n') return null;
    
    String line = buffer;
    
    buffer = '';
    
    return line;
  }

  Future close() async {}
}
```

### Pipeline

To actually use these middleware, we can either create a `Pipeline` object with the file stream, or we can pipe the 
stream to a pipeline object. The pipeline itself is a stream, so we can return the pipeline and allow other parts of 
the program to listen to it.

```dart
Pipeline<String> everyLineNumbered(File file) {
  
  Stream<List<int>> stream = file.openRead();
  
  Pipeline<String> pipeline = new Pipeline(middleware: [
    new ReadLine(),
    new PrependLine(),
  ]);
  
  stream.pipe(pipeline);
  
  return pipeline;
}
```

In this case, it might be nice to refactor into the `Pipeline.fromStream` constructor, like so:

```dart
Pipeline<String> everyLineNumbered(File file) => new Pipeline.fromStream(
  file.openRead(),
  middleware: [
    new ReadLine(),
    new PrependLine(),
  ]
);
```

# Use with HttpServer

A good use case for the pipeline is when you're setting up an `HttpServer`. That could look something like this:

```dart
import 'dart:io';
import 'package:pipeline/pipeline.dart';

main() async {
  
  HttpServer server = await HttpServer.bind('localhost', 1337);
  
  Pipeline<HttpRequest> pipeline = new Pipeline.fromStream(server, middleware: [
    new CsrfVerifier(), // Middleware<HttpRequest> that protects against CSRF by comparing some tokens.
    new HttpHandler(), // A handler that writes to the response object
  ]);
  
  await for(HttpRequest request in pipeline) {
  
    // Every response should be closed in the end
    request.response.close();
  }
}
```


# TODO

* Write tests