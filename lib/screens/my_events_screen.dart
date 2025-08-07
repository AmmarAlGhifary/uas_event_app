// lib/screens/my_events_screen.dart

import 'package:flutter/material.dart';
import 'package:uas_event_app/api/api_service.dart';
import 'package:uas_event_app/models/event_model.dart';
import 'package:uas_event_app/screens/event_details_screen.dart';
import 'package:uas_event_app/widgets/event_card.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final ApiService _apiService = ApiService();

  List<Event> _attendedEvents = [];
  bool _isLoadingAttended = true;
  String? _errorAttended;

  List<Event> _createdEvents = [];
  bool _isLoadingCreated = true;
  String? _errorCreated;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingAttended = true;
      _isLoadingCreated = true;
    });

    try {
      final results = await Future.wait([
        _apiService.getMyRegisteredEvents(),
        _apiService.getCreatedEvents(),
      ]);

      if (mounted) {
        setState(() {
          _attendedEvents = results[0];
          _isLoadingAttended = false;

          _createdEvents = results[1];
          _isLoadingCreated = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorAttended = 'Gagal memuat event yang diikuti.';
          _isLoadingAttended = false;
          _errorCreated = 'Gagal memuat event yang dibuat.';
          _isLoadingCreated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Saya'),
          bottom: const TabBar(
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'DIIKUTI'),
              Tab(text: 'DIBUAT'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadAllData,
          child: TabBarView(
            children: [
              _buildEventList(
                isLoading: _isLoadingAttended,
                error: _errorAttended,
                events: _attendedEvents,
                emptyMessage: 'Anda belum mengikuti event apapun.',
                isAttendedList: true,
              ),
              _buildEventList(
                isLoading: _isLoadingCreated,
                error: _errorCreated,
                events: _createdEvents,
                emptyMessage: 'Anda belum membuat event apapun.',
                isAttendedList: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList({
    required bool isLoading,
    required String? error,
    required List<Event> events,
    required String emptyMessage,
    required bool isAttendedList,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error));
    }

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          isRegistered: isAttendedList,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );
            _loadAllData();
          },
        );
      },
    );
  }
}