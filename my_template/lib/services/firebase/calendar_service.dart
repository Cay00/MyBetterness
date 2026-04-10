import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_template/models/calendar_event.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference get _eventsRef {
    if (_uid == null) throw Exception("Brak zalogowanego użytkownika");
    return _firestore.collection('users').doc(_uid).collection('events');
  }

  Future<void> addEvent(CalendarEvent event) async {
    await _eventsRef.add(event.toMap());
  }

  Stream<List<CalendarEvent>> getUserEvents() {
    if (_uid == null) return Stream.value([]);

    return _eventsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CalendarEvent.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsRef.doc(eventId).delete();
  }
}
