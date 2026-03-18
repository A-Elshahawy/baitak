import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  factory ApiException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    String message;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      message = 'انتهت مهلة الاتصال';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'تعذر الاتصال بالخادم';
    } else if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) {
          message = detail;
        } else if (detail is List && detail.isNotEmpty) {
          message = detail.first['msg']?.toString() ?? 'خطأ في البيانات';
        } else {
          message = detail.toString();
        }
      } else {
        message = 'خطأ ${e.response!.statusCode}';
      }
    } else {
      message = 'حدث خطأ غير متوقع';
    }

    return ApiException(statusCode: statusCode, message: message);
  }

  factory ApiException.unauthorized() =>
      const ApiException(statusCode: 401, message: 'غير مصرح');

  @override
  String toString() => 'ApiException($statusCode): $message';
}
