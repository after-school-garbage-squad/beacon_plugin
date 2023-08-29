# beacon_plugin

Beacon scanning library for Re:paint app on iOS / Android

## How to use

### プラグインを追加

pubspec.yamlに以下を記述

```pubspec.yaml
dependencies:
  flutter_sample_plugin:
    git:
      url: git@github.com:xxxxx/flutter_sample_plugin.git
      ref: HEAD

```

次に以下のコマンドを実行

```shell
flutter pub upgrade
```

### プラグインの使用

#### 必要な権限

必要な権限がiOSとAndroidで違います。

共通

- Permission.bluetooth
- Permission.location
- Permission.locationWhenInUse
- Permission.locationAlways

Androidのみ

- Permission.bluetoothScan

iOSのみ

- 特になし

#### 実行

bluetoothをONにした状態で使用してください。

##### スキーマ

BeaconDataとして、以下が定義されています。

```dart
class BeaconData {
  String? serviceUUID;
  String? hwid;
  double? rssi;
}
```

次のようにして、スキャンを開始します。

コールバック用の関数を定義

```dart
void onScanned(List<BeaconData?> beaconDataList) {
  final List<BeaconData> bl = beaconDataList.whereType<BeaconData>().toList();
  for (var element in bl) {
    print(element.hwid)
  }
}
```

スキャンを開始

```dart
final BeaconManager beaconManager = BeaconPlugin.beaconManager

// スキャン対象のビーコンのServiceUUIDを指定(LINE Simple Beaconの場合はFE6F)
beaconManager.setBeaconServiceUUIDs(["FE6F"]);

// ビーコンを検出したときのコールバックを設定
FlutterBeaconApi.setup(FlutterBeaconApiImpl(onScanned));

// スキャン開始
beaconManager.startScanning();

```

スキャンを停止

```dart
beaconManager.stopScanning();
```
