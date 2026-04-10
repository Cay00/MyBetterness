import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String category;

  CalendarEvent({
    this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'category': category,
    };
  }

  factory CalendarEvent.fromMap(String id, Map<String, dynamic> map) {
    return CalendarEvent(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      category: map['category'] ?? 'Doctor',
    );
  }
}
