import 'package:app/src/model/support/conversion.dart';
import 'package:app/src/provider/category_notifier.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  int id;
  String name;
  @JsonKey(fromJson: Conversion.stringToColor, toJson: Conversion.colorToString)
  Color color;
  @JsonKey(name: "pic")
  String image;
  @JsonKey(name: "header_pic")
  String header;
  @JsonKey(name: "parent", toJson: Conversion.objectToJson)
  Category parentCategory;
  @JsonKey(name: "has_sons", fromJson: Conversion.intToBool)
  bool hasChild;
  String type;
  String description;
  @JsonKey(name: "can_advertise", fromJson: Conversion.intToBool)
  bool canAdvertise;
  @JsonKey(name: "sector_pic")
  String sector;

  Category(
    this.id,
    this.name,
    this.color,
    this.image,
    this.parentCategory,
    this.hasChild,
    this.type,
    this.header,
    this.description,
    this.canAdvertise,
    this.sector,
  );

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  String get hasParent => parentCategory != null
      ? "${parentCategory.hasParent + " - " + name}"
      : "";

  String get hasAdvertiseParent => this.canAdvertise ?? false
      ? "${parentCategory.hasParent + " - " + name}"
      : parentCategory?.hasAdvertiseParent;

  Category get getParent =>
      parentCategory != null ? parentCategory.getParent : this;

  Category get advertiseCat =>
      canAdvertise ? this : parentCategory?.advertiseCat;

  String get findSectorPic =>
      this.hasSector ? this.sector : parentCategory?.findSectorPic;

  bool get hasHeader => header != null;

  bool get hasSector => sector != null;

  bool get isDifferent =>
      type != "shared" && type != "delivery" && type != "24h";

  String sharedText(BuildContext context) {
    Category category = Provider.of<CategoryNotifier>(context, listen: false)
        .selectedSubcategory;

    bool exit = false;

    Category lastCategory = category;
    Category tempCategory;

    while (!exit) {
      if (lastCategory.parentCategory != null) {
        tempCategory = lastCategory;
        lastCategory = lastCategory.parentCategory;
      } else {
        exit = true;
      }
    }

    if (tempCategory.type == "search") {
      return "Busco";
    } else if (tempCategory.type == "have") {
      return "Tengo";
    } else {
      return "Comparto";
    }
  }
}
