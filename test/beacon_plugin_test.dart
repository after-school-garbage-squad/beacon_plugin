import 'package:flutter_test/flutter_test.dart';
import 'package:beacon_plugin/beacon_plugin.dart';
import 'package:beacon_plugin/beacon_plugin_platform_interface.dart';
import 'package:beacon_plugin/beacon_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBeaconPluginPlatform
    with MockPlatformInterfaceMixin
    implements BeaconPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BeaconPluginPlatform initialPlatform = BeaconPluginPlatform.instance;

  test('$MethodChannelBeaconPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBeaconPlugin>());
  });

  test('getPlatformVersion', () async {
    BeaconPlugin beaconPlugin = BeaconPlugin();
    MockBeaconPluginPlatform fakePlatform = MockBeaconPluginPlatform();
    BeaconPluginPlatform.instance = fakePlatform;

    expect(await beaconPlugin.getPlatformVersion(), '42');
  });
}
