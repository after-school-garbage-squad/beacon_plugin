import 'package:beacon_plugin/pigeon.dart';
import 'package:beacon_plugin_example/beacon_data_widget.dart';
import 'package:flutter/widgets.dart';

class BeaconDataListController with ChangeNotifier {
  List<BeaconVisibleData> _beaconDataList = [];

  List<BeaconVisibleData> get beaconDataList => _beaconDataList;

  void setBeaconDataList(List<BeaconVisibleData> beaconDataList) {
    _beaconDataList = beaconDataList;
    notifyListeners();
  }
}
