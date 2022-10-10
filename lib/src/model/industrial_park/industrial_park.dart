import 'package:app/src/model/industrial_park/industrial_park_type.dart';
import 'package:app/src/model/municipality/municipality.dart';

class IndustrialPark {
  int id;
  String name;
  double lat;
  double lng;
  double distance;
  IndustrialParkType type;
  Municipality municipality;

  IndustrialPark({
    this.id,
    this.name,
    this.lat,
    this.lng,
    this.distance,
    this.type,
    this.municipality
  });

  factory IndustrialPark.fromJson(Map<String, dynamic> json) {
    return IndustrialPark(
      id: json['id'] as int,
      name: json['name'] as String,
      lat: (json['lat'] as num)?.toDouble(),
      lng: (json['lng'] as num)?.toDouble(),
      distance: json["distance"] != null ? double.tryParse(json["distance"].toString()) : null,
      type: json['type'] != null ? IndustrialParkType.fromJson(json['type']) : null,
      municipality: Municipality.fromJson(json['municipality'])
    );
  }
}
