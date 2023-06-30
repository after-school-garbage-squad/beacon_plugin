package dev.asgs.beacon_plugin

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.altbeacon.beacon.BeaconManager

@RequiresApi(Build.VERSION_CODES.O)
class BeaconPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var context: Context
  private lateinit var beaconManager: BeaconManager
  private lateinit var beaconManagerApi: BeaconManagerApiImpl
  private var foregroundBetweenScanPeriod: Int? = null
  private var foregroundScanPeriod: Int? = null
  private var isBackgroundEnabled: Boolean? = null
  private var isScheduledScanJobEnabled: Boolean? = null
  private var backgroundBetweenScanPeriod: Int? = null
  private var backgroundScanPeriod: Int? = null

  fun setupForegroundScanJob(
    foregroundBetweenScanPeriod: Int? = null,
    foregroundScanPeriod: Int? = null,
  ) {
    this.foregroundBetweenScanPeriod = foregroundBetweenScanPeriod
    this.foregroundScanPeriod = foregroundScanPeriod
  }

  fun setupBackgroundScanJob(
    isScheduledScanJobEnabled: Boolean? = null,
    backgroundBetweenScanPeriod: Int? = null,
    backgroundScanPeriod: Int? = null
  ) {
    this.isBackgroundEnabled = true
    this.isScheduledScanJobEnabled = isScheduledScanJobEnabled
    this.backgroundBetweenScanPeriod = backgroundBetweenScanPeriod
    this.backgroundScanPeriod = backgroundScanPeriod
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    beaconManager = BeaconManager.getInstanceForApplication(context)
    beaconManagerApi = BeaconManagerApiImpl(
      beaconManager,
      foregroundBetweenScanPeriod,
      foregroundScanPeriod,
      isBackgroundEnabled,
      isScheduledScanJobEnabled,
      backgroundBetweenScanPeriod,
      backgroundScanPeriod
    )
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "startMonitoring" -> beaconManagerApi.startMonitoring { }
      "stopMonitoring" -> beaconManagerApi.stopMonitoring { }
      "getMonitoringRegion" -> beaconManagerApi.getMonitoredRegion { }
      "startRanging" -> beaconManagerApi.startRanging { }
      "stopRanging" -> beaconManagerApi.stopRanging { }
      "getRangingBeacons" -> beaconManagerApi.getRangedBeacons { }
      "startForegroundService" -> beaconManagerApi.startForegroundService { }
      "stopForegroundService" -> beaconManagerApi.stopForegroundService { }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    beaconManagerApi.stopMonitoring { }
    beaconManagerApi.stopRanging { }
    beaconManagerApi.stopForegroundService { }
  }
}
