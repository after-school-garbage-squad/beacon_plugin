package dev.asgs.beacon_plugin

import BeaconManagerApi
import FlutterBeaconApi
import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.RemoteException
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

@RequiresApi(Build.VERSION_CODES.O)
class BeaconPlugin: FlutterPlugin,
  MethodCallHandler,
  ActivityAware,
  BeaconManagerApi {

  private lateinit var activity: Activity
  private lateinit var context: Context

  private val beaconManager by lazy { BeaconManager(context) }

  companion object {
    lateinit var flutterBeaconApi: FlutterBeaconApi
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext

    flutterBeaconApi = FlutterBeaconApi(binding.binaryMessenger)

    BeaconManager.setupBackgroundScanJob()
    BeaconManagerApi.setUp(
      binaryMessenger = binding.binaryMessenger,
      api = this
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    BeaconManagerApi.setUp(
      binaryMessenger = binding.binaryMessenger,
      api = null
    )
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onDetachedFromActivity() {
  }

  override fun setBeaconServiceUUIDs(uuid: List<String>, callback: (Result<Unit>) -> Unit) {
    try {
      callback(Result.success(beaconManager.setBeaconServiceUUIDs(uuid)))
    } catch (e: RemoteException) {
      callback(Result.failure(e))
    }
  }

  override fun startScan(callback: (Result<Unit>) -> Unit) {
    try {
      callback(Result.success(beaconManager.startScan()))
    } catch (e: RemoteException) {
      callback(Result.failure(e))
    }
  }

  override fun stopScan(callback: (Result<Unit>) -> Unit) {
    try {
      callback(Result.success(beaconManager.stopScan()))
    } catch (e: RemoteException) {
      callback(Result.failure(e))
    }
  }

}
