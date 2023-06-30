package dev.asgs.beacon_plugin

import BeaconData
import BeaconManagerApi
import RegionData
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
import org.altbeacon.beacon.Region
import org.altbeacon.beacon.RegionViewModel
import org.altbeacon.beacon.service.scanner.NonBeaconLeScanCallback

@RequiresApi(Build.VERSION_CODES.O)
class BeaconManagerApiImpl(
    private val beaconManager: BeaconManager,
    foregroundBetweenScanPeriod: Int? = null,
    foregroundScanPeriod: Int? = null,
    isBackgroundEnabled: Boolean? = null,
    isScheduledScanJobEnabled: Boolean? = null,
    backgroundBetweenScanPeriod: Int? = null,
    backgroundScanPeriod: Int? = null
) : BeaconManagerApi {
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
        if (state?.toLong() != regionData.state) {
            regionData = regionData.copy(state = state.toLong())
            Log.d(TAG, "Monitoring: $state")
        }
    }

    private val centralRangingObserver = Observer<Collection<Beacon>> { beacons ->
        Log.d(TAG, "Ranged: ${beacons.count()} beacons")
        for (beacon: Beacon in beacons) {
            if (beaconDatas[beacon.bluetoothAddress] != null) {
                beaconDatas[beacon.bluetoothAddress] = beaconDatas.getValue(beacon.bluetoothAddress).copy(
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
            } else {
                beaconDatas[beacon.bluetoothAddress] = BeaconData(
                    uuid = beacon.id1.toString(),
                    major = beacon.id2.toString(),
                    minor = beacon.id3.toString(),
                    rssi = beacon.rssi.toLong(),
                    proximity = when (beacon.distance) {
                        in 0.0..1.0 -> 1
                        in 1.0..3.0 -> 2
                        else -> 3
                    }.toLong(),
                    hwid = null
                )
            }
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
                    val beaconData = beaconDatas[device.address]
                    if (beaconData != null) {
                        beaconDatas[device.address] = beaconDatas.getOrDefault(device.address, BeaconData(
                            uuid = null,
                            major = null,
                            minor = null,
                            rssi = rssi.toLong(),
                            proximity = 0, // unknown
                            hwid = hwid
                        )).copy(rssi = rssi.toLong())
                    } else {
                        beaconDatas[device.address] =
                            BeaconData(
                                uuid = null,
                                major = null,
                                minor = null,
                                rssi = rssi.toLong(),
                                proximity = 0, // unknown
                                hwid = hwid
                            )
                    }
                    Log.d(TAG, "NonBeaconLeScan.  Device=$device rssi=$rssi hwid=$hwid")
                }
            }

        /*
            beaconManager.foregroundBetweenScanPeriod = (foregroundBetweenScanPeriod ?: 0).toLong()
            beaconManager.foregroundScanPeriod = (foregroundScanPeriod ?: 1100).toLong()

            if (isBackgroundEnabled == true) {
                beaconManager.setEnableScheduledScanJobs(isScheduledScanJobEnabled ?: false)
                beaconManager.backgroundBetweenScanPeriod = (backgroundBetweenScanPeriod ?: 0).toLong()
                beaconManager.backgroundScanPeriod = (backgroundScanPeriod ?: 1100).toLong()
            }
        */

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
        regionData = regionData.copy()
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
        val filteredBeaconDatas = beaconDatas.values
            .filter {
                it.uuid != null &&
                it.major != null &&
                it.minor != null &&
                it.rssi != null &&
                it.proximity != null &&
                it.hwid != null
            }

        callback(Result.success(filteredBeaconDatas))
    }

    override fun startForegroundService(callback: (Result<Unit>) -> Unit) {
        callback(Result.failure(Exception("setupNotificationBuilder() is not called")))
    }

    override fun stopForegroundService(callback: (Result<Unit>) -> Unit) {
        callback(Result.failure(Exception("setupNotificationBuilder() is not called")))
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
    }
}