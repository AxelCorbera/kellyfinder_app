import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/ui/widgets/items/archive/archive_image_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:flutter/material.dart';

class ArchiveImageList extends StatelessWidget {
  final List<Archive> archives;
  final double size;

  const ArchiveImageList({Key key, this.archives, this.size = 52})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (archives?.isNotEmpty ?? false)
      return ListView.separated(
        itemCount: archives.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return ArchiveImageListItem(
            size: size,
            archive: archives[index],
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 12);
        },
      );

    return EmptyListLayout(
      text: AppLocalizations.of(context).translate("noResult"),
    );
  }
}
