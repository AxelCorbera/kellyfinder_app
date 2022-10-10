import 'package:app/src/model/category.dart';
import 'package:app/src/ui/widgets/items/category/category_hour_grid_item.dart';
import 'package:flutter/material.dart';

class CategoryHourGrid extends StatelessWidget {
  final List<Category> categories;
  final Function callback;

  const CategoryHourGrid({Key key, this.categories, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).disabledColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return CategoryHourGridItem(
            category: categories[index],
            callback: callback,
          );
        },
      ),
    );
  }
}
