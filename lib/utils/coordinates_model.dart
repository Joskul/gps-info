class Coordinates {
  final double lat;
  final double lng;
  final double spd;

  Coordinates(this.lat, this.lng, this.spd);

  Coordinates.fromJson(Map<dynamic, dynamic> json)
      : lat = json['lat'] as double,
        lng = json['lng'] as double,
        spd = json['spd'] as double;

  Map<dynamic, dynamic> getList() {
    return {'lat': lat, 'lng': lng, 'spd': spd};
  }
}
