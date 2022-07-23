import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gps_info/routes/splash_screen/splash_screen.dart';
import 'package:gps_info/utils/constants.dart';
import 'package:gps_info/utils/methods.dart';
import 'package:location/location.dart';
import 'firebase_options.dart';

import 'routes/tracker_home/tracker_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: currentMode, // Or [ThemeMode.dark]
            theme: NordTheme.light()
                .copyWith(textTheme: GoogleFonts.poppinsTextTheme()),
            darkTheme: NordTheme.dark().copyWith(
                textTheme: GoogleFonts.poppinsTextTheme()
                    .apply(bodyColor: Colors.white)),
            title: 'Light Up & Locate',
            home: Splash(),
            //home: const TrackerHome(),
          );
        });
  }
}
