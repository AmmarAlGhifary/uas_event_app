import 'package:flutter/material.dart';
import 'package:uas_event_app/api/api_service.dart';
import 'package:uas_event_app/models/event_model.dart';
import 'package:uas_event_app/screens/profile_screen.dart';
import 'package:uas_event_app/widgets/event_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // Fungsi ini akan dipanggil saat inisialisasi dan saat pull-to-refresh
  Future<void> _fetchEvents() async {
    setState(() {
      _eventsFuture = _apiService.getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Terkini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat event',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terjadi kesalahan saat menghubungi server. Silakan periksa koneksi internet Anda dan tarik ke bawah untuk menyegarkan.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _fetchEvents,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Saat ini belum ada event.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final events = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _fetchEvents,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(event: events[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
