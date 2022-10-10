import 'package:app/src/model/municipality/municipality.dart';

class AutonomousCommunity{
  int id = 0;
  String name;
  String flag = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Flag_of_Andalusia_%28simple%29.svg/1200px-Flag_of_Andalusia_%28simple%29.svg.png";

  AutonomousCommunity({this.id, this.name, this.flag});

  factory AutonomousCommunity.fromJson(Map<String, dynamic> json){
    return AutonomousCommunity(
      id: json['id'] as int,
      name: json['name'] as String,
      flag: json['flag'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "flag": flag,
  };
}