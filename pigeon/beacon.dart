import 'package:pigeon/pigeon.dart';

class BeaconData {
  String? uuid;
  String? major;
  String? minor;
  int? rssi;
  int? proximity; // 0 = unknown, 1 = immediate, 2 = near, 3 = far
  String? hwid;
}

class RegionData {
  String? uuid;
  String? major;
  String? minor;
  int? state; // 0 = unknown, 1 = inside, 2 = outside
}

@HostApi()
abstract class BeaconManagerApi {
  @async
  void startMonitoring();

  @async
  void stopMonitoring();

  @async
  RegionData? getMonitoredRegion();

  @async
  void startRanging();

  @async
  void stopRanging();

  @async
  List<BeaconData?>? getRangedBeacons();

  @async
  void startForegroundService();

  @async
  void stopForegroundService();
}
