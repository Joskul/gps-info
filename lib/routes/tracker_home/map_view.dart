import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gps_info/utils/marker_icon_generator.dart';
import 'package:gps_info/utils/methods.dart';
import 'package:location/location.dart';

import '../../utils/constants.dart';
import '../../utils/coordinates_model.dart';

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

  late BitmapDescriptor userIcon;
  late BitmapDescriptor trackerIcon;

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
      _serviceEnabled = await userLocation.serviceEnabled();
      if (!_serviceEnabled) {
        //_serviceEnabled = await userLocation.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await userLocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        //_permissionGranted = await userLocation.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      // Track user Movements
      userLocation.onLocationChanged.listen((res) {
        setState(() {
          userCoords = Coordinates(res.latitude!, res.longitude!, res.speed!);
        });
      });
    }

    setMarkerIcons() async {
      double size = MediaQuery.of(context).size.height *
          MediaQuery.of(context).size.height /
          (1920 * 1080);
      userIcon = await MarkerGenerator(size * 100)
          .createBitmapDescriptorFromIconData(
              Icons.supervised_user_circle,
              Colors.lightBlue,
              Colors.lightBlue,
              Colors.lightBlue.withAlpha(64));

      trackerIcon = await MarkerGenerator(size * 100)
          .createBitmapDescriptorFromIconData(Icons.accessibility_new,
              Colors.red, Colors.red, Colors.red.withAlpha(64));
    }

    setMarkerIcons();

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
              icon: trackerIcon,
            ),
          );
          userCoords != null
              ? markers.add(
                  Marker(
                      markerId: const MarkerId("User"),
                      position: LatLng(userCoords!.lat, userCoords!.lng),
                      icon: userIcon),
                )
              : 0;

          circles.clear();

          circles.add(
            Circle(
                circleId: const CircleId("Help"),
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
