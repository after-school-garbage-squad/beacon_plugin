package dev.asgs.beacon_plugin

import BeaconManagerApi
import android.app.Activity
import android.content.Context
import android.os.Build
import android.util.Log
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
  ActivityAware {

  private lateinit var activity: Activity
  private lateinit var context: Context

  private val beaconManagerApi: BeaconManagerApiImpl by lazy { BeaconManagerApiImpl(context) }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("BeaconPlugin", "onAttachedToEngine")
    context = binding.applicationContext

    BeaconManagerApiImpl.setupBackgroundScanJob()
    BeaconManagerApi.setUp(
      binaryMessenger = binding.binaryMessenger,
      api = beaconManagerApi
    )
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    Log.d("BeaconPlugin", "onDetachedFromEngine")
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    Log.d("BeaconPlugin", "onMethodCall")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d("BeaconPlugin", "onAttachedToActivity")
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.d("BeaconPlugin", "onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d("BeaconPlugin", "onReattachedToActivityForConfigChanges")
  }

  override fun onDetachedFromActivity() {
    Log.d("BeaconPlugin", "onDetachedFromActivity")
  }

}
