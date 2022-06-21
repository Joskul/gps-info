class Coordinates {
  Map<dynamic, dynamic> data = {
    'lat': 0,
    'lng': 0,
    'spd': 0,
  };

  Coordinates(this.data);

  Coordinates.fromJson(Map<dynamic, dynamic> json) : data = json;

  Map<dynamic, dynamic> toJson() => data;
}
