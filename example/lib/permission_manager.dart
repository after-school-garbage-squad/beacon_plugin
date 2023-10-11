import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static final List<Permission> _permissions = [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.location,
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.notification
  ];

  static List<Permission> get permissions => _permissions;

  static List<PermissionWithService> get permissionsWithService =>
      _permissions.whereType<PermissionWithService>().toList();

  Future<Map<Permission, PermissionStatus>> getPermissionStatuses() async {
    final Map<Permission, PermissionStatus> statuses = Map.fromIterables(
        _permissions, await Future.wait(_permissions.map((e) => e.status)));
    return statuses;
  }

  Future<Map<PermissionWithService, ServiceStatus>> getServiceStatuses() async {
    final Map<PermissionWithService, ServiceStatus> statuses =
        Map.fromIterables(
            permissionsWithService,
            await Future.wait(
                permissionsWithService.map((e) => e.serviceStatus)));
    return statuses;
  }

  Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await _permissions
        .where((e) =>
            e != Permission.locationWhenInUse &&
            e != Permission.locationAlways &&
            e != Permission.locationAlways)
        .toList()
        .request();
    final Map<Permission, PermissionStatus> sequentialStatues = await [
      Permission.locationWhenInUse,
      Permission.locationAlways
    ].request();
    statuses.addAll(sequentialStatues);

    return statuses;
  }
}
