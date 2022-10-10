import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/ui/widgets/items/archive/archive_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:flutter/material.dart';

class ArchiveList extends StatelessWidget {
  final List<Archive> archives;
  final EdgeInsets padding;

  const ArchiveList(
      {Key key, this.archives, this.padding = const EdgeInsets.all(0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (archives?.isNotEmpty ?? false)
      return ListView.separated(
        padding: padding,
        itemCount: archives.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return ArchiveListItem(archive: archives[index]);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
      );

    return EmptyListLayout(
      text: AppLocalizations.of(context).translate("noResult_archives"),
    );
  }
}
