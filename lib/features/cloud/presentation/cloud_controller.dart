import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../data/cloud_repository.dart';

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
            await FlutterWebAuth2.authenticate(
                url: authorizationUrl,
                callbackUrlScheme: 'mydrive',
            );
        });
    }
}
