import 'package:beacon_plugin/pigeon.dart';
import 'package:beacon_plugin_example/beacon_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeaconVisibleData{
  final BeaconData? beaconData;
  final DateTime? lastScanned;

  BeaconVisibleData({this.beaconData, this.lastScanned});
}

class BeaconDataWidget extends StatelessWidget {
  const BeaconDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BeaconDataListController>(
        builder: (context, beaconDataListController, child) {
      final beaconDataList = beaconDataListController.beaconDataList;

      return Column(
        children: beaconDataList.map((beaconData) {
          return Card(
              child: ListTile(
                  title: Text("HWID: ${beaconData.beaconData?.hwid ?? "Scanning..."}"),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ServiceUUID: ${beaconData.beaconData?.serviceUUID}"),
                        Text("rssi: ${beaconData.beaconData?.rssi}"),
                        Text("Last scanned: ${beaconData.lastScanned}"),
                      ])));
        }).toList(),
      );
    });
  }
}
