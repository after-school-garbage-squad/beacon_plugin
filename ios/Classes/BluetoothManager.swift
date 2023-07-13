import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    @Published public var scannedPeripherals: [CBPeripheral] = []
    var timer: Timer?
    
    let serviceUUIDs = [CBUUID(string: "FE6F")]
    
    @Published public var isUseFilter = true
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        // Start timer to automatically broadcast and scan every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            // self.startBroadcasting()
            self.startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Add discovered peripheral to scannedPeripherals array
        if !scannedPeripherals.contains(peripheral) {
            scannedPeripherals.append(peripheral)
        }

        if let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data] {
            for (serviceUUID, data) in serviceData {
                if serviceUUID.uuidString == "FE6F" {
                    let frameType = data[0]
                    if frameType == 0x02 {
                        let hwid = data.subdata(in: 1..<6)
                        let hwidString = hwid.map { String(format: "%02X", $0) }.joined()
                        sendNotification(title: "LINE Beacon", body: hwidString)
                        print("LINE Simple Beacon HWID: \(hwidString)")
                    }
                }
            }
        }
        
        /*
        let url = URL(string: "http://192.168.0.171:3000/")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
        }.resume()
         */
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Bluetooth is ready to use
            startScanning()
        } else {
            // Bluetooth is not available
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            // Bluetooth is ready to use
            //startBroadcasting()
        } else {
            // Bluetooth is not available
        }
    }
    
    func startScanning() {
        // Start scanning for Bluetooth devices
        // print("scan")
        if(isUseFilter){
            centralManager.scanForPeripherals(withServices: serviceUUIDs, options: nil)
        }else{
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    /*
    func startBroadcasting() {
        print("Broadcast")
        // Start broadcasting Bluetooth signal
        let service = CBMutableService(type: serviceUUID, primary: true)
        let characteristicUUID = CBUUID(string: "AED269A3-CFFE-D059-6A7A-3F27AE3A3E67")
        let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.read, .write], value: nil, permissions: [.readable, .writeable])
        service.characteristics = [characteristic]
        peripheralManager.add(service)
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
    }
     */
    
    func sendNotification(title: String, body: String, interval: Double = 1) {
      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body

      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
      let request = UNNotificationRequest(identifier: "notification01", content: content, trigger: trigger)

      UNUserNotificationCenter.current().add(request)
    }
}
