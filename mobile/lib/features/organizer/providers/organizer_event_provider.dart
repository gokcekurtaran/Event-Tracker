import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../../events/models/paginated_events.dart';
import '../data/organizer_repository.dart';


final organizerRepositoryProvider =
    Provider<OrganizerRepository>(
  (ref) {
    return OrganizerRepository(
      ref.watch(apiClientProvider),
    );
  },
);

final organizerEventsProvider =
    AsyncNotifierProvider<
        OrganizerEventsNotifier,
        PaginatedEvents>(
  OrganizerEventsNotifier.new,
);

class OrganizerEventsNotifier
    extends AsyncNotifier<PaginatedEvents> {
  @override
  Future<PaginatedEvents> build() {
    return ref
        .watch(organizerRepositoryProvider)
        .getMyEvents();
  }

  Future<void> refreshEvents() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () {
        return ref
            .read(organizerRepositoryProvider)
            .getMyEvents();
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

    state = AsyncData(
      currentData.copyWith(
        isLoadingMore: true,
      ),
    );

    try {
      final PaginatedEvents nextPage = await ref
          .read(organizerRepositoryProvider)
          .getMyEvents(
            page: currentData.currentPage + 1,
          );

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
    } on OrganizerException {
      // Yeni sayfa yüklenemezse mevcut listeyi korur.
      state = AsyncData(
        currentData.copyWith(
          isLoadingMore: false,
        ),
      );
    }
  }
}