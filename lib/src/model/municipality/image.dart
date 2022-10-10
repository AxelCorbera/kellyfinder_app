class MunicipalityImage {
  int id;
  dynamic pic;

  MunicipalityImage({this.id, this.pic});

  factory MunicipalityImage.fromJson(Map<String, dynamic> json) {
    return MunicipalityImage(
      id: json['id'] as int,
      pic: json['pic_url'] as String
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pic': pic
  };
}