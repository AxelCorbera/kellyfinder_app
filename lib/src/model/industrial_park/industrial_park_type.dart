class IndustrialParkType {
  int id;
  String name;

  IndustrialParkType({this.id, this.name});

  factory IndustrialParkType.fromJson(Map<String, dynamic> json) {
    return IndustrialParkType(
      id: json['id'] as int,
      name: json['name'] as String
    );
  }

}