import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'create_event_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/models/event_model.dart';
import '../providers/organizer_event_provider.dart';
import 'organizer_event_detail_screen.dart';

class OrganizerHomeScreen
    extends ConsumerStatefulWidget {
  const OrganizerHomeScreen({
    super.key,
  });

  @override
  ConsumerState<OrganizerHomeScreen> createState() {
    return _OrganizerHomeScreenState();
  }
}


class _OrganizerHomeScreenState
    extends ConsumerState<OrganizerHomeScreen> {
  final ScrollController _scrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );
  }

  @override
  void dispose() {
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
          .read(
            organizerEventsProvider.notifier,
          )
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(
      authProvider,
    );

    final eventState = ref.watch(
      organizerEventsProvider,
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
                  .read(
                    organizerEventsProvider.notifier,
                  )
                  .refreshEvents();
            },
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          IconButton(
            onPressed: () {
              ref
                  .read(authProvider.notifier)
                  .logout();
            },
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return const CreateEventScreen();
      },
    ),
  );
},
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Create Event',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () {
          return ref
              .read(
                organizerEventsProvider.notifier,
              )
              .refreshEvents();
        },
        child: eventState.when(
          loading: () {
            return const CustomScrollView(
              physics:
                  AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          },

          error: (error, stackTrace) {
            return CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _OrganizerErrorView(
                    message: error.toString(),
                    onRetry: () {
                      ref
                          .read(
                            organizerEventsProvider
                                .notifier,
                          )
                          .refreshEvents();
                    },
                  ),
                ),
              ],
            );
          },

          data: (eventData) {
            if (eventData.events.isEmpty) {
              return const CustomScrollView(
                physics:
                    AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyOrganizerView(),
                  ),
                ],
              );
            }

            return ListView.separated(
              controller: _scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                100,
              ),
              itemCount: eventData.events.length +
                  (eventData.isLoadingMore ? 1 : 0),
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(height: 14);
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

                final EventModel event =
                    eventData.events[index];

                return _OrganizerEventCard(
                  event: event,
                  onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return OrganizerEventDetailScreen(
          eventId: event.id,
        );
      },
    ),
  );
},
                );
              },
            );
          },
        ),
      ),
    );
  }
}


class _OrganizerEventCard extends StatelessWidget {
  const _OrganizerEventCard({
    required this.event,
    required this.onTap,
  });

  final EventModel event;
  final VoidCallback onTap;

  Color _statusColor() {
    switch (event.status) {
      case 'published':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _statusText() {
    switch (event.status) {
      case 'published':
        return 'Published';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Draft';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 165,
              child: event.coverImage.isEmpty
                  ? Container(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: const Icon(
                        Icons.event_rounded,
                        size: 54,
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
                            size: 54,
                          ),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Text(
                          _statusText(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${event.category.icon} '
                        '${event.category.name}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    DateFormat(
                      'MMM d, yyyy • HH:mm',
                    ).format(event.startDate),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    '${event.locationName}, '
                    '${event.city}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${event.participantCount}'
                        ' / ${event.capacity}',
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EmptyOrganizerView extends StatelessWidget {
  const _EmptyOrganizerView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_business_outlined,
              size: 68,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            Text(
              'No events created',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first event to get started.',
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


class _OrganizerErrorView extends StatelessWidget {
  const _OrganizerErrorView({
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