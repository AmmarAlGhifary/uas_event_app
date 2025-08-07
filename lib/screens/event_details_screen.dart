
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uas_event_app/models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  String _formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            _buildDetailRow(
              context,
              icon: Icons.location_on_outlined,
              title: 'Lokasi',
              subtitle: event.location,
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Tanggal Mulai',
              subtitle: _formatDate(event.startDate),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              title: 'Tanggal Selesai',
              subtitle: _formatDate(event.endDate),
            ),
            const Divider(height: 48, thickness: 1),

            Text(
              'Deskripsi',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.black.withOpacity(0.7)),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context,
      {required IconData icon,
        required String title,
        required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
