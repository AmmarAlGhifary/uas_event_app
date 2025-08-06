
class Event {
  final int id;
  final String title;
  final String description;
  final String startDate;
  final String location;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.location,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: json['start_date'],
      location: json['location'],
    );
  }
}