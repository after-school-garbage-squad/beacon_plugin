import 'package:permission_handler/permission_handler.dart';

@Deprecated("Permissions should be managed within the app.")
class BeaconPermissionManager {
  final List<Permission> _permissions = [
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.bluetoothScan
  ];

  List<Permission> get permissions => _permissions;

  List<PermissionWithService> get permissionsWithService => _permissions.whereType<PermissionWithService>().toList();

  Future<Map<Permission, PermissionStatus>> getPermissionStatuses() async {
    final Map<Permission, PermissionStatus> statuses =
    Map.fromIterables(
        _permissions,
        await Future.wait(_permissions.map((e) => e.status))
    );
    return statuses;
  }

  Future<Map<PermissionWithService, ServiceStatus>> getServiceStatuses() async {
    final Map<PermissionWithService, ServiceStatus> statuses =
    Map.fromIterables(
        permissionsWithService,
        await Future.wait(permissionsWithService.map((e) => e.serviceStatus))
    );
    return statuses;
  }

  Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await _permissions.request();
    return statuses;
  }
}