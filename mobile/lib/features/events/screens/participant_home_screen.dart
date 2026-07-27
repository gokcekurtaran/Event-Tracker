import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/category_model.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class ParticipantHomeScreen
    extends ConsumerStatefulWidget {
  const ParticipantHomeScreen({
    super.key,
  });

  @override
  ConsumerState<ParticipantHomeScreen> createState() {
    return _ParticipantHomeScreenState();
  }
}

class _ParticipantHomeScreenState
    extends ConsumerState<ParticipantHomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();

    super.dispose();
  }

  void _handleScroll() {
    if (
        _scrollController.position.pixels >=
            _scrollController
                    .position.maxScrollExtent -
                300) {
      ref
          .read(eventsProvider.notifier)
          .loadMore();
    }
  }

  void _selectCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });

    ref
        .read(eventsProvider.notifier)
        .applyFilters(
          categoryId: categoryId,
          search: _searchController.text,
        );
  }
  void _search() {
    ref
        .read(eventsProvider.notifier)
        .applyFilters(
          categoryId: _selectedCategoryId,
          search: _searchController.text,
        );
  }
  void _clearSearch() {
  // Arama alanındaki metni temizler.
  _searchController.clear();

  // Açık klavyeyi kapatır.
  FocusScope.of(context).unfocus();

  // Suffix ikonunun kaybolması için ekranı yeniler.
  setState(() {});

  // Seçili kategoriyi koruyarak arama filtresini temizler.
  ref
      .read(eventsProvider.notifier)
      .applyFilters(
        categoryId: _selectedCategoryId,
        search: null,
      );
}

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final categoriesState = ref.watch(
      categoriesProvider,
    );
    final eventsState = ref.watch(
      eventsProvider,
    );

    final String firstName =
        authState.value?.firstName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, $firstName',
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(eventsProvider.notifier)
                  .refreshEvents();
            },
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref
              .read(eventsProvider.notifier)
              .refreshEvents();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Events',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Find your next experience.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
  controller: _searchController,
  textInputAction: TextInputAction.search,

  // Kullanıcı yazdıkça X ikonunun görünümünü günceller.
  onChanged: (value) {
    setState(() {});
  },

  // Klavyedeki arama tuşuna basıldığında filtreleme yapar.
  onSubmitted: (value) {
    _search();
  },

  decoration: InputDecoration(
    hintText: 'Search events',
    prefixIcon: const Icon(
      Icons.search_rounded,
    ),

    // Alan boşken ikon göstermez, yazı varsa X gösterir.
    suffixIcon:
        _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: _clearSearch,
                tooltip: 'Clear search',
                icon: const Icon(
                  Icons.close_rounded,
                ),
              )
            : null,
  ),
),
                    const SizedBox(height: 20),
                    Text(
                      'Categories',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 46,
                child: categoriesState.when(
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  error: (error, stackTrace) {
                    return Center(
                      child: TextButton(
                        onPressed: () {
                          ref.invalidate(
                            categoriesProvider,
                          );
                        },
                        child: const Text(
                          'Retry categories',
                        ),
                      ),
                    );
                  },
                  data: (categories) {
                    return ListView(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            right: 8,
                          ),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected:
                                _selectedCategoryId ==
                                    null,
                            showCheckmark: false,        
                            onSelected: (_) {
                              _selectCategory(null);
                            },
                          ),
                        ),
                        ...categories.map(
                          (CategoryModel category) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                right: 8,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  '${category.icon} '
                                  '${category.name}',
                                ),
                                selected:
                                    _selectedCategoryId ==
                                        category.id,
                                showCheckmark:false,       
                                onSelected: (_) {
                                  _selectCategory(
                                    category.id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 22),
            ),

            eventsState.when(
              loading: () {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              error: (error, stackTrace) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref
                          .read(eventsProvider.notifier)
                          .refreshEvents();
                    },
                  ),
                );
              },
              data: (eventData) {
                if (eventData.events.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyEventView(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    28,
                  ),
                  sliver: SliverList.separated(
                    itemCount: eventData.events.length +
                        (eventData.isLoadingMore ? 1 : 0),
                    separatorBuilder: (
                      context,
                      index,
                    ) {
                      return const SizedBox(
                        height: 16,
                      );
                    },
                    itemBuilder: (context, index) {
                      if (
                          index ==
                          eventData.events.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      }

                      final event =
                          eventData.events[index];

                      return EventCard(
                        event: event,
                        onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return EventDetailScreen(
          eventId: event.id,
        );
      },
    ),
  );
},
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEventView extends StatelessWidget {
  const _EmptyEventView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}