import 'dart:convert';

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

    Future<bool> hasValidAccessToken() async {
        final token = await access;
        if (token == null || token.isEmpty) return false;

        final parts = token.split('.');
        if (parts.length != 3) return false;

        try {
            final payload = jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
            );
            if (payload is! Map<String, dynamic>) return false;

            final expiry = payload['exp'];
            final expirySeconds = expiry is num
                    ? expiry.toInt()
                    : int.tryParse(expiry?.toString() ?? '');
            if (expirySeconds == null) return false;

            final expiryDate = DateTime.fromMillisecondsSinceEpoch(
                expirySeconds * 1000,
                isUtc: true,
            );
            return expiryDate.isAfter(
                DateTime.now().toUtc().add(const Duration(seconds: 30)),
            );
        } on FormatException {
            return false;
        } on JsonUnsupportedObjectError {
            return false;
        }
    }
}
