import 'package:flutter/material.dart';
import 'package:demo/components/connection_indicator.dart';
import 'package:demo/screens/connection_form_screen.dart';
import 'package:demo/screens/lg_services_screen.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:demo/connections/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late double height;
  late double width;

  late SSH ssh;
  bool connectionStatus = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  void _startFlyAnimation() {
    _controller.reset();
    _controller.forward();
    ssh.goHome();
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

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
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
              height: height * 0.30,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LGServices()),
                            );
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(29, 255, 255, 255),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/images/settings.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        ConnectionIndicator(isOnline: connectionStatus),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConnectFormScreen()),
                            );
                          },
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color.fromARGB(29, 255, 255, 255),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/images/link.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 20,
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
                                "Welcome to Liquid Galaxy!",
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
              height: height * 0.7,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Are you ready to move LG rig",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 14, 14, 14),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "To your home on the map?",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 14, 14, 14),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (!connectionStatus) {
                        // Display error message
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Color.fromARGB(255, 220, 97, 63),
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
                      _startFlyAnimation();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(75, 47, 59, 122)),
                      elevation: MaterialStateProperty.all<double>(0),
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2 * 3.141,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/flight.png',
                            width: 100,
                            height: 100,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Let\'s go!',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 59, 58, 58),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
