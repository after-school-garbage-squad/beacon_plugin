import Flutter
import UIKit

public class BeaconPlugin: NSObject, FlutterPlugin {
  var beaconManager: BeaconManager!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "beacon_plugin", binaryMessenger: registrar.messenger())
    let instance = BeaconPlugin()
    beaconManager = BeaconManager()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
