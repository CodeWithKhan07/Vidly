import 'package:dio/dio.dart';

/// Base class for all Vidly exceptions
abstract class VidlyException implements Exception {
  final String message;
  final String? code;

  VidlyException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Thrown when the RapidAPI service returns an error or empty result
class ServerException extends VidlyException {
  ServerException(String message, [String? code]) : super(message, code);
}

/// Thrown when there is no internet connection
class NetworkException extends VidlyException {
  NetworkException([String message = "No Internet Connection"])
    : super(message);
}

/// Thrown when the user pastes a URL that isn't supported or is malformed
class InvalidUrlException extends VidlyException {
  InvalidUrlException([String message = "The provided URL is not supported"])
    : super(message);
}

/// Thrown during the actual file downloading process (permission, storage full, etc)
class DownloadException extends VidlyException {
  DownloadException(String message) : super(message);
}

/// Helper to map Dio Errors to our Custom Exceptions
class ExceptionHandler {
  static VidlyException handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException("Connection Timed Out");
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return ServerException(
            "Invalid API Key or Limit Reached",
            "$statusCode",
          );
        }
        return ServerException(
          "Server Error: ${e.response?.statusMessage}",
          "$statusCode",
        );
      case DioExceptionType.cancel:
        return DownloadException("Download Cancelled");
      default:
        return ServerException("Something went wrong. Please try again.");
    }
  }
}
