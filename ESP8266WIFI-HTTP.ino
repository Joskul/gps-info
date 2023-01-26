bool getPosition(void) ;
void serialFlush(void) ;
#include <SoftwareSerial.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClient.h>

SoftwareSerial GPS(4, 5); // RX, TX
float latitude, longitude, speed;

ESP8266WiFiMulti WiFiMulti;

void setup() {
  Serial.begin(115200);
  GPS.begin(9600);

  WiFiMulti.addAP("projectteam","88888888");
}

void loop() {
  Serial.println("-------------------------------------------------");
  Serial.println("001");
  // get GPS 
  if (getPosition()) {
    Serial.print(latitude, 6);
    Serial.print(",");
    Serial.print(longitude, 6);
    Serial.print(" | Speed (Km) : ");
    Serial.print(speed, 2);
    Serial.println();
    delay(5000);
  }

  // send data to php
  Serial.println("connecting wifi");
  if(WiFiMulti.run() == WL_CONNECTED) {
    Serial.println("wifi connected");

    WiFiClient client;
    HTTPClient http;

    if(latitude > 0.0) { 
      //Serial.println("http://192.168.43.133/CRU/insert_gps.php?gps_no=001&latitude="+String(latitude,6)+"&longitude="+String(longitude,6));
      Serial.println("http://www.iotchonburi.com/cru/insert_gps.php?gps_no=001&latitude="+String(latitude,6)+"&longitude="+String(longitude,6));
      if(http.begin(client, "http://www.iotchonburi.com/cru/insert_gps.php?gps_no=003&latitude="+String(latitude,6)+"&longitude="+String(longitude,6))) {
        int httpCode = http.GET();
        if(httpCode == HTTP_CODE_OK) {
          String results = http.getString();
          Serial.println(results);
          
        }
      }
    }
  }


  delay(1000);
}

bool getPosition() {

    Serial.println("connecting gps");
    if (GPS.available()) {
      Serial.println("gps connected");
      String line = "";
      while(GPS.available()) {
        char c = GPS.read();
        if (c == '\r') {
          if (line.indexOf("$GPRMC") >= 0) {
            Serial.println(line);
            String dataCut[13];
            int index = 0;
            for (int dataStart=0;dataStart<line.length();) {
              dataCut[index] = line.substring(dataStart+1, line.indexOf(',', dataStart+1));
              // Serial.println(dataCut[index]);
              dataStart = line.indexOf(',', dataStart+1);
              index++;
            }
            Serial.println("dataCut[2] = "+dataCut[2]);
            if (dataCut[2] == "A") {
              int dotPos = 0;
              dotPos = dataCut[3].indexOf('.');
              String latDeg = dataCut[3].substring(0, dotPos-2);
              String latMin = dataCut[3].substring(dotPos-2, dotPos+10);
              dotPos = dataCut[5].indexOf('.');
              String lngDeg = dataCut[5].substring(0, dotPos-2);
              String lngMin = dataCut[5].substring(dotPos-2, dotPos+10);
              latitude = (latDeg.toFloat() + (latMin.toFloat() / 60.0)) * (dataCut[4] == "N" ? 1 : -1);
              longitude = (lngDeg.toFloat() + (lngMin.toFloat() / 60.0)) * (dataCut[6] == "E" ? 1 : -1);
              speed = dataCut[7].toFloat() * 1.652;
              return true;
            } else {
              Serial.println("Error : No fix now.");
            }
            serialFlush();
          }
          line = "";
        } else if (c == '\n') {
          // pass
        } else {
          line += c;
        }
        delay(1);
      }
    }

  return false;
}

void serialFlush() {
  while(Serial.available()) 
    Serial.read();
}
