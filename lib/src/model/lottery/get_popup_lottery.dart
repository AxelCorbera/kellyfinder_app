// To parse this JSON data, do
//
//     final getPopupLottery = getPopupLotteryFromJson(jsonString);

import 'dart:convert';

GetPopupLottery getPopupLotteryFromJson(String str) => GetPopupLottery.fromJson(json.decode(str));

String getPopupLotteryToJson(GetPopupLottery data) => json.encode(data.toJson());

class GetPopupLottery {
  GetPopupLottery({
    this.subject,
    this.text,
    this.code,
    this.activarCodeFlutter,
    this.footer,
    this.fechaFinalizacionEmail,
    this.activarEmail,
    this.activarPopup,
    this.fechaFinalizacionPopup,
  });

  String subject;
  String text;
  String code;
  int activarCodeFlutter;
  String footer;
  String fechaFinalizacionEmail;
  int activarEmail;
  int activarPopup;
  String fechaFinalizacionPopup;

  factory GetPopupLottery.fromJson(Map<String, dynamic> json) => GetPopupLottery(
    subject: json["subject"],
    text: json["text"],
    code: json["code"],
    activarCodeFlutter: json["activar_code_flutter"],
    footer: json["footer"],
    fechaFinalizacionEmail: json["fecha_finalizacion_email"],
    activarEmail: json["activar_email"],
    activarPopup: json["activar_popup"],
    fechaFinalizacionPopup: json["fecha_finalizacion_popup"],
  );

  Map<String, dynamic> toJson() => {
    "subject": subject,
    "text": text,
    "code": code,
    "activar_code_flutter": activarCodeFlutter,
    "footer": footer,
    "fecha_finalizacion_email": fechaFinalizacionEmail,
    "activar_email": activarEmail,
    "activar_popup": activarPopup,
    "fecha_finalizacion_popup": fechaFinalizacionPopup,
  };
}
