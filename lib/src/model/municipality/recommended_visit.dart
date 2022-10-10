class RecommendedVisit {
  int id;
  String name;
  double lat;
  double lng;
  String address;

  RecommendedVisit({this.id, this.name, this.lat, this.lng, this.address});

  factory RecommendedVisit.fromJson(Map<String, dynamic> json) {
    return RecommendedVisit(
      id: json['id'] as int,
      name: json['name'] as String,
      lat: (json['lat'] as num)?.toDouble(),
      lng: (json['lng'] as num)?.toDouble(),
      address: json['direction'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "lat": lat,
    "lng": lng,
    "direction": address,
  };
}