import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';

import 'coordinates_model.dart';

Location userLocation = Location();

class CoordinateDao {
  final DatabaseReference _coordsRef = FirebaseDatabase.instance.ref();

  Query getCoordinatesQuery() {
    return _coordsRef;
  }

  Future<Coordinates> getCoords() async {
    final snapshot = await _coordsRef.get();
    return snapshot.value as Coordinates;
  }

  Future<DatabaseEvent> getOnce() async {
    final snapshot = await _coordsRef.once();
    return snapshot;
  }

  DatabaseReference getRef() {
    return _coordsRef;
  }
}
