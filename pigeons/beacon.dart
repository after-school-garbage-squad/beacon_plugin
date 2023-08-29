import 'package:pigeon/pigeon.dart';

class BeaconData {
  String? serviceUUID;
  String? hwid;
  double? rssi;
}

@HostApi()
abstract class BeaconManagerApi {
  @async
  void setBeaconServiceUUIDs(List<String> uuid);

  @async
  void startScanning();

  @async
  void stopScanning();
}

@FlutterApi()
abstract class FlutterBeaconApi {
  void onScanned(List<BeaconData> beaconDataList);
}
