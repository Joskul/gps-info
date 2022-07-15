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
  Set<Marker> markers = Set();
  Set<Circle> circles = Set();
  GoogleMapController? _controller = null;
  late Coordinates? userCoords = null;

  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  late CameraPosition initialLocation = CameraPosition(
      target: LatLng(widget.coords.lat, widget.coords.lng), zoom: 18.0);
  @override
  Widget build(BuildContext context) {
    markers = {
      Marker(
        markerId: const MarkerId("Help"),
        position: LatLng(widget.coords.lat, widget.coords.lng),
      ),
    };

    _locateMe() async {
      // Track user Movements
      location.onLocationChanged.listen((res) {
        setState(() {
          userCoords = Coordinates(res.latitude!, res.longitude!, res.speed!);
        });
      });
    }

    return SafeArea(
      child: StreamBuilder(
        stream: CoordinateDao().getRef().child("coordinates").onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                  height: 50, width: 50, child: CircularProgressIndicator()),
            );
          }

          _locateMe();

          DatabaseEvent event = snapshot.data as DatabaseEvent;
          Coordinates currentCoords = Coordinates.fromJson(
              event.snapshot.value as Map<dynamic, dynamic>);

          markers.clear();

          final latLng = LatLng(currentCoords.lat, currentCoords.lng);

          // Add new marker with markerId.
          markers.add(
            Marker(
              markerId: const MarkerId("Help"),
              position: latLng,
            ),
          );
          userCoords != null
              ? markers.add(
                  Marker(
                      markerId: const MarkerId("User"),
                      position: LatLng(userCoords!.lat, userCoords!.lng)),
                )
              : 0;

          circles.clear();

          circles.add(
            Circle(
                circleId: const CircleId("User"),
                center: latLng,
                radius: 50,
                strokeWidth: 2,
                fillColor: Colors.green.withAlpha(64),
                strokeColor: Colors.green.withAlpha(128)),
          );

          // If google map is already created then update camera position with animation
          // if (_controller != null) {
          //   _controller?.animateCamera(
          //     CameraUpdate.newCameraPosition(
          //       CameraPosition(
          //         target: LatLng(currentCoords.lat, currentCoords.lng),
          //         zoom: 18.0,
          //       ),
          //     ),
          //   );
          // }

          return GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: initialLocation,
            markers: markers,
            circles: circles,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            compassEnabled: true,
          );
        },
      ),
    );
  }
}
