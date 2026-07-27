import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../events/providers/event_provider.dart';
import '../../events/screens/event_detail_screen.dart';
import '../data/favorite_repository.dart';
import '../models/favorite_model.dart';
import '../providers/favorite_provider.dart';


class FavoriteEventsScreen
    extends ConsumerStatefulWidget {
  const FavoriteEventsScreen({
    super.key,
  });

  @override
  ConsumerState<FavoriteEventsScreen> createState() {
    return _FavoriteEventsScreenState();
  }
}


class _FavoriteEventsScreenState
    extends ConsumerState<FavoriteEventsScreen> {
  final Set<int> _processingEventIds = {};

  Future<void> _removeFavorite(
    FavoriteModel favorite,
  ) async {
    setState(() {
      _processingEventIds.add(
        favorite.event.id,
      );
    });

    try {
      await ref
          .read(favoriteRepositoryProvider)
          .removeFavorite(
            favorite.event.id,
          );

      // Favori listesinin backend'den yeniden alınmasını sağlar.
      ref.invalidate(
        favoritesProvider,
      );

      // Ana sayfadaki kalp durumunun güncellenmesini sağlar.
      ref.invalidate(
        eventsProvider,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The event has been removed from your favorites.',
            ),
          ),
        );
      }
    } on FavoriteException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message,
            ),
            backgroundColor:
                Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingEventIds.remove(
            favorite.event.id,
          );
        });
      }
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(
      favoritesProvider,
    );

    await ref.read(
      favoritesProvider.future,
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteState = ref.watch(
      favoritesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Events',
        ),
      ),
      body: favoriteState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _FavoriteErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                favoritesProvider,
              );
            },
          );
        },
        data: (favorites) {
          if (favorites.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: const CustomScrollView(
                physics:
                    AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyFavoriteView(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                28,
              ),
              itemCount: favorites.length,
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(height: 14);
              },
              itemBuilder: (context, index) {
                final FavoriteModel favorite =
                    favorites[index];

                final bool isProcessing =
                    _processingEventIds.contains(
                  favorite.event.id,
                );

                return _FavoriteCard(
                  favorite: favorite,
                  isProcessing: isProcessing,
                  onRemove: () {
                    _removeFavorite(favorite);
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) {
                          return EventDetailScreen(
                            eventId:
                                favorite.event.id,
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
    );
  }
}


class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.isProcessing,
    required this.onTap,
    required this.onRemove,
  });

  final FavoriteModel favorite;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final event = favorite.event;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 145,
              child: event.coverImage.isEmpty
                  ? Container(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: const Icon(
                        Icons.event_rounded,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: event.coverImage,
                      fit: BoxFit.cover,
                      errorWidget: (
                        context,
                        url,
                        error,
                      ) {
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: const Icon(
                            Icons.event_rounded,
                          ),
                        );
                      },
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.categoryIcon} '
                      '${event.categoryName}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      DateFormat(
                        'MMM d, yyyy • HH:mm',
                      ).format(event.startDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${event.locationName}, '
                      '${event.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : IconButton(
                              onPressed: onRemove,
                              tooltip:
                                  'Remove from favorites',
                              icon: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EmptyFavoriteView extends StatelessWidget {
  const _EmptyFavoriteView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 68,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            Text(
              'No favorite events',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Events you add to your favorites '
              'will appear here.',
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
class _FavoriteErrorView extends StatelessWidget {
  const _FavoriteErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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