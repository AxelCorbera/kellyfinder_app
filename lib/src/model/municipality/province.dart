class Province{
  int id = 0;
  String name;
  String flag;
  int communityId;

  Province({this.id, this.name, this.flag, this.communityId});

  factory Province.fromJson(Map<String, dynamic> json){
    return Province(
      id: json['id'] as int,
      name: json['name'] as String,
      flag: json['flag'] as String,
      communityId: json['community_id'] as int
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "flag": flag,
    "community_id": communityId
  };
}