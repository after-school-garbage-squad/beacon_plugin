import Flutter
import UIKit

public class BeaconPlugin: NSObject, FlutterPlugin, BeaconManagerApi {
  let beaconManagaer: BeaconManager = BeaconManager()
  let bluetoothManager: BluetoothManager = BluetoothManager()
  let beaconDatas: [String: BeaconData] = [String: BeaconData]()

  func startMonitoring(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManagaer.startCustomMonitoring()))
  }

  func stopMonitoring(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManagaer.stopCustomMonitoring()))
  }

  func getMonitoredRegion(completion: @escaping (Result<RegionData?, Error>) -> Void) {
    return
  }

  func startRanging(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManagaer.startRanging()))
  }

  func stopRanging(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManagaer.stopRanging()))
  }

  func getRangedBeacons(completion: @escaping (Result<[BeaconData?]?, Error>) -> Void) {
    let beaconDatas = beaconManagaer.beaconDatas
    completion(Result.success(beaconDatas))
  }

  func startForegroundService(completion: @escaping (Result<Void, Error>) -> Void) {
    return
  }

  func stopForegroundService(completion: @escaping (Result<Void, Error>) -> Void) {
    return
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    BeaconManagerApiSetup.setUp(binaryMessenger: registrar.messenger(), api: BeaconPlugin.init())
  }
}
