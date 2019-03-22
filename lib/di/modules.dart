import 'package:dio/dio.dart';

String token = "";

final Dio dio = Dio()
  ..options = BaseOptions(baseUrl: 'https://api.github.com/', connectTimeout: 30, receiveTimeout: 30)
  ..interceptors.add(AuthInterceptor())
  ..interceptors.add(LogInterceptor(responseBody: true, requestBody: true));


class AuthInterceptor extends Interceptor {
  @override
  onRequest(RequestOptions options) {
    options.headers.update("Authorization", (_) => token, ifAbsent: () => token);
    return super.onRequest(options);
  }
}
