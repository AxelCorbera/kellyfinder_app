class Event {
  int id;
  String name;
  String link;
  String date;

  Event({this.id, this.name, this.link, this.date});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      name: json['name'] as String,
      link: json['link'] as String,
      date: json['date'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "link": link,
    "date": date
  };
}
