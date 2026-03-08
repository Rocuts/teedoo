import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../constants/app_constants.dart';
import 'api_result.dart';

/// Provider del cliente Dio configurado.
///
/// Uso:
/// ```dart
/// final dio = ref.read(dioClientProvider);
/// final result = await dio.safeGet<Map<String, dynamic>>('/invoices');
/// ```
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    tokenProvider: () async {
      return ref.read(authTokenProvider);
    },
    onAuthError: () {
      unawaited(
        Future<void>.microtask(() {
          ref.read(authProvider.notifier).logout();
        }),
      );
    },
  );
});

/// Tipo para funciones que proveen el token de autenticación.
typedef TokenProvider = Future<String?> Function();

/// Tipo para callback de error de autenticación (token expirado, etc.).
typedef AuthErrorCallback = void Function();

/// Cliente HTTP configurado para la API de TeeDoo.
///
/// Encapsula Dio con:
/// - Base URL y timeouts
/// - Interceptor de autenticación (JWT Bearer)
/// - Interceptor de errores (DioException -> AppException)
/// - Interceptor de logging (solo en debug)
///
/// Expone métodos safe que retornan [Result<T>] en lugar de lanzar excepciones.
class DioClient {
  late final Dio _dio;
  final TokenProvider _tokenProvider;
  final AuthErrorCallback? _onAuthError;

  DioClient({
    required TokenProvider tokenProvider,
    AuthErrorCallback? onAuthError,
    String? baseUrl,
  }) : _tokenProvider = tokenProvider,
       _onAuthError = onAuthError {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // El orden de los interceptores importa:
    // 1. Auth (agrega token antes de enviar)
    // 2. Logging (registra la request con token)
    // 3. Error (convierte errores al salir)
    _dio.interceptors.addAll([
      _AuthInterceptor(
        tokenProvider: _tokenProvider,
        onAuthError: _onAuthError,
      ),
      if (kDebugMode) _LoggingInterceptor(),
      const _ErrorInterceptor(),
    ]);
  }

  /// Acceso directo al Dio subyacente (para casos excepcionales).
  Dio get dio => _dio;

  // ── Safe Request Methods ──
  // Envuelven llamadas Dio en Result<T> para manejo funcional de errores.

  /// GET request seguro que retorna [Result<T>].
  Future<Result<T>> safeGet<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// POST request seguro que retorna [Result<T>].
  Future<Result<T>> safePost<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// PUT request seguro que retorna [Result<T>].
  Future<Result<T>> safePut<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// PATCH request seguro que retorna [Result<T>].
  Future<Result<T>> safePatch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// DELETE request seguro que retorna [Result<T>].
  Future<Result<T>> safeDelete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Upload de archivo con progreso.
  Future<Result<T>> safeUpload<T>(
    String path, {
    required FormData data,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    return _safeRequest(
      () => _dio.post<T>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      ),
    );
  }

