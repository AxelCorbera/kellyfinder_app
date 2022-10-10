import 'package:app/src/api/api_provider.dart';
import 'package:app/src/config/app_localizations.dart';
import 'package:app/src/config/app_styles.dart';
import 'package:app/src/model/event.dart';
import 'package:app/src/model/municipality/municipality.dart';
import 'package:app/src/provider/user_notifier.dart';
import 'package:app/src/ui/widgets/button/custom_button.dart';
import 'package:app/src/ui/widgets/dialog/add_festive_dialog.dart';
import 'package:app/src/ui/widgets/dialog/custom_dialog.dart';
import 'package:app/src/ui/widgets/indicators/future_circular_indicator.dart';
import 'package:app/src/ui/widgets/navigation_bar.dart';
import 'package:app/src/utils/alerts/catch_errors.dart';
import 'package:app/src/utils/methods/navigation_performer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:app/src/config/string_casing_extension.dart';
import 'package:table_calendar/table_calendar.dart';

class AddMunicipalityFestiveScreen extends StatefulWidget {
  final bool isCreating;

  AddMunicipalityFestiveScreen({this.isCreating = false});

  @override
  _AddMunicipalityFestiveScreenState createState() =>
      _AddMunicipalityFestiveScreenState();
}

class _AddMunicipalityFestiveScreenState
    extends State<AddMunicipalityFestiveScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future _futureEvents;

  CalendarController _calendarController;

  Map<DateTime, List<Event>> _events;

  List<Event> _selectedEvents;
  DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _futureEvents = getData();

    _selectedDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    _events = {};

    _selectedEvents = [];
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("publishMunicipality"),
        ),
      ),
      body: FutureBuilder(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return _buildBody();
            }
          }
          return FutureCircularIndicator();
        },
      ),
      //body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomButton(
        text: AppLocalizations.of(context).translate("save"),
        function: () {
          if (/*municipality == null*/ widget.isCreating) {
            /*Provider.of<UserNotifier>(context, listen: false)
                    .appUser
                    .municipality =
                Municipality(id: 0, name: "name", customName: "custom_name", major: "major", population: 200, phone: "phone", email: "email", directionTownHall: "",
                    lat: 12, lng: 23, video: "video", province: null, community: null, elevation: 12, politicalParty: "party", isRegistered: true);*/

            navigateTo(context, NavigationBar(initIndex: 3), willPop: true);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              AppLocalizations.of(context).translate("festive"),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _buildTableCalendar(),
          _buildEventList(),
          _buildButton(),
          SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      builders: CalendarBuilders(
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                bottom: 1,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle
                  ),
                ),
              ),
            );
          }

          return children;
        },
      ),
      events: _events,
      onDaySelected: (day, events) {
        setState(() {
          _selectedDay = DateTime(
            day.year,
            day.month,
            day.day,
          );

          _selectedEvents.clear();
          _selectedEvents.addAll(List.from(events));
        });
      },
      initialSelectedDay: _selectedDay,
      initialCalendarFormat: CalendarFormat.month,
      availableGestures: AvailableGestures.horizontalSwipe,
      availableCalendarFormats: const {CalendarFormat.month: ''},
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Theme.of(context).primaryColorLight,
        todayColor: Theme.of(context).primaryColorLight.withOpacity(0.5),
        markersColor: Theme.of(context).primaryColor,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(
          color: Colors.white,
          fontSize: 15.0,
        ),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      //onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _selectedEvents.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            ListTile(
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: AppLocalizations.of(context).translate("municipality_events_delete_confirmation_text"),
                        buttonText: AppLocalizations.of(context).translate("accept"),
                      );
                    },
                  );

                  if(result){
                    _deleteEvent(_selectedEvents[index].id);

                    setState(() {
                      _selectedEvents.removeAt(index);

                      if(_selectedEvents.length == 0){
                        _events.removeWhere((key, value) => key == _selectedDay);
                      }
                    });
                  }
                },
              ),
              dense: true,
              title: Text(
                AppLocalizations.of(context).translate("festiveName"),
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(color: AppStyles.lightGreyColor),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _selectedEvents[index].name,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
            ListTile(
              dense: true,
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.language,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).translate("link"),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: AppStyles.lightGreyColor),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _selectedEvents[index].link != "" ? _selectedEvents[index].link : "-",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Colors.black38);
      },
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: FlatButton.icon(
        padding: EdgeInsets.all(4),
        onPressed: () async {
          final result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddFestiveDialog();
              });

          if (result != null){

            Event ev = await _createEvent(result);

            setState(() {
              if (_events.containsKey(_selectedDay)) {
                _events[_selectedDay].add(ev);
              } else {
                _events.putIfAbsent(_selectedDay, () => [ev]);
              }
              _selectedEvents.add(ev);
            });
          }

        },
        icon: Icon(
          Icons.add,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
        label: Text(
          AppLocalizations.of(context).translate("addFestive"),
          style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Future getData() async {
    try {
      List<Event> events = await ApiProvider().getEvents(
          {},
          Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .id);

      for (var i = 0; i < events.length; i++) {
        DateTime date = DateTime.parse(events[i].date);

        if (_events.containsKey(date)) {
          _events[date].add(events[i]);
        } else {
          _events.putIfAbsent(date, () => [events[i]]);
        }
      }

      return true;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  Future<Event> _createEvent(Event event) async {
    try {
      String formattedDate = intl.DateFormat('yyyy-MM-dd').format(_selectedDay);

      Event result = await ApiProvider().createEvent(
          {"date": formattedDate, "name": event.name, "link": event.link},
          Provider.of<UserNotifier>(context, listen: false)
              .appUser
              .municipality
              .id);

      print(result);

      return result;
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }

  _deleteEvent(int eventId) async {
    try {
      var result =
      await ApiProvider().deleteEvent({}, eventId);

      print(result);
    } catch (e) {
      catchErrors(e, _scaffoldKey);
    }
  }
}
