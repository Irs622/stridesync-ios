import Testing
import Foundation
@testable import StrideSync

@Suite("Bluetooth BLE Sports Sensor Packet Decoding Tests")
struct BLESensorTests {
    
    @Test("Test GATT 0x2A37 Heart Rate 8-bit parsing")
    func testHeartRate8BitParsing() {
        // Flag byte: 0x00 (8-bit HR), Heart Rate: 142 bpm
        let packet = Data([0x00, 142])
        let hr = BLEHeartRateAndSensorManager.parseHeartRateMeasurement(from: packet)
        #expect(hr == 142)
    }
    
    @Test("Test GATT 0x2A37 Heart Rate 16-bit parsing")
    func testHeartRate16BitParsing() {
        // Flag byte: 0x01 (16-bit HR), Heart Rate: 185 bpm (0x00B9)
        let packet = Data([0x01, 0xB9, 0x00])
        let hr = BLEHeartRateAndSensorManager.parseHeartRateMeasurement(from: packet)
        #expect(hr == 185)
    }
    
    @Test("Test GATT 0x2A63 Cycling Power parsing")
    func testCyclingPowerParsing() {
        // Flags: 2 bytes, Instantaneous Power: 250 Watts (0x00FA)
        let packet = Data([0x00, 0x00, 0xFA, 0x00])
        let power = BLEHeartRateAndSensorManager.parseCyclingPowerMeasurement(from: packet)
        #expect(power == 250)
    }
}

