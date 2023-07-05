package dev.asgs.beacon_plugin

import BeaconData
import BeaconManagerApi
import RegionData
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.RemoteException
import android.text.TextUtils
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.lifecycle.Observer
import org.altbeacon.beacon.Beacon
import org.altbeacon.beacon.BeaconManager
import org.altbeacon.beacon.BeaconParser
import org.altbeacon.beacon.Identifier
import org.altbeacon.beacon.MonitorNotifier
import org.altbeacon.beacon.Region
import org.altbeacon.beacon.RegionViewModel
import org.altbeacon.beacon.service.scanner.NonBeaconLeScanCallback
import kotlin.random.Random

@RequiresApi(Build.VERSION_CODES.O)
class BeaconManagerApiImpl(
    private val context: Context
) : BeaconManagerApi {
    private val beaconManager = BeaconManager.getInstanceForApplication(context)
    // Android: key of beaconDatas is the device address
    // iOS: key of beaconDatas is hwid
    private val beaconDatas: MutableMap<String, BeaconData> = mutableMapOf()
    private var regionData: RegionData = RegionData(
        uuid = region.id1.toString(),
        major = region.id2.toString(),
        minor = region.id3.toString(),
        state = null
    )

    private val regionViewModel: RegionViewModel = beaconManager.getRegionViewModel(region)

    private val centralMonitoringObserver = Observer<Int> { state ->
        regionData = regionData.copy(state = state.toLong())
        val stateText = when (state) {
            MonitorNotifier.INSIDE -> "INSIDE"
            MonitorNotifier.OUTSIDE -> "OUTSIDE"
            else -> throw IllegalArgumentException("Unknown state: $state")
        }
        Log.d(TAG, "Monitoring: $stateText")
        if (isNotificationInitialized == true) {
            val notification = Notification.Builder(context, notificationChannelId)
                .setContentTitle("Beacon Plugin")
                .setContentText("Monitoring: $stateText")
                .setSmallIcon(notificationIcon!!)
                .build()
            notificationManager!!.notify(Random.nextInt(), notification)
        }
    }

    private val centralRangingObserver = Observer<Collection<Beacon>> { beacons ->
        Log.d(TAG, "Ranged: ${beacons.count()} beacons")
        beaconDatas
            .filterNot { beaconData ->
                beacons.map { beacon -> beacon.bluetoothAddress }
                    .contains(beaconData.key)
            }
            .forEach { beaconData -> beaconDatas.remove(beaconData.key) }
        for (beacon: Beacon in beacons) {
            beaconDatas[beacon.bluetoothAddress] = beaconDatas.getOrDefault(beacon.bluetoothAddress, BeaconData()).copy(
                uuid = beacon.id1.toString(),
                major = beacon.id2.toString(),
                minor = beacon.id3.toString(),
                rssi = beacon.rssi.toLong(),
                proximity = when (beacon.distance) {
                    in 0.0..1.0 -> 1
                    in 1.0..3.0 -> 2
                    else -> 3
                }.toLong()
            )
            Log.d(TAG, "$beacon about ${beacon.distance} meters away")
        }
    }

    init {
        beaconManager.beaconParsers.clear()
        beaconManager.beaconParsers.add(iBeaconParser)
        Beacon.setHardwareEqualityEnforced(true)
        beaconManager.nonBeaconLeScanCallback =
            NonBeaconLeScanCallback { device, rssi, scanRecord ->
                val hwid = convertHwid(scanRecord)
                if (hwid != null) {
                    beaconDatas[device.address] = beaconDatas
                        .getOrDefault(device.address, BeaconData())
                        .copy(hwid = hwid)
                    Log.d(TAG, "NonBeaconLeScan.  Device=$device rssi=$rssi hwid=$hwid")
                }
            }

        beaconManager.foregroundBetweenScanPeriod = (foregroundBetweenScanPeriod ?: 0).toLong()
        beaconManager.foregroundScanPeriod = (foregroundScanPeriod ?: 1100).toLong()

        if (isBackgroundEnabled == true) {
            beaconManager.setEnableScheduledScanJobs(isScheduledScanJobEnabled ?: false)
            beaconManager.backgroundBetweenScanPeriod = (backgroundBetweenScanPeriod ?: 0).toLong()
            beaconManager.backgroundScanPeriod = (backgroundScanPeriod ?: 1100).toLong()
        }

        regionViewModel.regionState.observeForever(centralMonitoringObserver)
        regionViewModel.rangedBeacons.observeForever(centralRangingObserver)
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

    override fun startMonitoring(callback: (Result<Unit>) -> Unit) {
        try {
            callback(Result.success(beaconManager.startMonitoring(region)))
        } catch (e: RemoteException) {
            callback(Result.failure(e))
        }
    }

    override fun stopMonitoring(callback: (Result<Unit>) -> Unit) {
        try {
            callback(Result.success(beaconManager.stopMonitoring(region)))
        } catch (e: RemoteException) {
            callback(Result.failure(e))
        }
    }

    override fun getMonitoredRegion(callback: (Result<RegionData?>) -> Unit) {
        callback(Result.success(regionData))
    }

    override fun startRanging(callback: (Result<Unit>) -> Unit) {
        try {
            callback(Result.success(beaconManager.startRangingBeacons(region)))
        } catch (e: RemoteException) {
            callback(Result.failure(e))
        }
    }

    override fun stopRanging(callback: (Result<Unit>) -> Unit) {
        try {
            callback(Result.success(beaconManager.stopRangingBeacons(region)))
        } catch (e: RemoteException) {
            callback(Result.failure(e))
        }
    }

    override fun getRangedBeacons(callback: (Result<List<BeaconData?>?>) -> Unit) {
        val filteredBeaconDatas = beaconDatas.values.toList()
        /*
        .filter {
            it.uuid != null &&
            it.major != null &&
            it.minor != null &&
            it.rssi != null &&
            it.proximity != null &&
            it.hwid != null
        }
         */

        callback(Result.success(filteredBeaconDatas))
    }

    override fun startForegroundService(callback: (Result<Unit>) -> Unit) {
        if (isBackgroundEnabled == true) {
            if (isNotificationInitialized == true) {
                val notification = Notification.Builder(context, notificationChannelId)
                    .setContentTitle("Scanning for Beacons")
                    .setContentText("This app is scanning for beacons.")
                    .setSmallIcon(notificationIcon!!)
                    .build()
                notificationManager!!.notify(2, notification)
                beaconManager.enableForegroundServiceScanning(notification, notificationId!!)
                callback(Result.success(Unit))
            } else {
                callback(Result.failure(Exception("setupNotification() is not called")))
            }
        } else {
            callback(Result.failure(Exception("Background is not enabled")))
        }
    }

    override fun stopForegroundService(callback: (Result<Unit>) -> Unit) {
        if (isBackgroundEnabled == true && isNotificationInitialized == true) {
            beaconManager.disableForegroundServiceScanning()
            callback(Result.success(Unit))
        } else {
            callback(Result.failure(Exception("Background is not enabled")))
        }
    }

    companion object {
        const val TAG = "BeaconManager"

        val iBeaconParser: BeaconParser =
            BeaconParser().setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24")

        val region = Region(
            "LINEBeacon",
            Identifier.parse("D0D2CE24-9EFC-11E5-82C4-1C6A7A17EF38"),
            Identifier.parse("0x4C49"),
            Identifier.parse("0x4E45")
        )

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