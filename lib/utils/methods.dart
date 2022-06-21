import 'package:firebase_database/firebase_database.dart';

import 'coordinates_model.dart';

class CoordsMethods {
  final DatabaseReference _coordsRef =
      FirebaseDatabase.instance.ref().child('coordinates');

  Query getCoordsQuery() {
    return _coordsRef;
  }
}
