import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';


class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    required this.onTap,
    super.key,
  });

  final EventModel event;
  final VoidCallback onTap;

  Color _categoryColor() {
    try {
      final String colorValue = event.category.color
          .replaceFirst('#', '');

      return Color(
        int.parse(
          'FF$colorValue',
          radix: 16,
        ),
      );
    } on FormatException {
      return const Color(0xFF6750A4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat(
      'EEE, MMM d • HH:mm',
    );

    final Color categoryColor = _categoryColor();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: event.coverImage.isEmpty
                  ? _ImagePlaceholder(
                      color: categoryColor,
                    )
                  : CachedNetworkImage(
                      imageUrl: event.coverImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
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
                        return _ImagePlaceholder(
                          color: categoryColor,
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
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${event.category.icon} '
                          '${event.category.name}',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        event.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: event.isFavorite
                            ? Colors.red
                            : Colors.grey.shade500,
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
                  const SizedBox(height: 12),
                  _InformationRow(
                    icon: Icons.calendar_month_outlined,
                    text: dateFormat.format(
                      event.startDate,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InformationRow(
                    icon: Icons.location_on_outlined,
                    text:
                        '${event.locationName}, ${event.city}',
                  ),
                  const SizedBox(height: 8),
                  _InformationRow(
                    icon: Icons.people_outline_rounded,
                    text:
                        '${event.remainingCapacity} spots remaining',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        event.isFree
                            ? 'Free'
                            : '${event.price.toStringAsFixed(2)} ₺',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      if (event.isJoined)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Joined',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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


class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}


class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(
        alpha: 0.12,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.event_rounded,
        size: 54,
        color: color,
      ),
    );
  }
}