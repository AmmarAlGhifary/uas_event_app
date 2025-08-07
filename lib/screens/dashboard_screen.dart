import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uas_event_app/api/api_service.dart';
import 'package:uas_event_app/models/event_model.dart';
import 'package:uas_event_app/screens/event_details_screen.dart';
import 'package:uas_event_app/screens/profile_screen.dart';
import 'package:uas_event_app/widgets/event_card.dart';
import 'package:uas_event_app/screens/create_event_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Event> _allEvents = [];
  List<Event> _displayedEvents = [];
  Set<int> _registeredEventIds = {};

  bool _isLoading = true;
  String? _errorMessage;

  String _activeFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterEvents);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    final savedIds = await _apiService.getSavedRegisteredEventIds();
    if (mounted) {
      setState(() {
        _registeredEventIds = savedIds;
      });
    }
    await _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (_allEvents.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _apiService.getEvents(),
        _apiService.getMyRegisteredEvents(),
      ]);

      final allEvents = results[0];
      final registeredEvents = results[1];

      final registeredIds = registeredEvents.map((event) => event.id).toSet();

      if (mounted) {
        setState(() {
          _allEvents = allEvents;
          _registeredEventIds = registeredIds;

          _isLoading = false;
        });
        _filterEvents();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    List<Event> filtered;

    if (_activeFilter == 'Semua') {
      filtered = List.from(_allEvents);
    } else {
      filtered = _allEvents
          .where((event) => _getEventStatus(event) == _activeFilter)
          .toList();
    }

    if (query.isNotEmpty) {
      filtered = filtered
          .where((event) => event.title.toLowerCase().contains(query))
          .toList();
    }

    setState(() {
      _displayedEvents = filtered;
    });
  }

  String _getEventStatus(Event event) {
    try {
      final now = DateTime.now();
      final startDate = DateTime.parse(event.startDate);
      final today = DateTime(now.year, now.month, now.day);
      final eventDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      if (eventDate.isAtSameMomentAs(today)) return 'Hari Ini';
      if (eventDate.isAfter(today)) return 'Akan Datang';
      return 'Selesai';
    } catch (_) {
      return 'Selesai';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AcaraKita'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bool? shouldRefresh = await Navigator.of(context).push<bool>( // <-- Tangkap hasil
            MaterialPageRoute(
              builder: (context) => const CreateEventScreen(),
            ),
          );
          if(shouldRefresh == true) {
            _fetchEvents();
          }
        },
        tooltip: 'Buat Event Baru',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari event...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // Filter chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['Semua', 'Akan Datang', 'Hari Ini', 'Selesai']
                    .map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: _activeFilter == status,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _activeFilter = status;
                              });
                              _filterEvents();
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, color: Colors.grey, size: 60),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Data',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_allEvents.isEmpty) {
      return const Center(child: Text('Saat ini belum ada event.'));
    }

    if (_displayedEvents.isEmpty) {
      return const Center(
        child: Text('Tidak ada event yang cocok dengan filter Anda.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _displayedEvents.length,
      itemBuilder: (context, index) {
        final event = _displayedEvents[index];
        final isRegistered = _registeredEventIds.contains(event.id);
        return EventCard(
          event: event,
          isRegistered: isRegistered,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );
            _fetchEvents();
          },
        );
      },
    );
  }
}
