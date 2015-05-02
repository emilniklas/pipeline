part of pipeline;

abstract class Middleware<T> {

  Future<T> pipe(T item);

  Future close();
}