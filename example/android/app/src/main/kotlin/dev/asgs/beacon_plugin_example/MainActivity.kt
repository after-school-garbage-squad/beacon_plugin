package dev.asgs.beacon_plugin_example

import BeaconManagerApi
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.multidex.MultiDex
import dev.asgs.beacon_plugin.BeaconManagerApiImpl
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import org.altbeacon.beacon.BeaconManager

class MainActivity: FlutterActivity() {
    private var beaconManager: BeaconManager? = null

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BeaconManagerApiImpl.setupBackgroundScanJob()
        BeaconManagerApiImpl.setupNotification(
            notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager,
            notificationId = 777,
            notificationChannelId = "beacon_plugin_example",
            notificationIcon = R.drawable.ic_android
        )
        BeaconManagerApi.setUp(
            binaryMessenger = flutterEngine.dartExecutor.binaryMessenger,
            api = BeaconManagerApiImpl(this.applicationContext)
        )
    }
}