  /// Ejecuta una request Dio y convierte el resultado a [Result<T>].
  Future<Result<T>> _safeRequest<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data == null && null is! T) {
        return Failure(
          UnknownException(
            message:
                'Respuesta vacía del servidor para una request de tipo $T.',
          ),
        );
      }
      return Success(data as T);
    } on DioException catch (e) {
      return Failure(_mapDioException(e));
    } on Exception catch (e) {
      return Failure(UnknownException(message: e.toString(), originalError: e));
    }
  }

  /// Convierte un [DioException] a la jerarquía [AppException].
  static AppException _mapDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => NetworkException(
        message: 'La conexión ha expirado. Verifica tu red.',
        originalError: e,
      ),
      DioExceptionType.connectionError => NetworkException(
        message: 'No se pudo conectar al servidor.',
        originalError: e,
      ),
      DioExceptionType.badResponse => _mapStatusCode(e),
      DioExceptionType.cancel => NetworkException(
        message: 'La solicitud fue cancelada.',
        originalError: e,
      ),
      _ => UnknownException(
        message: e.message ?? 'Error desconocido de red.',
        originalError: e,
      ),
    };
  }

  /// Mapea códigos de estado HTTP a excepciones específicas.
  static AppException _mapStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    // Intentar extraer mensaje del body de la respuesta
    final serverMessage = switch (responseData) {
      {'message': final String msg} => msg,
      {'error': final String msg} => msg,
      {'detail': final String msg} => msg,
      _ => null,
    };

    return switch (statusCode) {
      400 => _mapValidationError(e, serverMessage),
      401 => AuthException(
        message: serverMessage ?? 'Sesión expirada. Inicia sesión de nuevo.',
        statusCode: 401,
        originalError: e,
      ),
      403 => AuthException(
        message: serverMessage ?? 'No tienes permisos para esta acción.',
        statusCode: 403,
        originalError: e,
      ),
      404 => ServerException(
        message: serverMessage ?? 'Recurso no encontrado.',
        statusCode: 404,
        originalError: e,
      ),
      409 => ServerException(
        message: serverMessage ?? 'Conflicto con el estado actual.',
        statusCode: 409,
        originalError: e,
      ),
      422 => _mapValidationError(e, serverMessage),
      429 => ServerException(
        message: serverMessage ?? 'Demasiadas solicitudes. Intenta más tarde.',
        statusCode: 429,
        originalError: e,
      ),
      final code? when code >= 500 => ServerException(
        message: serverMessage ?? 'Error interno del servidor.',
        statusCode: code,
        originalError: e,
      ),
      _ => UnknownException(
        message: serverMessage ?? 'Error inesperado (código $statusCode).',
        originalError: e,
      ),
    };
  }

  /// Extrae errores de validación de campo del body de respuesta.
  static AppException _mapValidationError(
    DioException e,
    String? serverMessage,
  ) {
    final responseData = e.response?.data;

    // Intentar extraer errores por campo
    final fieldErrors = <String, List<String>>{};
    if (responseData case {'errors': final Map<String, dynamic> errors}) {
      for (final entry in errors.entries) {
        fieldErrors[entry.key] = switch (entry.value) {
          final List<dynamic> list => list.map((e) => e.toString()).toList(),
          final String s => [s],
          _ => [entry.value.toString()],
        };
      }
    }

    return ValidationException(
      message: serverMessage ?? 'Datos de entrada inválidos.',
      fieldErrors: fieldErrors,
      statusCode: e.response?.statusCode,
      originalError: e,
    );
  }
}

// ── Interceptors ──

/// Interceptor que agrega el token JWT a cada request.
class _AuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;
  final AuthErrorCallback? _onAuthError;

  const _AuthInterceptor({
    required TokenProvider tokenProvider,
    AuthErrorCallback? onAuthError,
  }) : _tokenProvider = tokenProvider,
       _onAuthError = onAuthError;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _onAuthError?.call();
    }
    handler.next(err);
  }
}

/// Interceptor de logging para modo debug.
///
/// Registra request/response de forma legible en la consola.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final maskedHeaders = Map<String, dynamic>.from(options.headers);
    for (final key in maskedHeaders.keys.toList()) {
      final lower = key.toLowerCase();
      if (lower == 'authorization' ||
          lower.contains('api-key') ||
          lower.contains('token')) {
        maskedHeaders[key] = '***';
      }
    }

    debugPrint(
      '\u2500\u2500 REQUEST \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n'
      '${options.method} ${options.uri}\n'
      'Headers: $maskedHeaders\n'
      '\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '\u2500\u2500 RESPONSE [${response.statusCode}] \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n'
      '${response.requestOptions.method} ${response.requestOptions.uri}\n'
      '\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '\u2500\u2500 ERROR [${err.response?.statusCode}] \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\n'
      '${err.requestOptions.method} ${err.requestOptions.uri}\n'
      'Message: ${err.message}\n'
      '\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500',
    );
    handler.next(err);
  }
}

/// Interceptor de errores que convierte [DioException] a [AppException].
///
/// Este interceptor se ejecuta al final de la cadena para asegurar
/// que los errores ya fueron procesados por auth y logging.
class _ErrorInterceptor extends Interceptor {
  const _ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Los errores 401 ya son manejados por _AuthInterceptor,
    // aquí solo propagamos para que _safeRequest los convierta.
    handler.next(err);
  }
}
