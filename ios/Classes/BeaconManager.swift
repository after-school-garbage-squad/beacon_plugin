import CoreBluetooth
import CoreLocation
import Flutter

class BeaconManager: NSObject, ObservableObject, CBCentralManagerDelegate {
  var beaconServiceUUIDs: [CBUUID] = []
  var wantScan = false

  var centralManager: CBCentralManager?

  override init() {
    super.init()
  }

  func setBeaconServiceUUIDs(beaconServiceUUIDs: [String]) {
    self.beaconServiceUUIDs = beaconServiceUUIDs.map { CBUUID(string: $0) }
    if self.centralManager?.isScanning == true {
      self.stopScan()
      self.startScan()
    }
  }

  func startScan() {
    wantScan = true
    if(centralManager == nil) {
      centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    if centralManager?.state == CBManagerState.poweredOn && !(self.centralManager?.isScanning == true) {
      centralManager?.scanForPeripherals(withServices: beaconServiceUUIDs, options: nil)
    }
  }

  func stopScan() {
    if self.centralManager?.isScanning == true {
      centralManager?.stopScan()
    }
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == CBManagerState.poweredOn {
      if wantScan {
        startScan()
      }
    }
  }

  func centralManager(
    _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any], rssi rssi: NSNumber
  ) {
    if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
      for (serviceUUID, data) in serviceData {
        let frameType = data[0]
        for uuid in beaconServiceUUIDs {
          if serviceUUID == uuid && frameType == 0x02 {
            let hwid = data.subdata(in: 1..<6)
            let hwidStr = hwid.map { String(format: "%02X", $0) }.joined()
            if let beaconData = BeaconData.fromList([uuid.uuidString, hwidStr, rssi]) {
              BeaconPlugin.flutterBeaconApi?.onScanned(beaconData: beaconData) {}
            }
          }
        }
      }
    }
  }
}
