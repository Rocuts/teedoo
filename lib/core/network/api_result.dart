/// Result type usando sealed classes (Dart 3.x best practice 2026).
/// Reemplaza fpdart Either para casos simples.
sealed class Result<T> {
  const Result();

  /// Mapea el valor exitoso.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success(:final data) => Success(transform(data)),
    Failure(:final error) => Failure(error),
  };

  /// Ejecuta callback según el tipo.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) => switch (this) {
    Success(:final data) => success(data),
    Failure(:final error) => failure(error),
  };

  /// Obtiene el valor o null.
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  /// Obtiene el error o null.
  AppException? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}

/// Jerarquía de excepciones de la aplicación.
sealed class AppException {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.statusCode,
    this.originalError,
  });
}

final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

final class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors = const {},
    super.statusCode,
    super.originalError,
  });
}

final class UnknownException extends AppException {
  const UnknownException({required super.message, super.originalError});
}
