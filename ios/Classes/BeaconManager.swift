/*
 * Source: https://github.com/after-school-garbage-squad/poc-for-repaint/blob/main/BLE%20test/BeaconView.swift
 */

import CoreLocation
import UserNotifications

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  let constraint = CLBeaconIdentityConstraint(
    uuid: UUID(uuidString: "d0d2ce24-9efc-11e5-82c4-1c6a7a17ef38")!)

  var customLocationManager: CLLocationManager!
  var customBeaconRegion: CLBeaconRegion!
  var beaconUuids: NSMutableArray!
  var beaconDetails: NSMutableArray!

  override init() {
    super.init()

    customLocationManager = CLLocationManager()
    customLocationManager.delegate = self
    customLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    customLocationManager.distanceFilter = 1

    customLocationManager.allowsBackgroundLocationUpdates = true

    customLocationManager.pausesLocationUpdatesAutomatically = false

    let status = customLocationManager.authorizationStatus
    print("CLAuthorizedStatus: \(status.rawValue)")
    if status == .notDetermined {
      customLocationManager.requestAlwaysAuthorization()
    }
    beaconUuids = NSMutableArray()
    beaconDetails = NSMutableArray()

    customLocationManager.startUpdatingLocation()

    customLocationManager.requestWhenInUseAuthorization()
  }

  public func startCustomMonitoring() {
    let identifierStr: String = "abcde1"
    customBeaconRegion = CLBeaconRegion(uuid: constraint.uuid, identifier: identifierStr)
    customBeaconRegion.notifyEntryStateOnDisplay = false
    customBeaconRegion.notifyOnEntry = true
    customBeaconRegion.notifyOnExit = true
    customLocationManager.startMonitoring(for: customBeaconRegion)
  }

  public func stopCustomMonitoring() {
    customLocationManager.stopMonitoring(for: customBeaconRegion)
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    print("didChangeAuthorizationStatus")

    switch status {
    case .notDetermined:
      print("not determined")
      break
    case .restricted:
      print("restricted")
      break
    case .denied:
      print("denied")
      break
    case .authorizedAlways:
      print("authorizedAlways")
      startCustomMonitoring()
      break
    case .authorizedWhenInUse:
      print("authorizedWhenInUse")
      startCustomMonitoring()
      break
    @unknown default:
      print("def")
      break
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didStartMonitoringFor region: CLRegion
  ) {
    manager.requestState(for: region)
  }

  func locationManager(
    _ manager: CLLocationManager,
    didDetermineState state: CLRegionState,
    for region: CLRegion
  ) {
    switch state {
    case .inside:
      print("iBeacon inside")
      // manager.startRangingBeacons(satisfying: constraint)
      sendNotification(title: "inside", body: region.identifier)
      break
    case .outside:
      print("iBeacon outside")
      sendNotification(title: "outside", body: region.identifier)
      break
    case .unknown:
      print("iBeacon unknown")
      break
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didRangeBeacons beacons: [CLBeacon],
    in region: CLBeaconRegion
  ) {
    beaconUuids = NSMutableArray()
    beaconDetails = NSMutableArray()
    if beacons.count > 0 {
      for i in 0..<beacons.count {
        let beacon = beacons[i]
        let beaconUUID = beacon.uuid
        let minorID = beacon.minor
        let majorID = beacon.major
        let rssi = beacon.rssi
        var proximity = ""

        switch beacon.proximity {
        case CLProximity.unknown:
          print("Proximity: Unknown")
          proximity = "Unknown"
          break
        case CLProximity.far:
          print("Proximity: Far")
          proximity = "Far"
          break
        case CLProximity.near:
          print("Proximity: Near")
          proximity = "Near"
          break
        case CLProximity.immediate:
          print("Proximity: Immediate")
          proximity = "Immediate"
          break
        @unknown default:
          break
        }

        beaconUuids.add(beaconUUID.uuidString)
        var customBeaconDetails = "Major: \(majorID) "
        customBeaconDetails += "Minor: \(minorID) "
        customBeaconDetails += "Proximity:\(proximity) "
        customBeaconDetails += "RSSI:\(rssi)"
        print(customBeaconDetails)
        beaconDetails.add(customBeaconDetails)
        sendNotification(title: proximity, body: customBeaconDetails)
        // label1.text = proximity
      }
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didEnterRegion region: CLRegion
  ) {
    print("didEnterRegion: iBeacon found")
    manager.startRangingBeacons(satisfying: constraint)
  }

  func locationManager(
    _ manager: CLLocationManager,
    didExitRegion region: CLRegion
  ) {
    print("didExitRegion: iBeacon lost")
    manager.stopRangingBeacons(satisfying: constraint)
  }
    
  func sendNotification(title: String, body: String, interval: Double = 1) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
    let request = UNNotificationRequest(identifier: "notification02", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request)
  }
}
