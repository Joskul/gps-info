// Set these to run example.
#define FIREBASE_HOST ""
#define FIREBASE_AUTH ""
#define PROJECT_ID ""
#define WIFI_SSID "SSID"
#define WIFI_PASSWORD "PASSWORD"

#include "SoftwareSerial.h"
SoftwareSerial GPSModule(2, 0); // TX, RX

String nmea[15];
//String labels[12] {"Time: ", "Status: ", "Latitude: ", "Hemisphere: ", "Longitude: ", "Hemisphere: ", "Speed: ", "Track Angle: ", "Date: "};

#include <Arduino.h>
#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>

//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Insert Firebase project API Key
#define API_KEY ""

// Insert RTDB URLefine the RTDB URL */
#define DATABASE_URL ""

//Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
int count = 0;
bool signupOK = false;

void setup() {
  GPSModule.begin(9600);
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  }
  else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  updateGPS();
//  Serial.print("Lat: ");
//  Serial.println(nmea[2]);
//  Serial.print("Lng: ");
//  Serial.println(nmea[4]);
//  Serial.print("Spd: ");
//  Serial.println(nmea[6]);
//  Serial.print("Time: ");
//  Serial.println(nmea[0]);

  if (
    rtdbPostDouble("coordinates/spd", nmea[6].toDouble()) &&
    rtdbPostDouble("coordinates/lat", nmea[2].toDouble()) &&
    rtdbPostDouble("coordinates/lng", nmea[4].toDouble()) ) {
    rtdbPostString("time", nmea[0] + " , " + nmea[8]);
  }
}

bool rtdbPostDouble(String path, double val) {
  if (val == 0) {
    Serial.println("Invalid Value!");
    return false;
  }

  if (Firebase.RTDB.setFloat(&fbdo, path, val)) {
    Serial.println("PASSED");
    Serial.println("PATH: " + fbdo.dataPath());
    Serial.println("TYPE: " + fbdo.dataType());
    return true;
  }
  else {
    Serial.println("FAILED");
    Serial.println("REASON: " + fbdo.errorReason());
    return false;
  }
}

bool rtdbPostString(String path, String val) {
  if (Firebase.RTDB.setString(&fbdo, path, val)) {
    Serial.println("PASSED");
    Serial.println("PATH: " + fbdo.dataPath());
    Serial.println("TYPE: " + fbdo.dataType());
    return true;
  }
  else {
    Serial.println("FAILED");
    Serial.println("REASON: " + fbdo.errorReason());
    return false;
  }
}

void updateGPS() {
  int pos;
  int stringplace = 0;

  Serial.flush();
  GPSModule.flush();
  while (GPSModule.available() > 0)
  {
    GPSModule.read();
  }
  if (GPSModule.find("$GPRMC,")) {
    String tempMsg = GPSModule.readStringUntil('\n');
    for (int i = 0; i < tempMsg.length(); i++) {
      if (tempMsg.substring(i, i + 1) == ",") {
        nmea[pos] = tempMsg.substring(stringplace, i);
        stringplace = i + 1;
        pos++;
      }
      if (i == tempMsg.length() - 1) {
        nmea[pos] = tempMsg.substring(stringplace, i);
      }
    }
    nmea[2] = ConvertLat(nmea);
    nmea[4] = ConvertLng(nmea);
    //    for (int i = 0; i < 9; i++) {
    //      Serial.print(labels[i]);
    //      Serial.print(nmea[i]);
    //      Serial.println("");
    //    }

  }
  stringplace = 0;
  pos = 0;
}

String ConvertLat(String* nmea) {
  String posneg = "";
  if (nmea[3] == "S") {
    posneg = "-";
  }
  String latfirst;
  float latsecond;
  for (int i = 0; i < nmea[2].length(); i++) {
    if (nmea[2].substring(i, i + 1) == ".") {
      latfirst = nmea[2].substring(0, i - 2);
      latsecond = nmea[2].substring(i - 2).toFloat();
    }
  }
  latsecond = latsecond / 60;
  String CalcLat = "";

  char charVal[9];
  dtostrf(latsecond, 4, 6, charVal);
  for (int i = 0; i < sizeof(charVal); i++)
  {
    CalcLat += charVal[i];
  }
  latfirst += CalcLat.substring(1);
  latfirst = posneg += latfirst;
  return latfirst;
}

String ConvertLng(String* nmea) {
  String posneg = "";
  if (nmea[5] == "W") {
    posneg = "-";
  }

  String lngfirst;
  float lngsecond;
  for (int i = 0; i < nmea[4].length(); i++) {
    if (nmea[4].substring(i, i + 1) == ".") {
      lngfirst = nmea[4].substring(0, i - 2);
      //Serial.println(lngfirst);
      lngsecond = nmea[4].substring(i - 2).toFloat();
      //Serial.println(lngsecond);

    }
  }
  lngsecond = lngsecond / 60;
  String CalcLng = "";
  char charVal[9];
  dtostrf(lngsecond, 4, 6, charVal);
  for (int i = 0; i < sizeof(charVal); i++)
  {
    CalcLng += charVal[i];
  }
  lngfirst += CalcLng.substring(1);
  lngfirst = posneg += lngfirst;
  return lngfirst;
}
