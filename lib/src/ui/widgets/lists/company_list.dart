import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/model/category.dart';
import 'package:app/src/ui/widgets/items/archive/company_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:flutter/material.dart';

class CompanyList extends StatelessWidget {
  final List<Company> companies;
  final EdgeInsets padding;
  final Category category;

  const CompanyList(
      {Key key,
      this.companies,
      this.padding = const EdgeInsets.all(16),
      this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (companies?.isNotEmpty ?? false)
      return ListView.separated(
        shrinkWrap: true,
        padding: padding,
        itemCount: companies.length,
        itemBuilder: (BuildContext context, int index) {
          return CompanyListItem(
            company: companies[index],
            category: category,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      );

    return EmptyListLayout(
      text: AppLocalizations.of(context).translate("noResult"),
    );
  }
}
