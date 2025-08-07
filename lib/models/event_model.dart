class Creator {
  final int id;
  final String name;
  final String studentNumber;

  Creator({
    required this.id,
    required this.name,
    required this.studentNumber,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Creator',
      studentNumber: json['student_number'] ?? 'N/A',
    );
  }
}

class Event {
  final int id;
  final String title;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final int registrationsCount;
  final int availableSpots;
  final Creator creator;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.registrationsCount,
    required this.availableSpots,
    required this.creator,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final defaultCreator = Creator(id: 0, name: 'Unknown', studentNumber: '');

    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      location: json['location'] ?? 'No Location',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      registrationsCount: json['registrations_count'] ?? 0,
      availableSpots: json['available_spots'] ?? 0,
      creator: json['creator'] != null
          ? Creator.fromJson(json['creator'])
          : defaultCreator,
    );
  }
}