import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../data/event_repository.dart';
import '../models/category_model.dart';
import '../models/paginated_events.dart';


final eventRepositoryProvider = Provider<EventRepository>(
  (ref) {
    return EventRepository(
      ref.watch(apiClientProvider),
    );
  },
);


// Kategorileri backend'den alır ve provider belleğinde saklar.
final categoriesProvider =
    FutureProvider<List<CategoryModel>>(
  (ref) {
    return ref
        .watch(eventRepositoryProvider)
        .getCategories();
  },
);


final eventsProvider = AsyncNotifierProvider<
    EventsNotifier,
    PaginatedEvents>(
  EventsNotifier.new,
);


class EventsNotifier
    extends AsyncNotifier<PaginatedEvents> {
  int? _selectedCategoryId;
  String? _search;

  @override
  Future<PaginatedEvents> build() {
    // Ana sayfa açıldığında yaklaşan etkinlikleri getirir.
    return _getEvents();
  }

  Future<PaginatedEvents> _getEvents({
    int page = 1,
  }) {
    return ref
        .read(eventRepositoryProvider)
        .getEvents(
          page: page,
          categoryId: _selectedCategoryId,
          search: _search,
        );
  }

  Future<void> applyFilters({
    required int? categoryId,
    String? search,
  }) async {
    _selectedCategoryId = categoryId;

    final String normalizedSearch =
        search?.trim() ?? '';

    _search = normalizedSearch.isEmpty
        ? null
        : normalizedSearch;

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () {
        return _getEvents();
      },
    );
  }

  Future<void> refreshEvents() async {
    // Mevcut filtreleri koruyarak etkinlikleri yeniler.
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () {
        return _getEvents();
      },
    );
  }

  Future<void> loadMore() async {
    final PaginatedEvents? currentData =
        state.value;

    if (
        currentData == null ||
        currentData.isLoadingMore ||
        !currentData.hasNextPage) {
      return;
    }

    // Mevcut listeyi koruyarak alt yükleme durumunu açar.
    state = AsyncData(
      currentData.copyWith(
        isLoadingMore: true,
      ),
    );

    try {
      final PaginatedEvents nextPage =
          await _getEvents(
        page: currentData.currentPage + 1,
      );

      // Yeni etkinlikleri mevcut listenin sonuna ekler.
      state = AsyncData(
        PaginatedEvents(
          events: [
            ...currentData.events,
            ...nextPage.events,
          ],
          totalCount: nextPage.totalCount,
          currentPage: nextPage.currentPage,
          hasNextPage: nextPage.hasNextPage,
          isLoadingMore: false,
        ),
      );
    } on EventException {
      // Hata durumunda mevcut etkinlikleri korur.
      state = AsyncData(
        currentData.copyWith(
          isLoadingMore: false,
        ),
      );
    }
  }
}