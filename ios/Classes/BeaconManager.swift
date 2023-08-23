import CoreLocation
import CoreBluetooth
import Flutter

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate
{
  var beaconServiceUUIDs: [CBUUID] = []
  var wantScan = false

  let centralManager = CBCentralManager()

  func setBeaconServiceUUIDs(beaconServiceUUIDs: [String]) {
    self.beaconServiceUUIDs = beaconServiceUUIDs.map { CBUUID(string: $0) }
  }

  func startScan(){
    wantScan = true
    if(centralManager.state == CBManagerState.poweredOn){
      centralManager.scanForPeripherals(withServices: beaconServiceUUIDs, options: nil)
    }
  }

  func stopScan(){
    centralManager.stopScan()
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if(central.state == CBManagerState.poweredOn){
      if(wantScan){
        startScan()
      }
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var beaconDataList: [BeaconData] = []
        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for (serviceUUID, data) in serviceData {
              for uuid in beaconServiceUUIDs{
                if serviceUUID == uuid {
                    let frameType = data[0]
                    if frameType == 0x02 {
                        let hwid = data.subdata(in: 1..<6)
                        let hwidStr = hwid.map { String(format: "%02X", $0) }.joined()
                        if let beaconData = BeaconData.fromList([uuid.uuidString, hwidStr]) {
                          beaconDataList.append(beaconData)
                        }
                    }
                }
              }
            }
        }

        BeaconPlugin.flutterBeaconApi?.onScanned(beaconDataList: beaconDataList) {
            // do nothing
        }
    }
}
