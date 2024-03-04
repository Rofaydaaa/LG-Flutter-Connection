import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartssh2/dartssh2.dart';

class SSH {
  late String _host;  // _host is the ip address
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      print('$_host,  $_passwordOrKey,  $_username,  $_port');

      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> execute() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final result = await _client!.execute('echo "search=Llida" > /tmp/query.txt');


      return result;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  // DEMO above, all the other functions below
//   TODO 11: Make functions for each of the tasks in the home screen
}
