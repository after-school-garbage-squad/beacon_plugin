package dev.asgs.beacon_plugin

import BeaconData
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import androidx.annotation.RequiresApi
import org.altbeacon.beacon.Beacon
import org.altbeacon.beacon.BeaconManager
import org.altbeacon.beacon.BeaconParser
import org.altbeacon.beacon.Identifier
import org.altbeacon.beacon.Region
import org.altbeacon.beacon.service.scanner.NonBeaconLeScanCallback

@RequiresApi(Build.VERSION_CODES.O)
class BeaconManager(
    context: Context
) {
    private var beaconServiceUUIDs: List<String>? = null
    private var isScanning = false


    private val beaconManager = BeaconManager.getInstanceForApplication(context)
    private val handler = Handler(Looper.getMainLooper())

    init {
        beaconManager.beaconParsers.clear()
        beaconManager.beaconParsers.add(iBeaconParser)
        Beacon.setHardwareEqualityEnforced(true)
        beaconManager.nonBeaconLeScanCallback =
            NonBeaconLeScanCallback { device, rssi, scanRecord ->
                val hwid = convertHwid(scanRecord)
                if (hwid != null) {
                    val beaconData = BeaconData(
                        device.address,
                        hwid,
                        rssi.toDouble()
                    )
                    Log.d(TAG, "NonBeaconLeScan.  Device=$device rssi=$rssi hwid=$hwid")
                    handler.post {
                        BeaconPlugin.flutterBeaconApi.onScanned(listOf(beaconData)) {}
                    }
                }
            }

        beaconManager.foregroundBetweenScanPeriod = (foregroundBetweenScanPeriod ?: 0).toLong()
        beaconManager.foregroundScanPeriod = (foregroundScanPeriod ?: 1100).toLong()

        if (isBackgroundEnabled == true) {
            beaconManager.setEnableScheduledScanJobs(isScheduledScanJobEnabled ?: false)
            beaconManager.backgroundBetweenScanPeriod = (backgroundBetweenScanPeriod ?: 0).toLong()
            beaconManager.backgroundScanPeriod = (backgroundScanPeriod ?: 1100).toLong()
        }
    }

    private fun convertHwid(scanRecord: ByteArray): String? {
        return if (scanRecord[9] == 0x6F.toByte() && scanRecord[10] == 0xFE.toByte()) {
            TextUtils.join(
                "",
                scanRecord.sliceArray(12..16).map { "%02X".format(it) }
            )
        } else {
            null
        }
    }

    fun setBeaconServiceUUIDs(uuid: List<String>) {
        beaconServiceUUIDs = uuid
        if(isScanning) {
            stopScanning()
            startScanning()
        }
    }

    fun startScanning() {
        Log.d(TAG, "startScanning")
        isScanning = true
        val regions = beaconServiceUUIDs?.map {
            Region(
                it,
                Identifier.parse(it),
                null,
                null
            )
        } ?: listOf()
        for(region in regions) {
            beaconManager.startRangingBeacons(region)
        }
    }

    fun stopScanning() {
        Log.d(TAG, "stopScanning")
        isScanning = false
        val regions = beaconServiceUUIDs?.map {
            Region(
                it,
                Identifier.parse(it),
                null,
                null
            )
        } ?: listOf()
        for(region in regions) {
            beaconManager.startRangingBeacons(region)
        }
    }

    companion object {
        const val TAG = "BeaconManager"

        val iBeaconParser: BeaconParser =
            BeaconParser().setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24")

        private var notificationManager: NotificationManager? = null
        private var foregroundBetweenScanPeriod: Int? = null
        private var foregroundScanPeriod: Int? = null
        private var isBackgroundEnabled: Boolean? = null
        private var isScheduledScanJobEnabled: Boolean? = null
        private var backgroundBetweenScanPeriod: Int? = null
        private var backgroundScanPeriod: Int? = null
        private var isNotificationInitialized: Boolean? = null
        private var notificationId: Int? = null
        private var notificationChannel: NotificationChannel? = null
        private var notificationChannelId: String? = null
        private var notificationIcon: Int? = null

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
            this.isScheduledScanJobEnabled = isScheduledScanJobEnabled
            this.backgroundBetweenScanPeriod = backgroundBetweenScanPeriod
            this.backgroundScanPeriod = backgroundScanPeriod
            this.isBackgroundEnabled = true
        }

        fun setupNotification(
            notificationManager: NotificationManager,
            notificationId: Int,
            notificationChannelId: String,
            notificationIcon: Int
        ) {
            this.notificationManager = notificationManager
            this.notificationId = notificationId
            this.notificationChannel = NotificationChannel(
                notificationChannelId,
                "Beacon Plugin Example",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(notificationChannel!!)
            this.notificationChannelId = notificationChannelId
            this.notificationIcon = notificationIcon
            this.isNotificationInitialized = true
        }

    }
}
