import Foundation
@preconcurrency import CoreBluetooth

/// Manager handling discovery, connection, and GATT telemetry packet decoding for external Bluetooth sports sensors.
@Observable
@MainActor
public final class BLEHeartRateAndSensorManager: NSObject {
    public static let shared = BLEHeartRateAndSensorManager()
    
    // Bluetooth SIG Assigned Standard UUIDs
    public nonisolated static let heartRateServiceUUIDString = "180D"
    public nonisolated static let heartRateMeasurementUUIDString = "2A37"
    
    public nonisolated static let cyclingSpeedCadenceServiceUUIDString = "1816"
    public nonisolated static let cscMeasurementUUIDString = "2A5B"
    
    public nonisolated static let cyclingPowerServiceUUIDString = "1818"
    public nonisolated static let powerMeasurementUUIDString = "2A63"
    
    public nonisolated static let batteryServiceUUIDString = "180F"
    public nonisolated static let batteryLevelUUIDString = "2A19"
    
    public var isScanning: Bool = false
    public var discoveredDevices: [BLESensorDevice] = []
    public var connectedDevices: [BLESensorDevice] = []
    public var latestTelemetry: BLETelemetryData = BLETelemetryData()
    
    public var onHeartRateUpdate: ((Int) -> Void)?
    
    private var centralManager: CBCentralManager?
    private var connectedPeripherals: [UUID: CBPeripheral] = [:]
    
    public override init() {
        super.init()
        #if !os(watchOS)
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        #endif
    }
    
    public func startScan() {
        guard let cm = centralManager, cm.state == .poweredOn else { return }
        isScanning = true
        discoveredDevices.removeAll()
        cm.scanForPeripherals(
            withServices: [
                CBUUID(string: Self.heartRateServiceUUIDString),
                CBUUID(string: Self.cyclingSpeedCadenceServiceUUIDString),
                CBUUID(string: Self.cyclingPowerServiceUUIDString)
            ],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    public func stopScan() {
        centralManager?.stopScan()
        isScanning = false
    }
    
    public func connect(to device: BLESensorDevice) {
        #if !os(watchOS)
        if let peripheral = connectedPeripherals[device.id] {
            centralManager?.connect(peripheral, options: nil)
        }
        #endif
    }
    
    public func disconnect(device: BLESensorDevice) {
        #if !os(watchOS)
        if let peripheral = connectedPeripherals[device.id] {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        #endif
        connectedDevices.removeAll(where: { $0.id == device.id })
    }
    
    // MARK: - Binary GATT Packet Decoders (Static & Testable)
    
    /// Decodes GATT 0x2A37 Heart Rate Measurement byte stream.
    /// Bit 0 of Flag byte: 0 = UINT8 HR, 1 = UINT16 HR.
    public nonisolated static func parseHeartRateMeasurement(from data: Data) -> Int? {
        guard data.count >= 2 else { return nil }
        let flags = data[0]
        let is16Bit = (flags & 0x01) != 0
        
        if is16Bit {
            guard data.count >= 3 else { return nil }
            let hrValue = UInt16(data[1]) | (UInt16(data[2]) << 8)
            return Int(hrValue)
        } else {
            return Int(data[1])
        }
    }
    
    /// Decodes GATT 0x2A63 Cycling Power Instantaneous Power (Watts).
    /// Bytes 2-3 represent 16-bit signed integer watts.
    public nonisolated static func parseCyclingPowerMeasurement(from data: Data) -> Int? {
        guard data.count >= 4 else { return nil }
        let rawWatts = Int16(data[2]) | (Int16(data[3]) << 8)
        return max(0, Int(rawWatts))
    }
}

#if !os(watchOS)
extension BLEHeartRateAndSensorManager: @preconcurrency CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Handle central state transitions
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Sports Sensor"
        let device = BLESensorDevice(
            id: peripheral.identifier,
            name: name,
            sensorType: .heartRate,
            isConnected: false,
            rssi: RSSI.intValue
        )
        
        self.connectedPeripherals[peripheral.identifier] = peripheral
        if !self.discoveredDevices.contains(where: { $0.id == device.id }) {
            self.discoveredDevices.append(device)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([
            CBUUID(string: Self.heartRateServiceUUIDString),
            CBUUID(string: Self.cyclingSpeedCadenceServiceUUIDString),
            CBUUID(string: Self.cyclingPowerServiceUUIDString),
            CBUUID(string: Self.batteryServiceUUIDString)
        ])
        
        if let index = self.discoveredDevices.firstIndex(where: { $0.id == peripheral.identifier }) {
            var dev = self.discoveredDevices[index]
            dev.isConnected = true
            self.connectedDevices.append(dev)
        }
    }
}

extension BLEHeartRateAndSensorManager: @preconcurrency CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        if characteristic.uuid == CBUUID(string: Self.heartRateMeasurementUUIDString) {
            if let hr = Self.parseHeartRateMeasurement(from: data) {
                self.latestTelemetry.heartRateBpm = hr
                self.onHeartRateUpdate?(hr)
            }
        } else if characteristic.uuid == CBUUID(string: Self.powerMeasurementUUIDString) {
            if let power = Self.parseCyclingPowerMeasurement(from: data) {
                self.latestTelemetry.powerWatts = power
            }
        }
    }
}
#endif

