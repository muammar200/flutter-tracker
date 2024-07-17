import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');

  Stream<DatabaseEvent> getUserLocationStream() {
    return _usersRef.onValue;
  }
}
