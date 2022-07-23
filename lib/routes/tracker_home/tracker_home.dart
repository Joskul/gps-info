import 'package:flutter/material.dart';
import 'package:gps_info/main.dart';
import 'package:gps_info/routes/tracker_home/map_view.dart';
import 'package:gps_info/routes/tracker_home/tracker_info.dart';
import 'package:gps_info/utils/constants.dart';
import 'package:gps_info/utils/methods.dart';
import 'package:location/location.dart';

class TrackerHome extends StatelessWidget {
  const TrackerHome({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: const Text('Track Me!'),
        actions: [
          IconButton(
            icon: Icon(MyApp.themeNotifier.value == ThemeMode.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              MyApp.themeNotifier.value =
                  MyApp.themeNotifier.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light;
            },
          ),
          IconButton(
              onPressed: () async {
                bool serviceEnabled = await userLocation.serviceEnabled();
                if (!serviceEnabled) {
                  serviceEnabled = await userLocation.requestService();
                  if (!serviceEnabled) {
                    return;
                  }
                }

                PermissionStatus permissionGranted =
                    await userLocation.hasPermission();
                if (permissionGranted == PermissionStatus.denied) {
                  permissionGranted = await userLocation.requestPermission();
                  if (permissionGranted != PermissionStatus.granted) {
                    return;
                  }
                }
              },
              icon: Icon(Icons.location_searching_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return MobileBody();
              } else {
                return DesktopBody();
              }
            }),
          ),
        ),
      ),
    );
  }
}

class MobileBody extends StatelessWidget {
  const MobileBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 2, child: MapView()),
        Expanded(
          flex: 2,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.headline6!,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding),
              child: SingleChildScrollView(
                child: TrackerInfo(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DesktopBody extends StatelessWidget {
  const DesktopBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 4, child: MapView()),
        Expanded(
          flex: 2,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.headline6!,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding),
              child: SingleChildScrollView(
                child: TrackerInfo(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
