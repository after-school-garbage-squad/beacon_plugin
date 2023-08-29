import 'package:beacon_plugin/pigeon.dart';
import 'package:beacon_plugin_example/beacon_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BeaconVisibleData{
  final BeaconData? beaconData;
  final DateTime? lastScanned;
  final List<double>? rssiHistory;

  BeaconVisibleData({this.beaconData, this.lastScanned, this.rssiHistory});
}

class BeaconDataWidget extends StatelessWidget {
  const BeaconDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BeaconDataListController>(
        builder: (context, beaconDataListController, child) {
      final beaconDataList = beaconDataListController.beaconDataList;
      final outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

      return SingleChildScrollView(child:Column(
        children: beaconDataList.map((beaconData) {
          return Card(child:ExpansionTile(
              title: ListTile(
                  title: Text("HWID: ${beaconData.beaconData?.hwid ?? "Scanning..."}"),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ServiceUUID: ${beaconData.beaconData?.serviceUUID}"),
                        Text("rssi: ${beaconData.beaconData?.rssi}"),
                        Text("Last scanned: ${outputFormat.format(beaconData.lastScanned!)}"),
                      ])),
              children: beaconData.rssiHistory?.map((e) => <Widget>[Text(e.toString()),const Divider()]).expand((i) => i).toList() ?? []
          ));
        }).toList(),
      ));
    });
  }
}
