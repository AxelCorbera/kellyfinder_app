  import 'dart:async';

import 'package:app/src/config/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:pusher_websocket_flutter/pusher.dart';

class SocketService {
  Event lastEvent;
  String lastConnectionState;
  Channel channel;
  //final String _url = "http://dev.kellyfindermail.com";
  final String _url = "http://stage.kellyfindermail.com";

  StreamController<String> _eventData = StreamController<String>();

  Sink get _inEventData => _eventData.sink;

  Stream get eventStream => _eventData.stream;

  Future<void> initPusher() async {
    try {
      await Pusher.init(
        "AnyKey",
        PusherOptions(
          auth: PusherAuth(_url + '/api/broadcasting/auth', headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer " + globals.accessToken,
          }),
          cluster: 'eu',
          host: '82.223.115.184',
          port: 6001,
          encrypted: false,
        ),
      );
    } on PlatformException catch (e) {
      print("PlatformException: ${e.message}");
    }
  }

  void connectPusher() {
    Pusher.connect(
      onConnectionStateChange: (ConnectionStateChange connectionState) async {
        print("ESTADO: " + connectionState.currentState);
        lastConnectionState = connectionState.currentState;
      },
      onError: (ConnectionError e) {
        print("Error: ${e.message}");
        print("JSON: ${e.toJson()}.");
      },
    );
  }

  Future disconnect(String channelName) {
    unSubscribePusher(channelName);
    Pusher.disconnect();
  }

  Future<void> subscribePusher(String channelName) async {
    print("TRY CHANNEL $channelName");

    channel = await Pusher.subscribe(channelName);

    print("SUBSCRIBED $channel");
  }

  void unSubscribePusher(String channelName) {
    Pusher.unsubscribe(channelName);
  }

  void bindEvent(String eventName) {
    print(eventName);

    channel.bind(eventName, (last) {
      final String data = last.data;
      _inEventData.add(data);
    });
  }

  void unbindEvent(String eventName) {
    channel.unbind(eventName);
    _eventData.close();
  }

  Future<void> firePusher(String channelName, String event) async {
    await initPusher();

    connectPusher();

    await subscribePusher(channelName);

    bindEvent(event);
  }
}
