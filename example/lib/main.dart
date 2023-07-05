import 'dart:async';

import 'package:beacon_plugin/beacon_manager.dart';
import 'package:beacon_plugin/beacon_plugin.dart';
import 'package:beacon_plugin/pigeon.dart';
import 'package:beacon_plugin_example/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

enum BeaconProximity {
  unknown,
  immediate,
  near,
  far,
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BeaconManager _beaconManager = BeaconPlugin.beaconManager;
  final PermissionManager _permissionManager = PermissionManager();
  late final Stream<List<BeaconData?>?> _rangedBeaconsStream;
  bool _isPermissionGranted = false;
  bool _isMonitoring = false;
  bool _isRanging = false;

  @override
  void initState() {
    super.initState();
    _initAppState();
  }

  void _initAppState() {
    _permissionManager.getPermissionStatuses().then((value) {
      setState(() {
        _isPermissionGranted = value.values.every((element) => element == PermissionStatus.granted);
      });
    });
    _rangedBeaconsStream = (() async* {
      while(true){
        await Future.delayed(const Duration(seconds: 1));
        yield await _beaconManager.getRangedBeacons();
      }
    })();
    _beaconManager.startForegroundService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: MediaQuery.of(context).platformBrightness,
        useMaterial3: true
      ),
      home: Scaffold(
        body: CustomScrollView(
          slivers:[
            SliverAppBar.large(
              title: const Text('Beacon Plugin Example'),
            ),
            SliverFillRemaining(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: _rangedBeaconsStream,
                    builder: (context, AsyncSnapshot<List<BeaconData?>?> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return const Expanded(child: Center(child: Text("No beacons found.")));
                        } else {
                          return Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: snapshot.data!.map((e) {
                                final String proximity = BeaconProximity.values[e!.proximity!].toString().split('.').last;
                                return ListTile(
                                  title: Text("HWID: ${e.hwid ?? "Scanning..."}"),
                                  subtitle: Text("UUID: ${e.uuid}\nMajor: ${e.major}\nMinor: ${e.minor}\nRSSI: ${e.rssi}"),
                                  trailing: Text("${proximity[0].toUpperCase()}${proximity.substring(1).toLowerCase()}"),
                                );
                              }).toList()
                            )
                          );
                        }
                      } else {
                        if (_isMonitoring == true || _isRanging == true) {
                          return const Expanded(child:
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 10.0),
                                Text("Scanning for beacons...")
                              ]
                            )
                          );
                        } else {
                          return const Expanded(child: Center(child: Text("Start monitoring or ranging to scan for beacons.")));
                        }
                      }
                    }
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _isPermissionGranted ? [
                        Expanded(child:
                          FilledButton.tonal(
                            onPressed: () async {
                              if (_isMonitoring) {
                                await _beaconManager.stopMonitoring();
                                setState(() { _isMonitoring = false; });
                              } else {
                                await _beaconManager.startMonitoring();
                                setState(() { _isMonitoring = true; });
                              }
                            },
                            child: Text("${_isMonitoring ? "Stop" : "Start"} Monitoring")
                          )
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(child:
                          FilledButton.tonal(
                            onPressed: () async {
                              if (_isRanging) {
                                await _beaconManager.stopRanging();
                                setState(() { _isRanging = false; });
                              } else {
                                await _beaconManager.startRanging();
                                setState(() { _isRanging = true; });
                              }
                            },
                            child: Text("${_isRanging ? "Stop" : "Start"} Ranging")
                          )
                        )
                      ] : [
                        Expanded(child:
                          FilledButton.tonal(
                            onPressed: () {
                              _permissionManager.requestPermissions().then((value) {
                                setState(() {
                                  _isPermissionGranted = value.values.every((element) => element == PermissionStatus.granted);
                                });
                              });
                            },
                            child: const Text("Grant permissions")
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            ),
          ]
        )
      )
    );
  }
}
