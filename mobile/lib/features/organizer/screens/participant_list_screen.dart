import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/organizer_participant_model.dart';
import '../providers/organizer_management_provider.dart';


class ParticipantListScreen
    extends ConsumerWidget {
  const ParticipantListScreen({
    required this.eventId,
    required this.eventTitle,
    super.key,
  });

  final int eventId;
  final String eventTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantState = ref.watch(
      organizerParticipantsProvider(eventId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Participants',
        ),
      ),
      body: participantState.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  organizerParticipantsProvider(
                    eventId,
                  ),
                );
              },
              child: const Text(
                'Try Again',
              ),
            ),
          );
        },
        data: (participants) {
          if (participants.isEmpty) {
            return const Center(
              child: Text(
                'No participants registered yet.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                organizerParticipantsProvider(
                  eventId,
                ),
              );

              await ref.read(
                organizerParticipantsProvider(
                  eventId,
                ).future,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: participants.length,
              separatorBuilder: (
                context,
                index,
              ) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                final OrganizerParticipantModel
                    participant =
                    participants[index];

                return Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundImage: participant
                                      .user
                                      .profileImage !=
                                  null &&
                              participant
                                  .user
                                  .profileImage!
                                  .isNotEmpty
                          ? CachedNetworkImageProvider(
                              participant
                                  .user
                                  .profileImage!,
                            )
                          : null,
                      child: participant
                                      .user
                                      .profileImage ==
                                  null ||
                              participant
                                  .user
                                  .profileImage!
                                  .isEmpty
                          ? Text(
                              participant
                                      .user
                                      .fullName
                                      .isEmpty
                                  ? '?'
                                  : participant
                                      .user
                                      .fullName[0]
                                      .toUpperCase(),
                            )
                          : null,
                    ),
                    title: Text(
                      participant.user.fullName,
                    ),
                    subtitle: Text(
                      '${participant.user.email}\n'
                      'Registered: '
                      '${DateFormat('MMM d, yyyy • HH:mm').format(participant.registeredAt)}',
                    ),
                    isThreeLine: true,
                    trailing: Icon(
                      participant.isCheckedIn
                          ? Icons.check_circle
                          : Icons.schedule,
                      color: participant.isCheckedIn
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}