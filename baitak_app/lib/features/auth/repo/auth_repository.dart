import 'package:dio/dio.dart' show Dio, Options;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/otp.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<({String token, User user})> login(
    String email,
    String password,
  ) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final token = response.data['access_token'] as String;
    final user = await getMe(token: token);
    return (token: token, user: user);
  }

  Future<User> register(String name, String email, String password) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> getMe({String? token}) async {
    final opts = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;
    final response = await _dio.get('/auth/me', options: opts);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> updateMe({String? name, double? commissionRate}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (commissionRate != null) data['commission_rate'] = commissionRate;
    final response = await _dio.patch('/auth/me', data: data);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> requestOtp(String phone) async {
    await _dio.post('/auth/otp/request', data: {'phone': phone});
  }

  Future<OTPTokenOut> verifyOtp(
    String phone,
    String code, {
    String? name,
  }) async {
    final response = await _dio.post('/auth/otp/verify', data: {
      'phone': phone,
      'code': code,
      if (name != null) 'name': name,
    });
    return OTPTokenOut.fromJson(response.data as Map<String, dynamic>);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});
