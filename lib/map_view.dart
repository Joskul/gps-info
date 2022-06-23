import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_info/utils/methods.dart';

import 'utils/constants.dart';
import 'utils/coordinates_model.dart';

class MapView extends StatefulWidget {
  const MapView({
    Key? key,
  }) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CoordinateDao().getOnce(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data!.snapshot.value['coordinates']);
          Coordinates coords = Coordinates.fromJson(
              snapshot.data!.snapshot.value['coordinates']);
          final CameraPosition initialLocation = CameraPosition(
              target: LatLng(coords.lat, coords.lng), zoom: 16.0);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: initialLocation,
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
                aspectRatio: 1,
                child: SizedBox(
                    width: 50.0,
                    height: 50,
                    child: const CircularProgressIndicator())),
          );
        }
      },
    );
  }
}
