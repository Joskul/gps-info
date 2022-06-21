import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'utils/constants.dart';

class MapView extends StatelessWidget {
  const MapView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialLocation = CameraPosition(
        target: LatLng(37.42796133580664, -122.085749655962), zoom: 14.4746);

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
  }
}
