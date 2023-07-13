import Flutter
import UIKit

public class BeaconPlugin : NSObject, FlutterPlugin, BeaconManagerApi {
    func startMonitoring(completion: @escaping (Result<Void, Error>) -> Void) {
        return
    }
    
    func stopMonitoring(completion: @escaping (Result<Void, Error>) -> Void) {
        return
    }
    
    func getMonitoredRegion(completion: @escaping (Result<RegionData?, Error>) -> Void) {
        return
    }
    
    func startRanging(completion: @escaping (Result<Void, Error>) -> Void) {
        return
    }
    
    func stopRanging(completion: @escaping (Result<Void, Error>) -> Void) {
        return
    }
    
    func getRangedBeacons(completion: @escaping (Result<[BeaconData?]?, Error>) -> Void) {
        return
    }
    
    func startForegroundService(completion: @escaping (Result<Void, Error>) -> Void) {
        return
    }
    
    func stopForegroundService(completion: @escaping (Result<Void, Error>) -> Void) {
        return
    }
    
  var beaconManagaer: BeaconManager = BeaconManager()
  var bluetoothManager: BluetoothManager = BluetoothManager()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
      BeaconManagerApiSetup.setUp(binaryMessenger: registrar.messenger(), api: BeaconPlugin.init())
  }
}
