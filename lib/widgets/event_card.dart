import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uas_event_app/models/event_model.dart';
import '../screens/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool isRegistered;
  final VoidCallback onTap;
  final bool showManagementButtons;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.isRegistered = false,
    this.showManagementButtons = false,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStatusChip(BuildContext context) {
    try {
      final now = DateTime.now();
      final startDate = DateTime.parse(event.startDate);

      final today = DateTime(now.year, now.month, now.day);
      final eventDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      if (eventDate.isAtSameMomentAs(today)) {
        return Chip(
          label: const Text('Hari Ini'),
          labelStyle: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.green[100],
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
        );
      } else if (eventDate.isAfter(today)) {
        return Chip(
          label: const Text('Akan Datang'),
          labelStyle: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.blue[100],
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
        );
      } else {
        return Chip(
          label: const Text('Selesai'),
          labelStyle: TextStyle(color: Colors.grey[700]),
          backgroundColor: Colors.grey[300],
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
        );
      }
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSlots = event.registrationsCount + event.availableSpots;

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Image.network(
              'https://picsum.photos/seed/${event.id}/400/200',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        alignment: WrapAlignment.end,
                        children: [
                          if (isRegistered)
                            Chip(
                              label: const Text('Terdaftar'),
                              avatar: const Icon(Icons.check_circle, size: 16),
                              labelStyle: TextStyle(
                                color: Colors.purple[800],
                                fontWeight: FontWeight.bold,
                              ),
                              backgroundColor: Colors.purple[100],
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                            ),
                          _buildStatusChip(context),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Info Tanggal
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDate(event.startDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${event.registrationsCount} / $totalSlots Peserta',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (showManagementButtons)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Hapus'),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
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
