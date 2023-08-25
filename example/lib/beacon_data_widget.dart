import 'package:beacon_plugin_example/beacon_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeaconDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BeaconDataListController>(
        builder: (context, beaconDataListController, child) {
      final beaconDataList = beaconDataListController.beaconDataList;

      return Column(
        children: beaconDataList.map((beaconData) {
          return Card(
              child: ListTile(
                  title: Text("HWID: ${beaconData.hwid ?? "Scanning..."}"),
                  subtitle: Text(
                      "ServiceUUID: ${beaconData.serviceUUID}\nrssi: ${beaconData.rssi}")));
        }).toList(),
      );
    });
  }
}
