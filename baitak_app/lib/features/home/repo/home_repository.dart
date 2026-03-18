import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/stats.dart';
import '../../../core/network/api_client.dart';

class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  Future<OverviewStats> getOverview() async {
    final response = await _dio.get('/stats/overview');
    return OverviewStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ApartmentStats>> getApartmentsStats() async {
    final response = await _dio.get('/stats/apartments');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ApartmentStats.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.watch(apiClientProvider));
});

final overviewProvider = FutureProvider.autoDispose<OverviewStats>((ref) {
  return ref.watch(homeRepositoryProvider).getOverview();
});

final apartmentsStatsProvider =
    FutureProvider.autoDispose<List<ApartmentStats>>((ref) {
  return ref.watch(homeRepositoryProvider).getApartmentsStats();
});
