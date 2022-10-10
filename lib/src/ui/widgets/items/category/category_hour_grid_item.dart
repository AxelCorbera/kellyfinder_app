import 'package:app/src/model/category.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CategoryHourGridItem extends StatelessWidget {
  final Category category;
  final Function callback;

  const CategoryHourGridItem({Key key, this.category, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: InkWell(
              onTap: () {
                callback(category);
              },
              child: Image.network(
                category.image,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Container(
          height: 32,
          child: AutoSizeText(
            category.name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            wrapWords: false,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
