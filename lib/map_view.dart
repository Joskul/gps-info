import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_info/utils/methods.dart';
import 'package:location/location.dart';

import 'utils/constants.dart';
import 'utils/coordinates_model.dart';

class MapView extends StatelessWidget {
  const MapView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: CoordinateDao().getOnce(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          //print(snapshot.data!.snapshot.value['coordinates']);
          Coordinates coords = Coordinates.fromJson(
              snapshot.data!.snapshot.value['coordinates']);

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: MapElement(coords: coords),
          );
        } else {
          return const Center(
            child: SizedBox(
                height: 50, width: 50, child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class MapElement extends StatefulWidget {
  const MapElement({
    Key? key,
    required this.coords,
  }) : super(key: key);

  final Coordinates coords;

  @override
  State<MapElement> createState() => _MapElementState();
}

class _MapElementState extends State<MapElement> {
  late Marker marker;
  late Circle circle;
  late GoogleMapController _controller;

  late CameraPosition initialLocation = CameraPosition(
      target: LatLng(widget.coords.lat, widget.coords.lng), zoom: 18.0);
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: initialLocation,
      markers: {
        Marker(
            markerId: MarkerId("Help"),
            position: LatLng(widget.coords.lat, widget.coords.lng))
      },
      // circles: Set.of((circle != null) ? [circle] : []),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      compassEnabled: true,
    );
  }
}
