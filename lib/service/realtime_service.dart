import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class RealtimeDatabaseService {
  final DatabaseReference _locationsRef =
      FirebaseDatabase.instance.ref().child('locations');
  final String _documentId = 'currentLocation';

  Stream<DatabaseEvent> getLocationStream() {
    return _locationsRef.child(_documentId).onValue;
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _locationsRef.child(_documentId).set({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getCurrentLocationAndSave() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await updateLocation(position.latitude, position.longitude);
  }
}
