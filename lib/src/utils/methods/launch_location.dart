import 'package:url_launcher/url_launcher.dart';

void launchLocation(double lat, double long) async {
  String url = "https://www.google.com/maps/search/?api=1&query=" + "$lat,$long";

  print("URL: $url");

  if (await canLaunch(url)) {
    print("Can launch");

    await launch(url);
  } else {
    print("Could not launch");
    throw 'Could not launch Maps';
  }
}

void launchWeb(String web) async {
  String url = web;

  if (!url.contains("http://") && !url.contains("https://")) {
    url = "http://" + url;
  }

  if (await canLaunch(url)) {
    print("Can launch");

    await launch(url);
  } else {
    print("Could not launch");
    throw 'Could not launch Web';
  }
}
