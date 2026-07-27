import 'event_model.dart';


class PaginatedEvents {
  const PaginatedEvents({
    required this.events,
    required this.totalCount,
    required this.currentPage,
    required this.hasNextPage,
    this.isLoadingMore = false,
  });

  final List<EventModel> events;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;

  PaginatedEvents copyWith({
    List<EventModel>? events,
    int? totalCount,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) {
    return PaginatedEvents(
      events: events ?? this.events,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore:
          isLoadingMore ?? this.isLoadingMore,
    );
  }
}