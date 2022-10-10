import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/ui/widgets/lists/archive_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/src/config/string_casing_extension.dart';

class ArchiveListScreen extends StatelessWidget {
  final List<Archive> archives;
  final String title;

  const ArchiveListScreen({Key key, this.archives, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle:true,title: Text(title)),
      body: ArchiveList(archives: archives),
    );
  }
}
