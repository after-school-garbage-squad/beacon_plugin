import 'package:beacon_plugin/pigeon.dart';

class FlutterBeaconApiImpl extends FlutterBeaconApi {
  final Function(List<BeaconData?> beaconDataList) caller;

  FlutterBeaconApiImpl(this.caller);

  @override
  void onScanned(List<BeaconData?> beaconDataList) {
    caller(beaconDataList);
  }
}
