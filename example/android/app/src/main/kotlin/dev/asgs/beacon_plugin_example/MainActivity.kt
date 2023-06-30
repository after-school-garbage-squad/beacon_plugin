package dev.asgs.beacon_plugin_example

import BeaconManagerApi
import android.os.Build
import androidx.annotation.RequiresApi
import dev.asgs.beacon_plugin.BeaconManagerApiImpl
import dev.asgs.beacon_plugin.BeaconPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import org.altbeacon.beacon.BeaconManager

class MainActivity: FlutterActivity() {
    @RequiresApi(Build.VERSION_CODES.O)
    private var beaconPlugin: BeaconPlugin? = null
    private var beaconManager: BeaconManager? = null

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        beaconPlugin = BeaconPlugin()
        beaconManager = BeaconManager.getInstanceForApplication(this)

        BeaconManagerApi.setUp(
            binaryMessenger = flutterEngine.dartExecutor.binaryMessenger,
            BeaconManagerApiImpl(beaconManager!!)
        )
    }
}
