import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/sentence_case_text_formatter.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:app/src/model/archive/archive.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  final Archive archive;

  const ReportScreen({Key key, this.archive}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _commentController;

  Future _futureReport;
  int _reportType;

  String _selectedReason;
  List<String> _reasons;

  @override
  void initState() {
    super.initState();

    _commentController = TextEditingController();

    _reportType = 1;

    Future.delayed(
      Duration(seconds: 1),
      () {
        _selectedReason = _reasons.first;
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _reasons = [
      AppLocalizations.of(context).translate("reason1"),
      AppLocalizations.of(context).translate("reason2"),
      AppLocalizations.of(context).translate("reason3"),
      AppLocalizations.of(context).translate("reason4"),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        title: Text(AppLocalizations.of(context).translate("whatProblem")),
      ),
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFutureButton(
        text: AppLocalizations.of(context).translate("doReport"),
        future: _futureReport,
        callback: () {
          setState(() {
            _futureReport = _validate();
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        RadioListTile(
          dense: true,
          value: 1,
          groupValue: _reportType,
          activeColor: Theme.of(context).buttonColor,
          onChanged: (value) {
            setState(() {
              _selectedReason = _reasons[0];
              _reportType = value;
            });
          },
          title: Text(_reasons[0]),
        ),
        RadioListTile(
          dense: true,
          value: 2,
          groupValue: _reportType,
          activeColor: Theme.of(context).buttonColor,
          onChanged: (value) {
            setState(() {
              _selectedReason = _reasons[1];

              _reportType = value;
            });
          },
          title: Text(_reasons[1]),
        ),
        RadioListTile(
          dense: true,
          value: 3,
          groupValue: _reportType,
          activeColor: Theme.of(context).buttonColor,
          onChanged: (value) {
            setState(() {
              _selectedReason = _reasons[2];
              _reportType = value;
            });
          },
          title: Text(_reasons[2]),
        ),
        RadioListTile(
          dense: true,
          value: 4,
          groupValue: _reportType,
          activeColor: Theme.of(context).buttonColor,
          onChanged: (value) {
            setState(() {
              _selectedReason = _reasons[3];

              _reportType = value;
            });
          },
          title: Text(_reasons[3]),
        ),
        if (_reportType == 4)
          ListTile(
            title: TextField(
              inputFormatters: [
                SentenceCaseTextFormatter()
              ],
              controller: _commentController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).translate("addComment"),
                fillColor: Theme.of(context).disabledColor,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Future _validate() async {
    try {
      Map params = {
        "card_id": widget.archive.id,
        "reason": _selectedReason,
      };

      if (_reportType == 3) {
        params.putIfAbsent("comment", () => _commentController.text);
      }

      await ApiProvider().performCardReport(params);

      Navigator.pop(context);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}
