class IndustrialParkCategory {
  int id;
  String name;
  String image;
  int order;

  IndustrialParkCategory({this.id, this.name, this.image, this.order});

  factory IndustrialParkCategory.fromJson(Map<String, dynamic> json) {
    return IndustrialParkCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['pic_url'] as String,
      order: json['order'] as int
    );
  }

  Map<String, dynamic> toJson() =>
      {"id": id, "name": name, "image": image, "order": order};
}