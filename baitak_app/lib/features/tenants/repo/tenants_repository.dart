import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/tenant.dart';
import '../../../core/network/api_client.dart';

class TenantsRepository {
  TenantsRepository(this._dio);

  final Dio _dio;

  Future<List<TenantWithContext>> listTenants({bool unpaidOnly = false}) async {
    final response = await _dio.get(
      '/tenants',
      queryParameters: unpaidOnly ? {'unpaid_only': true} : null,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TenantWithContext.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TenantOut> assignTenant({
    required int bedId,
    required String name,
    required String phone,
    required DateTime startDate,
    required double rentAmount,
    required String month,
    bool markPaid = false,
  }) async {
    final response = await _dio.post('/tenants/assign', data: {
      'bed_id': bedId,
      'name': name,
      'phone': phone,
      'start_date': startDate.toIso8601String(),
      'rent_amount': rentAmount,
      'month': month,
      'mark_paid': markPaid,
    });
    return TenantOut.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateTenant(
    int id, {
    String? name,
    String? phone,
    DateTime? startDate,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (startDate != null) data['start_date'] = startDate.toIso8601String();
    await _dio.patch('/tenants/$id', data: data);
  }

  Future<void> vacateTenant(int id) async {
    await _dio.post('/tenants/$id/vacate');
  }

  Future<void> markPaid(
    int tenantId, {
    required String month,
    double? amount,
  }) async {
    final data = <String, dynamic>{'month': month};
    if (amount != null) data['amount'] = amount;
    await _dio.post('/tenants/$tenantId/payments/mark-paid', data: data);
  }

  Future<void> markUnpaid(
    int tenantId, {
    required String month,
  }) async {
    await _dio.post('/tenants/$tenantId/payments/mark-unpaid',
        data: {'month': month});
  }
}

final tenantsRepositoryProvider = Provider<TenantsRepository>((ref) {
  return TenantsRepository(ref.watch(apiClientProvider));
});

final tenantsListProvider =
    FutureProvider.autoDispose<List<TenantWithContext>>((ref) {
  return ref.watch(tenantsRepositoryProvider).listTenants();
});

final unpaidTenantsProvider =
    FutureProvider.autoDispose<List<TenantWithContext>>((ref) {
  return ref.watch(tenantsRepositoryProvider).listTenants(unpaidOnly: true);
});

String currentMonth() => DateFormat('yyyy-MM').format(DateTime.now());
