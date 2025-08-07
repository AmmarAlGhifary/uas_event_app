
class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final int registrationsCount;
  final int availableSpots;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.registrationsCount,
    required this.availableSpots,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      location: json['location'] ?? 'No Location',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      registrationsCount: json['registrations_count'] ?? 0,
      availableSpots: json['available_spots'] ?? 0,
    );
  }
}
