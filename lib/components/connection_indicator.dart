import 'package:flutter/material.dart';

class ConnectionIndicator extends StatelessWidget {
  final bool isOnline;

  ConnectionIndicator({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    Color indicatorColor = isOnline ? Colors.green : Colors.red;

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: indicatorColor,
          ),
        ),
        SizedBox(width: 10),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 20,
            color: indicatorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
