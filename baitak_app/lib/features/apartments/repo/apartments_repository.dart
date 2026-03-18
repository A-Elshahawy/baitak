import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/apartment.dart';
import '../../../core/network/api_client.dart';

class ApartmentsRepository {
  ApartmentsRepository(this._dio);

  final Dio _dio;

  Future<List<Apartment>> listApartments() async {
    final response = await _dio.get('/apartments');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Apartment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Apartment> getApartment(int id) async {
    final response = await _dio.get('/apartments/$id');
    return Apartment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Apartment> createApartment({
    required String name,
    required String area,
    required String address,
    required int floor,
  }) async {
    final response = await _dio.post('/apartments', data: {
      'name': name,
      'area': area,
      'address': address,
      'floor': floor,
    });
    return Apartment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateApartment(
    int id, {
    String? name,
    String? area,
    String? address,
    int? floor,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (area != null) data['area'] = area;
    if (address != null) data['address'] = address;
    if (floor != null) data['floor'] = floor;
    await _dio.patch('/apartments/$id', data: data);
  }

  Future<void> deleteApartment(int id) async {
    await _dio.delete('/apartments/$id');
  }

  Future<Map<String, dynamic>> createRoom(
    int aptId, {
    required String name,
    int orderIndex = 0,
  }) async {
    final response = await _dio.post('/apartments/$aptId/rooms', data: {
      'name': name,
      'order_index': orderIndex,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateRoom(int roomId, {String? name, int? orderIndex}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (orderIndex != null) data['order_index'] = orderIndex;
    await _dio.patch('/rooms/$roomId', data: data);
  }

  Future<void> deleteRoom(int roomId) async {
    await _dio.delete('/rooms/$roomId');
  }

  Future<Map<String, dynamic>> createBed(
    int roomId, {
    required String label,
    required int priceMonthly,
  }) async {
    final response = await _dio.post('/rooms/$roomId/beds', data: {
      'label': label,
      'price_monthly': priceMonthly,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateBed(
    int bedId, {
    String? label,
    int? priceMonthly,
  }) async {
    final data = <String, dynamic>{};
    if (label != null) data['label'] = label;
    if (priceMonthly != null) data['price_monthly'] = priceMonthly;
    await _dio.patch('/beds/$bedId', data: data);
  }

  Future<void> deleteBed(int bedId) async {
    await _dio.delete('/beds/$bedId');
  }
}

final apartmentsRepositoryProvider = Provider<ApartmentsRepository>((ref) {
  return ApartmentsRepository(ref.watch(apiClientProvider));
});

final apartmentsListProvider =
    FutureProvider.autoDispose<List<Apartment>>((ref) {
  return ref.watch(apartmentsRepositoryProvider).listApartments();
});

final apartmentDetailProvider =
    FutureProvider.autoDispose.family<Apartment, int>((ref, id) {
  return ref.watch(apartmentsRepositoryProvider).getApartment(id);
});
