import 'dart:convert' show utf8;

class Location {
  int id;
  String name;
  double lat;
  double lon;
  String type;
  String description;
  Location(this.id, this.name, this.lat, this.lon, this.type, this.description);
  factory Location.fromJson(final json) {
    // var encoded = utf8.encode(json["name"]);
    // var decoded = json.decode(utf8.decode(encoded));
    return Location(json["id"], json["name"], json["lat"], json["lon"],
        json["type"], json["description"]);
  }
}
