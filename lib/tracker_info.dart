import 'package:flutter/material.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:gps_info/utils/coordinates_model.dart';
import 'package:gps_info/utils/methods.dart';
import 'utils/constants.dart';

class TrackerInfo extends StatefulWidget {
  const TrackerInfo({
    Key? key,
  }) : super(key: key);

  @override
  State<TrackerInfo> createState() => _TrackerInfoState();
}

class _TrackerInfoState extends State<TrackerInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const InfoBanner(),
        AreaInfoStream(title: 'Latitude', text: 'lat'),
        AreaInfoStream(title: 'Longitude', text: 'lng'),
        const AreaInfoText(title: "Speed", text: "0.03 km/h"),
        const AreaInfoText(
            title: "Distance from current Location", text: "20 m"),
      ],
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('wave.gif', fit: BoxFit.cover),
            Container(color: Theme.of(context).backgroundColor.withAlpha(128)),
            Padding(
              padding: const EdgeInsets.all(defaultPadding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tracker Info",
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AreaInfoText extends StatelessWidget {
  final String title, text;
  const AreaInfoText({Key? key, required this.title, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(text, style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

class AreaInfoStream extends StatelessWidget {
  final coordsDao = CoordsMethods();
  final String title, text;
  AreaInfoStream({Key? key, required this.title, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          FirebaseAnimatedList(
            query: coordsDao.getCoordsQuery(),
            itemBuilder: (context, snapshot, animation, index) {
              final json = snapshot.value as Map<dynamic, dynamic>;
              final coords = Coordinates.fromJson(json);
              return Text(coords.data[text].toString());
            },
          ),
        ],
      ),
    );
  }
}
