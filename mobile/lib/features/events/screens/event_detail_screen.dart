import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../favorites/providers/favorite_provider.dart';
import '../data/event_repository.dart';
import '../models/event_model.dart';
import '../providers/event_detail_provider.dart';
import '../providers/event_provider.dart';


class EventDetailScreen
    extends ConsumerStatefulWidget {
  const EventDetailScreen({
    required this.eventId,
    super.key,
  });

  final int eventId;

  @override
  ConsumerState<EventDetailScreen> createState() {
    return _EventDetailScreenState();
  }
}


class _EventDetailScreenState
    extends ConsumerState<EventDetailScreen> {
  bool _isProcessing = false;

  Future<void> _joinEvent(
    EventModel event,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Kullanıcıyı seçilen etkinliğe kaydeder.
      await ref
          .read(eventRepositoryProvider)
          .joinEvent(event.id);

      await _refreshEvent();

      if (mounted) {
        _showMessage(
          'You have joined the event successfully.',
        );
      }
    } on EventException catch (error) {
      if (mounted) {
        _showMessage(
          error.message,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _confirmLeave(
    EventModel event,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancel Registration',
          ),
          content: const Text(
            'Are you sure you want to cancel '
            'your registration for this event?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Keep Registration',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Cancel Registration',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Kullanıcının etkinlik kaydını iptal eder.
      await ref
          .read(eventRepositoryProvider)
          .leaveEvent(event.id);

      await _refreshEvent();

      if (mounted) {
        _showMessage(
          'Your registration has been cancelled.',
        );
      }
    } on EventException catch (error) {
      if (mounted) {
        _showMessage(
          error.message,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(
    EventModel event,
  ) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      if (event.isFavorite) {
        // Etkinlik favorilerdeyse favorilerden çıkarır.
        await ref
            .read(eventRepositoryProvider)
            .removeFavorite(event.id);
      } else {
        // Etkinlik favorilerde değilse favorilere ekler.
        await ref
            .read(eventRepositoryProvider)
            .addFavorite(event.id);
      }

      await _refreshEvent();
      ref.invalidate(
        favoritesProvider,
      );

      if (mounted) {
        _showMessage(
          event.isFavorite
              ? 'The event has been removed from your favorites.'
              : 'The event has been added to your favorites.',
        );
      }
    } on EventException catch (error) {
      if (mounted) {
        _showMessage(
          error.message,
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _refreshEvent() async {
    // Detay ekranının güncel veriyi backend'den
    // yeniden almasını sağlar.
    ref.invalidate(
      eventDetailProvider(widget.eventId),
    );

    // Ana sayfadaki katılım, kontenjan ve
    // favori bilgilerini de yeniler.
    await ref
        .read(eventsProvider.notifier)
        .refreshEvents();
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(
      eventDetailProvider(widget.eventId),
    );

    return eventState.when(
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },

      error: (error, stackTrace) {
        return Scaffold(
          appBar: AppBar(),
          body: _DetailErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                eventDetailProvider(widget.eventId),
              );
            },
          ),
        );
      },

      data: (event) {
        return Scaffold(
          body: _buildContent(
            context,
            event,
          ),

          // Katılım butonunu ekranın altında sabit gösterir.
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isProcessing ||
                      (
                        !event.isJoined &&
                        event.remainingCapacity == 0
                      )
                  ? null
                  : () {
                      if (event.isJoined) {
                        _confirmLeave(event);
                      } else {
                        _joinEvent(event);
                      }
                    },
              child: _bottomButton(event),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    EventModel event,
  ) {
    final DateFormat dateFormat = DateFormat(
      'EEEE, MMMM d, yyyy',
    );

    final DateFormat timeFormat = DateFormat(
      'HH:mm',
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          actions: [
            IconButton.filledTonal(
              onPressed: _isProcessing
                  ? null
                  : () {
                      _toggleFavorite(event);
                    },
              tooltip: event.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: Icon(
                event.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: event.isFavorite
                    ? Colors.red
                    : null,
              ),
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: event.coverImage.isEmpty
                ? Container(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.event_rounded,
                      size: 72,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: event.coverImage,
                    fit: BoxFit.cover,
                    placeholder: (
                      context,
                      url,
                    ) {
                      return Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child:
                            const CircularProgressIndicator(),
                      );
                    },
                    errorWidget: (
                      context,
                      url,
                      error,
                    ) {
                      return Container(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.event_rounded,
                          size: 72,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      );
                    },
                  ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            22,
            24,
            22,
            120,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Text(
                  '${event.category.icon} '
                  '${event.category.name}',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  event.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 22),

                _DetailInformation(
                  icon: Icons.calendar_month_outlined,
                  title: dateFormat.format(
                    event.startDate,
                  ),
                  subtitle:
                      '${timeFormat.format(event.startDate)}'
                      ' – ${timeFormat.format(event.endDate)}',
                ),
                const SizedBox(height: 16),

                _DetailInformation(
                  icon: Icons.location_on_outlined,
                  title: event.locationName,
                  subtitle:
                      '${event.address}, ${event.city}',
                ),
                const SizedBox(height: 16),

                _DetailInformation(
                  icon: Icons.people_outline_rounded,
                  title:
                      '${event.participantCount} participants',
                  subtitle:
                      '${event.remainingCapacity} of '
                      '${event.capacity} spots remaining',
                ),
                const SizedBox(height: 16),

                _DetailInformation(
                  icon: Icons.payments_outlined,
                  title: event.isFree
                      ? 'Free Event'
                      : '${event.price.toStringAsFixed(2)} ₺',
                  subtitle: event.isFree
                      ? 'No ticket fee is required.'
                      : 'Payment is not collected in the app.',
                ),

                const SizedBox(height: 30),

                Text(
                  'About this event',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                Text(
                  event.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        height: 1.6,
                      ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Organizer',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _OrganizerAvatar(
                    fullName:
                        event.organizer.fullName,
                    profileImage:
                        event.organizer.profileImage,
                  ),
                  title: Text(
                    event.organizer.fullName,
                  ),
                  subtitle: const Text(
                    'Event Organizer',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomButton(
    EventModel event,
  ) {
    if (_isProcessing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    if (event.isJoined) {
      return const Text(
        'Cancel Registration',
      );
    }

    if (event.remainingCapacity == 0) {
      return const Text(
        'Event Full',
      );
    }

    return const Text(
      'Join Event',
    );
  }
}


class _OrganizerAvatar extends StatelessWidget {
  const _OrganizerAvatar({
    required this.fullName,
    required this.profileImage,
  });

  final String fullName;
  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    final String firstCharacter =
        fullName.trim().isEmpty
            ? '?'
            : fullName.trim()[0].toUpperCase();

    if (
        profileImage != null &&
        profileImage!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          profileImage!,
        ),
      );
    }

    return CircleAvatar(
      child: Text(
        firstCharacter,
      ),
    );
  }
}


class _DetailInformation extends StatelessWidget {
  const _DetailInformation({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _DetailErrorView extends StatelessWidget {
  const _DetailErrorView({
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
            Icon(
              Icons.error_outline_rounded,
              size: 60,
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