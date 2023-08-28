import 'dart:async';
import 'dart:io' show Platform;
import 'package:beacon_plugin/pigeon.dart';

class BeaconManager {
  bool _isScanning = false;
  final BeaconManagerApi api = BeaconManagerApi();

  /// Starts ranging beacons.
  /// TODO: Android: beaconManager.startRanging(Region region)
  /// iOS: beaconManager.setBeaconServiceUUIDs(beaconServiceUUIDs: [String])
  Future<void> setBeaconServiceUUIDs(List<String> uuid) async {
    await api.setBeaconServiceUUIDs(uuid);
  }

  /// Starts scanning beacons.
  /// TODO: Android: beaconManager.startMonitoring(Region region)
  /// iOS: locationManager.startScanning()
  Future<void> startScanning() async {
    if (_isScanning) throw Exception('Already monitoring');
    await api.startScanning();
    _isScanning = true;
  }

  /// Stops scanning beacons.
  /// TODO: Android: beaconManager.stopMonitoring(Region region)
  /// iOS: locationManager.stopScanning()
  Future<void> stopScanning() async {
    if (!_isScanning) throw Exception('Not monitoring');
    await api.stopScanning();
    _isScanning = false;
  }

  /// Singleton
  static final BeaconManager _instance = BeaconManager._internal();
  factory BeaconManager() => _instance;
  BeaconManager._internal();
}
