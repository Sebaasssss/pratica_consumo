import 'package:dio/dio.dart';

import 'bitacora_interceptor.dart';

const urlDummyJson = 'https://dummyjson.com';

/// Crea el cliente Dio de la app: HTTPS, timeouts y bitácora segura.
Dio crearDioRecetas({List<Interceptor> interceptores = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlDummyJson,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors
    ..add(BitacoraInterceptor())
    ..addAll(interceptores);
  return dio;
}
