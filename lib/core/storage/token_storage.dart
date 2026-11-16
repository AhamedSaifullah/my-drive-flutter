import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>(
    (ref) => const TokenStorage(),
);

class TokenStorage {
    const TokenStorage();

    static const _storage = FlutterSecureStorage();

    Future<void> save(String access, String refresh) async {
        await _storage.write(key: 'access', value: access);
        await _storage.write(key: 'refresh', value: refresh);
    }

    Future<String?> get access => _storage.read(key: 'access');
    Future<String?> get refresh => _storage.read(key: 'refresh');
    Future<void> clear() => _storage.deleteAll();
}
