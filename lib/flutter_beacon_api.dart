import 'package:beacon_plugin/pigeon.dart';

class FlutterBeaconApiImpl extends FlutterBeaconApi {
  final Function(BeaconData beaconData) caller;

  FlutterBeaconApiImpl(this.caller);

  @override
  void onScanned(BeaconData beaconData) {
    caller(beaconData);
  }
}
