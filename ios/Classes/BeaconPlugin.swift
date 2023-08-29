import Flutter

public class BeaconPlugin: NSObject, FlutterPlugin, BeaconManagerApi {

  let beaconManager = BeaconManager()
  static var flutterBeaconApi: FlutterBeaconApi?

  func setBeaconServiceUUIDs(uuid: [String], completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManager.setBeaconServiceUUIDs(beaconServiceUUIDs: uuid)))
  }

  func startScanning(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManager.startScanning()))
  }

  func stopScanning(completion: @escaping (Result<Void, Error>) -> Void) {
    completion(Result.success(beaconManager.stopScanning()))
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    BeaconManagerApiSetup.setUp(binaryMessenger: registrar.messenger(), api: BeaconPlugin.init())
    flutterBeaconApi = FlutterBeaconApi(binaryMessenger: registrar.messenger())
  }
}
