import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_events.dart';
import '../repo/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final sub = AuthEvents.onUnauthorized.listen((_) async {
      await ref.read(secureStorageProvider).delete(key: 'auth_token');
      state = const AsyncData(null);
    });
    ref.onDispose(sub.cancel);

    final token =
        await ref.read(secureStorageProvider).read(key: 'auth_token');
    if (token == null) return null;

    try {
      return await ref.read(authRepositoryProvider).getMe();
    } catch (_) {
      await ref.read(secureStorageProvider).delete(key: 'auth_token');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result =
          await ref.read(authRepositoryProvider).login(email, password);
      await ref
          .read(secureStorageProvider)
          .write(key: 'auth_token', value: result.token);
      return result.user;
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .register(name, email, password);
      final result =
          await ref.read(authRepositoryProvider).login(email, password);
      await ref
          .read(secureStorageProvider)
          .write(key: 'auth_token', value: result.token);
      return result.user;
    });
  }

  Future<void> updateUser({String? name, double? commissionRate}) async {
    final updated = await ref
        .read(authRepositoryProvider)
        .updateMe(name: name, commissionRate: commissionRate);
    state = AsyncData(updated);
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).delete(key: 'auth_token');
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
