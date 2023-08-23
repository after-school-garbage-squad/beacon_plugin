import Flutter

public class BeaconPlugin: NSObject, FlutterPlugin, BeaconManagerApi {

  let beaconManager = BeaconManager()
  static var flutterBeaconApi: FlutterBeaconApi? = nil
  
  func setBeaconServiceUUIDs(uuid: [String], completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManager.setBeaconServiceUUIDs(beaconServiceUUIDs: uuid)))
  }

  func startScan(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManager.startScan()))
  }

  func stopScan(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManager.stopScan()))
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    BeaconManagerApiSetup.setUp(binaryMessenger: registrar.messenger(), api: BeaconPlugin.init())
    flutterBeaconApi = FlutterBeaconApi(binaryMessenger: registrar.messenger())
  }
}
