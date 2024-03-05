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
      print('$_host,  $_passwordOrKey,  $_username,  $_port, $_numberOfRigs');
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> execute(cmd, success_message) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final result = await _client!.execute(cmd);
      print(success_message);
      return result;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<void> shutdown() async {

    final shutdown_command = 'sshpass -p $_passwordOrKey ssh -t lg$_username "echo $_passwordOrKey | sudo -S poweroff"';
    await execute(shutdown_command, 'Liquid Galaxy shutdown successfully');
  }

  Future<SSHSession?> relaunchLG() async {

    final relaunch_cmd = """
        RELAUNCH_CMD="\\
        if [ -f /etc/init/lxdm.conf ]; then
          export SERVICE=lxdm
        elif [ -f /etc/init/lightdm.conf ]; then
          export SERVICE=lightdm
        else
          exit 1
        fi

        if [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
          echo $_passwordOrKey | sudo -S service \\\${SERVICE} start
        else
          echo $_passwordOrKey | sudo -S service \\\${SERVICE} restart
        fi
        " && sshpass -p $_passwordOrKey ssh -x -t lg@lg1 "\$RELAUNCH_CMD\"""";

    return await execute(relaunch_cmd, 'Liquid Galaxy relaunched successfully');   
  }

  Future<void> reboot() async {
      final reboot_1 = 'sshpass -p $_passwordOrKey ssh -t lg1 "echo $_passwordOrKey | sudo -S reboot"';
      final reboot_2 = 'sshpass -p $_passwordOrKey ssh -t lg2 "echo $_passwordOrKey | sudo -S reboot"';
      final reboot_3 = 'sshpass -p $_passwordOrKey ssh -t lg3 "echo $_passwordOrKey | sudo -S reboot"';

      await execute(reboot_1, 'Liquid Galaxy 1 rebooted successfully');
      await execute(reboot_2, 'Liquid Galaxy 2 rebooted successfully');
      await execute(reboot_3, 'Liquid Galaxy 3 rebooted successfully');
  }

  Future<SSHSession?> goHome() async {
    final gohome_command = 'echo "search=Cairo" > /tmp/query.txt';
    return await execute(gohome_command, 'Liquid Galaxy went home successfully');
  } 

  Future<SSHSession?> Orbithome() async {
  
    final orbit_command = 'echo "flytoview=<gx:duration>1</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>31.20665</longitude><latitude>30.063806</latitude><range>5000</range><tilt>60</tilt><heading>180</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>" > /tmp/query.txt';
    return await execute(orbit_command, 'Liquid Galaxy orbit home successfully');

  }

}