import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../../core/network/api_exception.dart';
import '../data/cloud_repository.dart';
import '../data/models/cloud_models.dart';

final cloudControllerProvider = AsyncNotifierProvider<CloudController, void>(
    CloudController.new,
);

class CloudController extends AsyncNotifier<void> {
    @override
    Future<void> build() async {}

    Future<void> linkGoogle() async {
        state = const AsyncLoading();
        state = await AsyncValue.guard(() async {
            final authorizationUrl = await ref
                    .read(cloudRepositoryProvider)
                    .createGoogleLink();
            final callback = await FlutterWebAuth2.authenticate(
                url: authorizationUrl,
                callbackUrlScheme: 'mydrive',
            );
            final callbackUri = Uri.tryParse(callback);
            final error = callbackUri?.queryParameters['error'];
            if (error != null && error.isNotEmpty) {
                throw ApiException('Google Drive linking failed: $error');
            }
            ref.invalidate(cloudAccountsProvider);
            ref.invalidate(fileSummaryProvider);
        });
    }

    Future<void> unlinkAccount(CloudAccount account) async {
        state = const AsyncLoading();
        state = await AsyncValue.guard(() async {
            await ref.read(cloudRepositoryProvider).unlinkAccount(account.id);
            ref.invalidate(cloudAccountsProvider);
            ref.invalidate(fileSummaryProvider);
        });
    }
}
