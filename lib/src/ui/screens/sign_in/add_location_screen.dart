import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/model/user.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/button/custom_future_button.dart';
import 'package:app/src/ui/widgets/form/location_textfield.dart';
import 'package:app/src/ui/widgets/navigation_bar.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddLocationScreen extends StatefulWidget {
  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _locationController;

  Future _futureLocation;

  Map _mapInfo;

  @override
  void initState() {
    super.initState();

    _locationController = TextEditingController();

    _mapInfo = {};
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle:true,
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            onPressed: () => navigateTo(context, NavigationBar(fromLogin: true),
                willPop: true),
            child: Text(AppLocalizations.of(context).translate("skip")),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: CustomFutureButton(
        text: AppLocalizations.of(context).translate("add"),
        future: _futureLocation,
        callback: () {
          setState(() {
            _futureLocation = _validate();
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Form(
              key: _formKey,
              child: _buildForm(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(
            AppLocalizations.of(context).translate("addLocation"),
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        SizedBox(height: 32),
        LocationTextField(
          controller: _locationController,
          mapInfo: _mapInfo,
          callback: (address){
            setState(() {
              _locationController.text = address;
            });
          },
        ),
      ],
    );
  }

  Future _validate() async {
    if (_formKey.currentState.validate()) {
      try {
        User user = await ApiProvider().performSetLocation({
          "lat": _mapInfo["lat"],
          "lng": _mapInfo["long"],
          "locality": _mapInfo["city"],
        });

        Provider.of<UserNotifier>(context, listen: false).editUser(user);

        navigateTo(context, NavigationBar(fromLogin: true), willPop: true);
      } catch (e) {
        catchErrors(e, _scaffoldKey);
      }
    }
  }
}
