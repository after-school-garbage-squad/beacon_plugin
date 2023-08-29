package dev.asgs.beacon_plugin_example

import android.app.NotificationManager
import android.content.Context
import androidx.multidex.MultiDex
import dev.asgs.beacon_plugin.BeaconManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        BeaconManager.setupNotification(
            notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager,
            notificationId = 777,
            notificationChannelId = "beacon_plugin_example",
            notificationIcon = R.drawable.ic_android
        )
    }
}
