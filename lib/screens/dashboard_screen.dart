
import 'package:flutter/material.dart';
import 'package:uas_event_app/api/api_service.dart';
import 'package:uas_event_app/models/event_model.dart';
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
    _eventsFuture = _apiService.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AcaraKita'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada event yang tersedia saat ini.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          if (snapshot.hasData) {
            final List<Event> events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final Event event = events[index];
                return EventCard(event: event);
              },
            );
          }

          return const Center(child: Text("Sesuatu yang aneh terjadi."));
        },
      ),
    );
  }
}