import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartssh2/dartssh2.dart';

class SSH {
  late String _host; // _host is the ip address
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
    for (int i = 1; i <= int.parse(_numberOfRigs); i++) {
      final shutdown_command =
          'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S shutdown now"';
      await execute(shutdown_command, 'Liquid Galaxy $i shutdown successfully');
    }
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
    for (int i = 1; i <= int.parse(_numberOfRigs); i++) {
      final reboot_command =
          'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"';
      await execute(reboot_command, 'Liquid Galaxy $i rebooted successfully');
    }
  }

  Future<SSHSession?> goHome() async {
    final gohome_command = 'echo "search=Cairo" > /tmp/query.txt';
    return await execute(
        gohome_command, 'Liquid Galaxy went home successfully');
  }

  Future<SSHSession?> Orbithome() async {
    final orbit_command =
        'echo "flytoview=<gx:duration>1</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>31.20665</longitude><latitude>30.063806</latitude><range>5000</range><tilt>60</tilt><heading>0</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>" > /tmp/query.txt';
    await execute(orbit_command, 'Liquid Galaxy orbit home successfully');
    final orbit_command2 =
        'echo "flytoview=<gx:duration>1</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>31.20665</longitude><latitude>30.063806</latitude><range>5000</range><tilt>60</tilt><heading>180</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>" > /tmp/query.txt';
    await execute(
        orbit_command2, 'Liquid Galaxy orbit home successfully');
    return await execute(
        orbit_command, 'Liquid Galaxy orbit home successfully');
  }

  Future<SSHSession?> sendKML() async {
    // Add the ballon html
    final KML2 = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>VolTrac</name>
	<open>1</open>
	<description>The logo it located in the bottom left hand corner</description>
	<Folder>
		<name>tags</name>
		<Style>
			<ListStyle>
				<listItemType>checkHideChildren</listItemType>
				<bgColor>00ffffff</bgColor>
				<maxSnippetLines>2</maxSnippetLines>
			</ListStyle>
		</Style>
		<ScreenOverlay id="abc">
			<name>VolTrac</name>
			<Icon>
				<href>https://raw.githubusercontent.com/Rofaydaaa/LG-Flutter-Connection/master/assets/images/ballon.png</href>
			</Icon>
			<overlayXY x="0.9" y="1" xunits="fraction" yunits="fraction"/>
			<screenXY x="0.9" y="0.7" xunits="fraction" yunits="fraction"/>
			<rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
			<size x="0" y="0" xunits="pixels" yunits="fraction"/>
		</ScreenOverlay>
	</Folder>
</Document>
</kml>
    ''';
    final kml_command2 = "echo '$KML2' > /var/www/html/kml/slave_2.kml";
    return execute(kml_command2, 'Liquid Galaxy set KML successfully');
  }

  Future<SSHSession?> clearKML() async {
    final slave2_command = 'echo "" > /var/www/html/kml/slave_2.kml';
    await execute(
        slave2_command, 'Liquid Galaxy cleared KML from slave2 successfully');
    final slave3_command = 'echo "" > /var/www/html/kml/slave_3.kml';
    return await execute(
        slave3_command, 'Liquid Galaxy cleared KML from slave 3 successfully');
  }

  uploadKml(File inputFile, String filename) async {
    final sftp = await _client?.sftp();
    double anyKindofProgressBar;
    print("sftp created");
    final file = await sftp?.open('/var/www/html/$filename',
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write);
    var fileSize = await inputFile.length();
    await file?.write(inputFile.openRead().cast(), onProgress: (progress) {
      anyKindofProgressBar = progress / fileSize;
    });
  }

  Future<void> sendTour(String tourKml, String tourName) async {
    final String _url = 'http://lg1:81';
    final fileName = '$tourName.kml';
    try {
      final kmlFile = await createFile(fileName, tourKml);
      print('kml created');
      await uploadKml(kmlFile, fileName);
      print('kml uploaded');

      await execute('echo "\n$_url/$fileName" >> /var/www/html/kmls.txt',
          'Tour added successfully');
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }

  Future<void> query(String content) async {
    await execute(
        'echo "$content" > /tmp/query.txt', 'Query sent successfully');
  }

  Future<void> startTour(String tourName) async {
    try {
      print('here play tour');
      await query('playtour=$tourName');
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  /// Uses the [query] method to stop all tours in Google Earth.
  Future<void> stopTour() async {
    try {
      await query('exittour=true');
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}

class OrbitModel {
  /// Generates the orbit tag based on the given [lookAt].
  static String tag() {
    String content = '';

    double heading = 0;
    int orbit = 0;

    while (orbit <= 36) {
      if (heading >= 360) {
        heading -= 360;
      }

      content += '''
            <gx:FlyTo>
              <gx:duration>1.2</gx:duration>
              <gx:flyToMode>smooth</gx:flyToMode>
              <LookAt>
                  <longitude>31.20665</longitude>
                  <latitude>30.063806</latitude>
                  <heading></heading>
                  <tilt>60</tilt>
                  <range>10000</range>
                  <gx:fovy>60</gx:fovy>
                  <altitude>50000.1097385</altitude>
                  <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
              </LookAt>
            </gx:FlyTo>
          ''';

      heading += 10;
      orbit += 1;
    }

    return content;
  }

  /// Builds and returns the orbit KML based on the given [content].
  static String buildOrbit(String content) => '''
<?xml version="1.0" encoding="UTF-8"?>
      <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
        <gx:Tour>
          <name>Orbit</name>
          <gx:Playlist> 
            $content
          </gx:Playlist>
        </gx:Tour>
      </kml>
    ''';
}

Future<File> createFile(String name, String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$name');
  file.writeAsStringSync(content);

  return file;
}
