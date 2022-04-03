import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iot_wifi/flutter_iot_wifi.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:app_settings/app_settings.dart';
import 'package:hc_wifi_latest/scanScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  /// Default constructor for [MyApp] widget.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const WelcomeScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/scan': (context) => const ScanScreen(),
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<String> accessPoints = [];
  String ssid = 'William_WiFi';
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<bool> _checkPermissions() async {
    if (Platform.isIOS || await Permission.location.request().isGranted) {
      return true;
    }
    return false;
  }

  _current() async {
    if (await _checkPermissions()) {
      ssid = await FlutterIotWifi.current() as String;
      setState(() {});
    } else {
      const snackBar = SnackBar(
        content: Text("WiFi Permissions not set"),
      );
      _messengerKey.currentState!.showSnackBar(snackBar);
    }
  }

  void _disconnect() async {
    if (await _checkPermissions()) {
      FlutterIotWifi.disconnect().then((value) => print("disconnect initiated: $value"));
    } else {
      print("don't have permission");
    }
  }

  @override
  void initState(){
    super.initState();
    _current();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigiLube HeadController App',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 116, 21, 17),
          centerTitle: true,
          title: const Text('DigiLube HeadController App'),
          leading: IconButton (icon:const Icon(Icons.arrow_back),
              onPressed:() {
                showDialog(context: context, builder: (BuildContext context)
                {
                  return AlertDialog(
                    backgroundColor:Colors.grey,
                    title: const Text("Are you sure want to exit?"),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 116, 21, 17))),
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                        _disconnect();
                        exit(0);
                      },
                      ),
                      const SizedBox(width: 20.0),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color.fromARGB(255, 255, 255, 255))),
                        child: const Text('No',
                            style: TextStyle(color: Colors.black)),
                        onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      ),
                    ]),
                  );
                });
              },
              )
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 155.0,
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            const Center(
                child: Text("You are currently connected to:\n",
                    style: TextStyle(fontSize: 24.0, color: Colors.black54))),
            Center(
                child: Text("$ssid\n",
                    style: const TextStyle(fontSize: 36.0, color: Colors.black54))),
            ElevatedButton(
              child: const Text('   SCAN   ', style: TextStyle(fontSize: 24.0)),
              style: ButtonStyle(
                //backgroundColor: Colors.blueAccent,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.blueAccent)))
              ),
              onPressed: () {
                if (Platform.isAndroid) {
                  const snackBar = SnackBar(
                    content: Text('Scanning...'),
                  );
                  _messengerKey.currentState!.showSnackBar(snackBar);
                }
                [(Platform.isAndroid)
                      ? Navigator.pushNamed(context, '/scan')
                      : AppSettings.openWIFISettings(), Navigator.pushNamed(context, '/scan')];
              },
            ),
          ],
        ),
      ),
    );
  }
}
