import 'package:demo/components/connection_indicator.dart';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:demo/connections/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:isolate';

class LGServices extends StatefulWidget {
  const LGServices({Key? key}) : super(key: key);
  @override
  State<LGServices> createState() => _LGServicesState();
}

class _LGServicesState extends State<LGServices> {
  var height, width;

  List imgData = [
    {
      "img": "assets/images/shutdown.png",
      "title": "Shut Down",
    },
    {
      "img": "assets/images/relunch.png",
      "title": "Relaunch LG",
    },
    {
      "img": "assets/images/reboot.png",
      "title": "Reboot",
    },
    {
      "img": "assets/images/clear.png",
      "title": "Clear KML",
    },
  ];

  late SSH ssh;
  bool connectionStatus = false;

  void handleItemClick(int index) {
    if (!connectionStatus) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 220, 97, 63),
          title: Text(
            'Connection Error',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You are not connected to LG. Please connect first.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 255, 248, 125),
        title: Text(
          'Confirmation',
          style: TextStyle(
            color: Color.fromARGB(255, 27, 27, 27),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to ${imgData[index]["title"].toLowerCase()}?',
          style: TextStyle(
            color: Color.fromARGB(255, 27, 27, 27),
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await executeAction(index);
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> executeAction(int index) async {
    switch (index) {
      case 0:
        await ssh.shutdown();
        break;
      case 1:
        await ssh.relaunchLG();
        break;
      case 2:
        await ssh.reboot();
        break;
      case 3:
        await ssh.clearKML();
        break;
      default:
        print("Unknown function");
    }
  }

  Future<void> rebootInIsolate() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_rebootFunction, receivePort.sendPort);
  }

  void _rebootFunction(SendPort sendPort) {
    ssh.reboot();
  }

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _connectToLG();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 8, 56, 123),
        height: height,
        width: width,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(),
              height: height * 0.40,
              width: width,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 50,
                      left: 80,
                      right: 80,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(0, 255, 255, 255),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/images/back.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        ConnectionIndicator(isOnline: connectionStatus),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "LG Services",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              height: height * 0.6,
              width: width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 300),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  shrinkWrap: true,
                  itemCount: imgData.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        handleItemClick(index);
                      },
                      child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset(
                                imgData[index]["img"],
                                width: 100,
                                height: 100,
                              ),
                              SizedBox(height: 10),
                              Text(
                                imgData[index]["title"],
                                style: TextStyle(
                                  color: Color.fromARGB(255, 14, 14, 14),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
