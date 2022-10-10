import 'package:app/src/model/municipality/communique.dart';
import 'package:app/src/model/municipality/municipality.dart';

class MunicipalInfo {
  bool isCreator;
  bool receiveMunicipalInformation;
  int connectedUsers;
  Municipality municipality;
  List<Communique> communiques;

  MunicipalInfo({this.isCreator, this.receiveMunicipalInformation, this.connectedUsers, this.municipality, this.communiques});

  factory MunicipalInfo.fromJson(Map<String, dynamic> json) {
    return MunicipalInfo(
      isCreator: json['municipal-information']['is_creator'] as bool,
      receiveMunicipalInformation: json['municipal-information']['receive_municipal_information'] as bool,
      connectedUsers: json['municipal-information']['connected_users'] as int,
      municipality: Municipality.fromJson(json['municipal-information']['municipality']),
      communiques: json['news'] != null ? json['news']['data'].map<Communique>((it) => Communique.fromJson(it)).toList() : null
    );
  }
}