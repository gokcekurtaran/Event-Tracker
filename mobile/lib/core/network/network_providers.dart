import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';
import 'api_client.dart';


final tokenStorageProvider = Provider<TokenStorage>(
  (ref) {
    // Uygulama boyunca tek TokenStorage nesnesi kullanır.
    return TokenStorage();
  },
);


final apiClientProvider = Provider<ApiClient>(
  (ref) {
    final TokenStorage tokenStorage = ref.watch(
      tokenStorageProvider,
    );

    // Bütün repository sınıfları aynı ApiClient'ı kullanır.
    return ApiClient(
      tokenStorage,
    );
  },
);