import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/petition.dart';
import 'package:app/src/provider/socket_notifier.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/items/petition_list_item.dart';
import 'package:app/src/ui/widgets/layout/empty_list_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class PetitionList extends StatefulWidget {
  final List<Petition> petitions;

  const PetitionList({Key key, this.petitions}) : super(key: key);

  @override
  _PetitionListState createState() => _PetitionListState();
}

class _PetitionListState extends State<PetitionList> {
  @override
  Widget build(BuildContext context) {
    if (widget.petitions?.isNotEmpty ?? false)
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: widget.petitions.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            key: ValueKey(index),
            closeOnScroll: true,
            actionPane: SlidableScrollActionPane(),
            secondaryActions: <Widget>[
              SlideAction(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: new Builder(builder: (context) {
                        return new Icon(
                          Icons.delete,
                          color: Theme.of(context).accentColor,
                          size: MediaQuery.of(context).size.height,
                        );
                      }),
                    ),
                  ),
                ),
                color: Theme.of(context).errorColor,
                onTap: () => _deletePetition(widget.petitions[index]),
              ),
            ],
            child: PetitionListItem(petition: widget.petitions[index]),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(height: 1);
        },
      );
    return EmptyListLayout(
      text: AppLocalizations.of(context).translate("noResult"),
    );
  }

  Future _deletePetition(Petition petition) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: AppLocalizations.of(context).translate("sureDeleteRequest"),
          buttonText: AppLocalizations.of(context).translate("delete"),
        );
      },
    );

    if (result == true) {
      Provider.of<SocketNotifier>(context, listen: false)
          .removePetition(petition);
    }
  }
}
