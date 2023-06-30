import 'dart:async';
import 'dart:io' show Platform;
import 'package:beacon_plugin/pigeon.dart';

class BeaconManager {
  bool _isMonitoring = false;
  bool _isRanging = false;
  bool _isForegroundServiceRunning = false;
  final BeaconManagerApi api = BeaconManagerApi();

  /// Starts monitoring beacons.
  /// Android: beaconManager.startMonitoring(Region region)
  /// iOS: locationManager.startMonitoring(for region: CLRegion)
  Future<void> startMonitoring() async {
    if (_isMonitoring) throw Exception('Already monitoring');
    await api.startMonitoring();
    _isMonitoring = true;
  }

  /// Stops monitoring beacons.
  /// Android: beaconManager.stopMonitoring(Region region)
  /// iOS: locationManager.stopMonitoring(for region: CLRegion)
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) throw Exception('Not monitoring');
    await api.stopMonitoring();
    _isMonitoring = false;
  }

  /// Returns the region that is currently being monitored.
  /// Android: regionViewModel.regionState
  /// iOS: locationManager.monitoredRegions
  Future<RegionData?> getMonitoredRegion() {
    return _isRanging ? api.getMonitoredRegion() : Future.value();
  }

  /// Starts ranging beacons.
  /// Must explicitly branch in application code to avoid calling this method on iOS.
  /// Android: beaconManager.startRanging(Region region)
  /// iOS: There is no manual ranging on iOS. This method will throw an exception.
  /// Must explicitly branch in application code to avoid calling this method on iOS.
  Future<void> startRanging() async {
    if (_isRanging) throw Exception('Already ranging');
    if (Platform.isIOS) throw Exception('iOS does not support manual ranging');
    await api.startRanging();
    _isRanging = true;
  }

  /// Stops ranging beacons.
  /// Must explicitly branch in application code to avoid calling this method on iOS.
  /// Android: beaconManager.stopRanging(Region region)
  /// iOS: There is no manual ranging on iOS. This method will throw an exception.
  Future<void> stopRanging() async {
    if (!_isRanging) throw Exception('Not ranging');
    if (Platform.isIOS) throw Exception('iOS does not support manual ranging');
    await api.stopRanging();
    _isRanging = false;
  }

  /// Returns a list of beacons that have been ranged.
  /// Android: regionViewModel.rangedBeacons
  /// iOS: locationManager.rangedRegions
  Future<List<BeaconData?>?> getRangedBeacons() {
    return _isRanging ? api.getRangedBeacons() : Future.value(null);
  }

  /// Starts the foreground service.
  /// Android: beaconManager.startForegroundService()
  /// iOS: There is no foreground service on iOS. This method will throw an exception.
  Future<void> startForegroundService() async {
    if (isForegroundServiceRunning) throw Exception('Foreground service already running');
    if (Platform.isIOS) throw Exception('iOS does not support foreground service');
    await api.startForegroundService();
    _isForegroundServiceRunning = true;
  }

  /// Stops the foreground service.
  /// Android: beaconManager.stopForegroundService()
  /// iOS: There is no foreground service on iOS. This method will throw an exception.
  Future<void> stopForegroundService() async {
    if (!isForegroundServiceRunning) throw Exception('Foreground service not running');
    if (Platform.isIOS) throw Exception('iOS does not support foreground service');
    await api.stopForegroundService();
    _isForegroundServiceRunning = false;
  }

  /// Returns the current monitoring region.
  bool get isForegroundServiceRunning => _isForegroundServiceRunning;

  /// Singleton
  static final BeaconManager _instance = BeaconManager._internal();
  factory BeaconManager() => _instance;
  BeaconManager._internal();
}