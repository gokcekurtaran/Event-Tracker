import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../data/favorite_repository.dart';
import '../models/favorite_model.dart';

final favoriteRepositoryProvider =
    Provider<FavoriteRepository>(
  (ref) {
    return FavoriteRepository(
      ref.watch(apiClientProvider),
    );
  },
);

// Kullanıcının favorilerini backend'den getirir.
final favoritesProvider =
    FutureProvider<List<FavoriteModel>>(
  (ref) {
    return ref
        .watch(favoriteRepositoryProvider)
        .getFavorites();
  },
);