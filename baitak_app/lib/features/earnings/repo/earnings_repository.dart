import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/stats.dart';
import '../../../core/network/api_client.dart';

class EarningsRepository {
  EarningsRepository(this._dio);

  final Dio _dio;

  Future<EarningsStats> getEarnings() async {
    final response = await _dio.get('/stats/earnings');
    return EarningsStats.fromJson(response.data as Map<String, dynamic>);
  }
}

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepository(ref.watch(apiClientProvider));
});

final earningsProvider = FutureProvider.autoDispose<EarningsStats>((ref) {
  return ref.watch(earningsRepositoryProvider).getEarnings();
});
