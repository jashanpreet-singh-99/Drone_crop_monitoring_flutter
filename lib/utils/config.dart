import 'package:latlong2/latlong.dart';

class Config {
  static const String mapBoxAccessToken =
      'sk.eyJ1IjoiamFzaGFucHJlZXQ5OSIsImEiOiJjbGZ6cWhzNjQwbHdlM2xxZXZ3MXJocG9kIn0.VECdQXtxsC1JrDASl08YtA';

  static const String mapBoxStyleId = 'clfzqnhta006e01qso5adofwl';

  static final myLocation = LatLng(42.31741270569441, -83.03884432896145);

  static Uri urlAddFarm = Uri.parse("http://4.205.33.57/add_farm");
  static Uri urlDeleteFarm = Uri.parse("http://4.205.33.57/delete_farm");
  static Uri urlFarms = Uri.parse("http://4.205.33.57/show_farms");
  static Uri urlFarmGrid = Uri.parse("http://4.205.33.57/get_grid_farms");
  static Uri urlDroneStat = Uri.parse("http://4.205.33.57/get_drone_info");
  static Uri urlDroneState = Uri.parse("http://4.205.33.57/set_drone_state");

  // http://4.205.33.57/reset

  static const int STATE_DEPLOY = 0;
  static const int STATE_STALL = 1;
  static const int STATE_ABORT = 2;
}

class Log {
  static const bool DEBUG = true;

  static const String E = "Error";
  static const String I = "Info ";

  static const String TAG_SPLASH = "Activity_Splash_Screen";
  static const String TAG_FARM = "Activity_monitor_Screen";
  static const String TAG_MAP = "MapBox_Screen";
  static const String TAG_REQUEST = "server_request";
  static const String TAG_RENDER = "render_farm";

  static void log(String tag, String message, String type) {
    if (DEBUG) {
      // ignore: avoid_print
      print("$tag : $type : $message");
    }
  }
}
