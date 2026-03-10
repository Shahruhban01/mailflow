import 'package:dio/dio.dart';
import '../../errors/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Connection timeout. Check your internet.',
      DioExceptionType.receiveTimeout    => 'Server took too long to respond.',
      DioExceptionType.connectionError   => 'No internet connection.',
      _ => err.response?.data?['message'] ?? 'Something went wrong.',
    };
    handler.next(
      err.copyWith(
        error: AppException(message: message, statusCode: err.response?.statusCode),
      ),
    );
  }
}
