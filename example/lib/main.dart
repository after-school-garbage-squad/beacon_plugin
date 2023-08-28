import 'package:beacon_plugin/beacon_manager.dart';
import 'package:beacon_plugin/beacon_plugin.dart';
import 'package:beacon_plugin/flutter_beacon_api.dart';
import 'package:beacon_plugin/pigeon.dart';
import 'package:beacon_plugin_example/beacon_data_controller.dart';
import 'package:beacon_plugin_example/beacon_data_widget.dart';
import 'package:beacon_plugin_example/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BeaconManager _beaconManager = BeaconPlugin.beaconManager;
  final PermissionManager _permissionManager = PermissionManager();
  final BeaconDataListController _beaconDataListController =
      BeaconDataListController();
  bool _isPermissionGranted = false;
  bool _isScanning = false;

  final _beaconDict = <String, BeaconVisibleData>{};

  @override
  void initState() {
    super.initState();
    _initAppState();
  }

  void _initAppState() {
    _permissionManager.getPermissionStatuses().then((value) {
      setState(() {
        _isPermissionGranted = value.values
            .every((element) => element == PermissionStatus.granted);
      });
    });
    _beaconDataListController.setBeaconDataList([BeaconVisibleData(
      beaconData:BeaconData(
        serviceUUID: "example service uuid",
        hwid: "example hwid",
      ),
        lastScanned: DateTime.now()
    )
    ]);
    _beaconManager.setBeaconServiceUUIDs(["FE6F"]);
    FlutterBeaconApi.setup(FlutterBeaconApiImpl(onScanned));
    // _beaconManager.startForegroundService();
  }

  void onScanned(List<BeaconData?> beaconDataList) {
    final List<BeaconData> bl = beaconDataList.whereType<BeaconData>().toList();
    for (var element in bl) {if (element.hwid != null) _beaconDict[element.hwid!] = BeaconVisibleData(beaconData: element, lastScanned: DateTime.now());}
    _beaconDataListController.setBeaconDataList(_beaconDict.values.toList());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            brightness: MediaQuery.of(context).platformBrightness,
            useMaterial3: true),
        home: ChangeNotifierProvider<BeaconDataListController>(
            create: (_) => _beaconDataListController,
            child: Scaffold(
                body: CustomScrollView(slivers: [
              const SliverAppBar.large(
                title: Text('Beacon Plugin Example'),
              ),
              SliverFillRemaining(
                  child: Column(children: [
                BeaconDataWidget(),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _isPermissionGranted
                            ? [
                                Expanded(
                                    child: FilledButton.tonal(
                                        onPressed: () async {
                                          if (_isScanning) {
                                            await _beaconManager.stopScan();
                                            setState(() {
                                              _isScanning = false;
                                            });
                                          } else {
                                            await _beaconManager.startScan();
                                            setState(() {
                                              _isScanning = true;
                                            });
                                          }
                                        },
                                        child: Text(
                                            "${_isScanning ? "Stop" : "Start"} Scanning")))
                              ]
                            : [
                                Expanded(
                                    child: FilledButton.tonal(
                                        onPressed: () {
                                          _permissionManager
                                              .requestPermissions()
                                              .then((value) {
                                            setState(() {
                                              _isPermissionGranted = value
                                                  .values
                                                  .every((element) =>
                                                      element ==
                                                      PermissionStatus.granted);
                                            });
                                          });
                                        },
                                        child: const Text("Grant permissions")))
                              ]))
              ])),
            ]))));
  }
}
