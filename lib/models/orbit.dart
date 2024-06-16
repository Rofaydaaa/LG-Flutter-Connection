class OrbitModel {
  static String tag() {
    String content = '';

    double longitude = 31.20665;
    double latitude = 30.063806;
    // double longitude = 31.2348283;
    // double latitude = 30.0512139;
    String range = '5000';
    String tilt = '60';
    double altitude = 10000;
    String altitudeMode = 'relativeToSeaFloor';
    double heading = double.parse('0');
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
                  <longitude>$longitude</longitude>
                  <latitude>$latitude</latitude>
                  <heading>$heading</heading>
                  <tilt>60</tilt>
                  <range>$range</range>
                  <gx:fovy>60</gx:fovy>
                  <altitude>$altitude</altitude>
                  <gx:altitudeMode>$altitudeMode</gx:altitudeMode>
              </LookAt>
            </gx:FlyTo>
          ''';

      heading += 10;
      orbit += 1;
    }

    return content;
  }

  /// Builds and returns the `orbit` KML based on the given [content].
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
