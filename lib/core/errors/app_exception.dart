import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  factory AppException.fromDio(DioException e) {
    final data = e.response?.data;
    final msg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : e.message ?? 'Unknown error';
    return AppException(
      message: msg,
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => message;
}
