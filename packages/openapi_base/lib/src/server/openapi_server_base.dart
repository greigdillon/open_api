import 'dart:io';

abstract class OpenApiServerBase {
  Future<HttpServer> startServer({
    String address = 'localhost',
    int port = 8080,
  });
}

abstract class StoppableProcessBase {
  Future<int> get exitCode;
  Future stop(int exitCode, {String? reason});
}
