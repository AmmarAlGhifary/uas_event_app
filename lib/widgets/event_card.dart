// lib/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uas_event_app/models/event_model.dart';
import 'package:uas_event_app/screens/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

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
      final eventDate = DateTime(startDate.year, startDate.month, startDate.day);

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
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://picsum.photos/seed/${event.id}/400/200',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[600],
                    size: 48,
                  ),
                );
              },
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(context),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
