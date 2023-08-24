import 'package:beacon_plugin/pigeon.dart';
import 'package:flutter/widgets.dart';

class BeaconDataListController with ChangeNotifier {
  List<BeaconData> _beaconDataList = [];

  List<BeaconData> get beaconDataList => _beaconDataList;

  void setBeaconDataList(List<BeaconData> beaconDataList) {
    this._beaconDataList = beaconDataList;
    notifyListeners();
  }
}
