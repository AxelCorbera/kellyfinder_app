class Service {
  final String slug;
  final String name;
  final List<ServiceCategory> categories;
  final String image;

  Service({this.slug, this.name, this.categories, this.image});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
        slug: json['slug'] as String,
        name: json['name'] as String,
        categories: json['categories']
            .map<ServiceCategory>((it) => ServiceCategory.fromJson(it))
            .toList(),
        image: json['pic_url'] as String);
  }

  Map<String, dynamic> toJson() =>
      {"slug": slug, "name": name, "categories": categories, "image": image};
}

class ServiceCategory {
  final int id;
  final String name;
  final String slug;
  final String image;
  int companyNumber = 0;

  ServiceCategory({this.id, this.name, this.slug, this.image});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
        id: json['id'] as int,
        slug: json['slug'] as String,
        name: json['name'] as String,
        image: json['pic_url'] as String);
  }

  Map<String, dynamic> toJson() =>
      {"id": id, "slug": slug, "name": name, "image": image};
}
