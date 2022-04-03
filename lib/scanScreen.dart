import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_iot_wifi/flutter_iot_wifi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<String> accessPoints = [];
  String ssid = '';
  String password = 'T6589435a!.';
  static const String _url = 'http://192.168.1.110/';
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  Color highlightColor = Colors.black54;

  void _launchURL() async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isIOS || await Permission.location.request().isGranted) {
      return true;
    }
    return false;
  }

  _scan(BuildContext context) async {
    if (await _checkPermissions()) {
      FlutterIotWifi.scan().then((value) => print("scan started: $value"));
      await Future.delayed(const Duration(seconds: 1));
      //FlutterIotWifi.list().then((value) => print("ssids: $value"));
      accessPoints = await FlutterIotWifi.list();
      setState(() {});
    } else {
      //print("don't have permission");
      const snackBar = SnackBar(
        content: Text("don't have permission"),
      );
      _messengerKey.currentState!.showSnackBar(snackBar);
    }
  }

  _connect() async {
    if (await _checkPermissions()) {
      FlutterIotWifi.connect(ssid, password, prefix: true)
          .then((value) => print("connect initiated: $value"));
    } else {
      const snackBar = SnackBar(
        content: Text("don't have permission"),
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

  _select(String name) {
    ssid = name;
    return ssid;
  }

  @override
  void initState() {
    super.initState();
    _scan(context);
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
            )),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 155.0,
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            const Text("Pull Down to Refresh."),
            const Divider(thickness: 2),
            Flexible(
                child: Center(
                    child: accessPoints.isEmpty
                        ? RefreshIndicator(onRefresh: () {  return _scan(context); },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: accessPoints.length, itemBuilder: (BuildContext context, int index) { return const Text("NO SCANNED RESULTS"); }))
                        : RefreshIndicator(child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            //shrinkWrap: true,
                            itemCount: accessPoints.length,
                            itemBuilder: (context, i) {
                              if (accessPoints[i].startsWith("Ani")) {
                                final ap = accessPoints[i];
                                return ListTile(
                                  visualDensity: VisualDensity.compact,
                                  title: Text(ap,
                                      style: const TextStyle(fontSize: 24.0)),
                                  textColor: highlightColor,
                                  tileColor:
                                      const Color.fromARGB(255, 225, 225, 225),
                                  trailing: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color.fromARGB(
                                                  255, 116, 21, 17)),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      )),
                                    ),
                                    child: const Text('CONNECT',
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      //_disconnect();
                                      ssid = _select(ap);
                                      highlightColor = Colors.blue;
                                      setState(() {});
                                      _connect();
                                      const snackBar = SnackBar(
                                        content: Text('Connecting!'),
                                      );
                                      _messengerKey.currentState!
                                          .showSnackBar(snackBar);
                                      if (ssid.startsWith("Ani")) {
                                        _launchURL();
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return const AlertDialog(
                                                title:
                                                    Text("Connection Failed"),
                                                content: Text(
                                                    "Please connect to HC5004* WiFi"),
                                              );
                                            });
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    highlightColor = Colors.blue;
                                    ssid = _select(ap);
                                    setState(() {});
                                  },
                                );
                              }
                              return const Text("Other");
                            }),
                          color: const Color.fromARGB(255, 116, 21, 17),
                          onRefresh: () { return _scan(context); },)
                )
            )
          ],
        ),
      ),
    );
  }
}
