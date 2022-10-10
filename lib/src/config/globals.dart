import 'package:app/src/utils/constants/petition_type.dart';
import 'package:app/src/utils/constants/searching_type.dart';
import 'package:flutter/cupertino.dart';

String accessToken;

SearchingType searchingType = SearchingType.OFFER;

PetitionType petitionType = PetitionType.RECEIVED;

Type archiveType;

final navigatorKey = GlobalKey<NavigatorState>();

String kellyFinderWeb = "www.kelly-finder.com";
String androidStore = "https://play.google.com/store/apps/details?id=com.kellyfinder.app";
String iosStore = "https://apps.apple.com/us/app/kellyfinder/id1530790495";

String policyAndLegalURL = "http://stage.kellyfindermail.com/storage/combo.pdf";
String policyURL = "http://stage.kellyfindermail.com/storage/politica_privacidad.pdf";
String termsURL = "http://stage.kellyfindermail.com/storage/terminos_condiciones.pdf";
String legalURL = "http://stage.kellyfindermail.com/storage/aviso_legal.pdf";
String raffleRulesURL = "http://stage.kellyfindermail.com/storage/sorteo.pdf";