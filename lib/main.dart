import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pusher_websocket_flutter/pusher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageMain(),
    );
  }
}

class Status {
  static var connect = "CONNECTED";
  static var disconnect = "DISCONNECTED";
}

class PageMain extends StatelessWidget {
  RxString _status = "${Status.disconnect}".obs;
  RxString _data = "-".obs;
  RxBool _isConnect = false.obs;
  Channel? _channel;

  //pusher
  String _apiKey = "your_pusher_api_key";
  String _cluster = "your_pusher_cluster";
  String _yourChannel = "your_pusher_channel";
  String _yourEvent = "your_pusher_event";

  // if you using null safety version, add --no-sound-null-safety
  // Android Studio = Run > Edit Configurations > Additional Arguments
  // VS Code or other IDE = you can search on Google :)

  _start() async {
    try {
      Pusher.init(
        _apiKey,
        PusherOptions(
          cluster: _cluster,
        ),
      );
      Pusher.connect(
        onConnectionStateChange: (state) {
          // connection status
          _status.value = state.currentState;
        },
        onError: (error) => print("error  connect: ${error.message}"),
      );
      _channel = await Pusher.subscribe(_yourChannel);
      _channel!.bind(_yourEvent, (event) {
        // retrieve data
        _data.value = event.data;
      });
    } catch (e) {
      print("error catch: $e");
    }
  }

  _stop() {
    Pusher.disconnect();
    Pusher.unsubscribe(_yourChannel);
    _channel!.unbind(_yourEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        _isConnect.value = _status.value == Status.connect;
        return Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
            padding: EdgeInsets.all(12),
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: !_isConnect.value
                            ? () {
                                _start();
                              }
                            : () {},
                        color: !_isConnect.value
                            ? Colors.blue
                            : Colors.grey.shade300,
                        child: Text(
                          "START",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 8),
                    Expanded(
                      child: MaterialButton(
                        onPressed: _isConnect.value
                            ? () {
                                _stop();
                              }
                            : () {},
                        color: _isConnect.value
                            ? Colors.red
                            : Colors.grey.shade300,
                        child: Text(
                          "STOP",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _text(data: "Status", fontWeight: FontWeight.w700),
              _text(
                data: _status.value,
                color: _isConnect.value ? Colors.blue : Colors.red,
              ),
              _text(data: "Data", marginTop: 16, fontWeight: FontWeight.w700),
              _text(data: _data.value),
            ],
          ),
        );
      },
    );
  }

  _text({
    double marginTop = 8,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    required var data,
  }) {
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      child: Text(
        data,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}
