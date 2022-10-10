class Communique {
  int id;
  String media;
  String description;
  String date;
  String type;

  Communique({this.id, this.media, this.description, this.date, this.type});

  factory Communique.fromJson(Map<String, dynamic> json) {
    return Communique(
      id: json['id'] as int,
      media: json['media'] as String,
      description: json['description'] as String,
      date: json['day'] as String,
      type: json['type'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "media": media,
    "description": description,
    "date": date,
    "type": type
  };
}