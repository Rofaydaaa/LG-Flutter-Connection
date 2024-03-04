import 'package:flutter/material.dart';
import 'package:demo/components/connection_indicator.dart';

class ConnectFormScreen extends StatelessWidget {
  var height, width;

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
                        ConnectionIndicator(isOnline: false),
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
                                "LG Connection",
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Username'),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Password'),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'IP Address'),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Port'),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Number of Screens'),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Handle connect button pressed
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 8, 56, 123),
                              ),
                            ),
                            child: Text(
                              'Connect',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
