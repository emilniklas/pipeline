part of pipeline;

class Pipeline<T> implements StreamConsumer<T>, Stream<T> {

  Stream _from;

  StreamSubscription _subscription;

  get from {

    return _from;
  }

  set from(Stream from) {

    _from = from;

    _listen();
  }

  StreamController<T> _controller = new StreamController();

  final List<Middleware<T>> middleware = [];

  Pipeline({List<Middleware<T>> middleware}) {

    if (middleware != null)
      this.middleware.addAll(middleware);
  }

  Pipeline.fromStream(Stream stream, {List<Middleware<T>> middleware}) {

    if (middleware != null)
      this.middleware.addAll(middleware);

    this.from = stream;
  }

  _listen() async {

    _subscription = from.listen((T item) async {

      for (Middleware<T> layer in middleware) {

        item = await layer.pipe(item);

        if (item == null) return;
      }

      _controller.add(item);
    });

    await _controller.done;

    await _subscription.cancel();

    for (Middleware<T> layer in middleware) {

      await layer.close();
    }
  }

  Future addStream(Stream stream) async {

    this.from = stream;

    await _controller.done;
  }

  Future close() async {

    if (_controller.isClosed) return;

    print('closing controller');

    await _controller.close();
  }

  Future<bool> any(bool test(T element)) => _controller.stream.any(test);

  Stream asBroadcastStream({void onListen(StreamSubscription subscription), void onCancel(StreamSubscription
  subscription)}) => _controller.stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);

  Stream asyncExpand(Stream convert(T event)) => _controller.stream.asyncExpand(convert);

  Stream asyncMap(convert(T event)) => _controller.stream.asyncMap(convert);

  Future<bool> contains(Object needle) => _controller.stream.contains(needle);

  Stream distinct([bool equals(T previous, T next)]) => _controller.stream.distinct(equals);

  Future drain([futureValue]) => _controller.stream.drain(futureValue);

  Future elementAt(int index) => _controller.stream.elementAt(index);

  Future<bool> every(bool test(T element)) => _controller.stream.every(test);

  Stream expand(Iterable convert(T value)) => _controller.stream.expand(convert);

  Future firstWhere(bool test(T element), {Object defaultValue()}) => _controller.stream.firstWhere(test,
  defaultValue: defaultValue);

  Future fold(initialValue, combine(previous, T element)) => _controller.stream.fold(initialValue, combine);

  Future forEach(void action(T element)) => _controller.stream.forEach(action);

  Stream handleError(Function onError, {bool test(error)}) => _controller.stream.handleError(onError, test: test);

  Future<String> join([String separator = ""]) => _controller.stream.join(separator);

  Future lastWhere(bool test(T element), {Object defaultValue()}) => _controller.stream.lastWhere(test, defaultValue: defaultValue);

  Stream map(convert(T event)) => _controller.stream.map(convert);

  Future pipe(StreamConsumer streamConsumer) => _controller.stream.pipe(streamConsumer);

  Future reduce(T combine(T previous, T element)) => _controller.stream.reduce(combine);

  Future singleWhere(bool test(T element)) => _controller.stream.singleWhere(test);

  Stream skip(int count) => _controller.stream.skip(count);

  Stream skipWhile(bool test(T element)) => _controller.stream.skipWhile(test);

  Stream take(int count) => _controller.stream.take(count);

  Stream takeWhile(bool test(T element)) => _controller.stream.takeWhile(test);

  Stream timeout(Duration timeLimit, {void onTimeout(EventSink sink)}) => _controller.stream.timeout(timeLimit,
  onTimeout: onTimeout);

  Future<List> toList() => _controller.stream.toList();

  Future<Set> toSet() => _controller.stream.toSet();

  Stream transform(StreamTransformer streamTransformer) => _controller.stream.transform(streamTransformer);

  Stream where(bool test(T event)) => _controller.stream.where(test);

  Future get first => _controller.stream.first;

  bool get isBroadcast => _controller.stream.isBroadcast;

  Future<bool> get isEmpty => _controller.stream.isEmpty;

  Future get last => _controller.stream.last;

  Future<int> get length => _controller.stream.length;

  StreamSubscription listen(void onData(T event), {Function onError, void onDone(), bool cancelOnError}) =>
  _controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  Future get single => _controller.stream.single;
}