import 'package:flutter/material.dart';
import 'package:gps_info/routes/tracker_home/tracker_home.dart';
import 'package:gps_info/utils/constants.dart';

import '../../main.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        return Scaffold(
          floatingActionButton: IconButton(
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
          body: ListView(
            children: [
              SplashBanner(constraints: constraints),
            ],
          ),
        );
      }),
    );
  }
}

class SplashBanner extends StatelessWidget {
  final BoxConstraints constraints;
  const SplashBanner({
    Key? key,
    required this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/wave.gif",
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
                colors: [Theme.of(context).canvasColor, Colors.transparent],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: Theme.of(context).textTheme.headline1!.fontSize,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  Text(
                    "LightUp & Locate",
                    style: Theme.of(context).textTheme.headline1!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TrackerHome()));
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * 2,
                    vertical: defaultPadding * 2,
                  ),
                ),
                child: Text(
                  style: Theme.of(context).textTheme.headline5!,
                  "Get Started",
                ),
              ),
              const Spacer(flex: 3),
              Image.network("assets/arrow.gif", scale: 2.0),
            ],
          )
        ],
      ),
    );
  }
}
