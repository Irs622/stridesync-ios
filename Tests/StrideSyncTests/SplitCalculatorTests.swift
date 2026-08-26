import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("SplitCalculator Tests")
struct SplitCalculatorTests {
    
    @Test("Test 1-Kilometer Split Calculation")
    func testKilometerSplitCalculation() throws {
        let calculator = SplitCalculator(splitIntervalMeters: 1000.0)
        let baseTime = Date()
        
        // Generate simulated coordinates spanning > 2.5 km
        var points: [TelemetrySnapshot] = []
        let startLat = -6.175392
        let startLon = 106.827153
        
        // ~111,000 meters per degree latitude -> 0.009 deg ≈ 1 km
        for i in 0...30 {
            let lat = startLat + (Double(i) * 0.0009) // ~100m per step
            let time = baseTime.addingTimeInterval(Double(i) * 25.0) // 25s per 100m => 250s/km (4:10 /km pace)
            points.append(
                TelemetrySnapshot(
                    timestamp: time,
                    latitude: lat,
                    longitude: startLon,
                    altitude: 10.0 + Double(i),
                    speedMps: 4.0,
                    heartRate: 155
                )
            )
        }
        
        let splits = calculator.calculateSplits(from: points)
        #expect(splits.count >= 2)
        
        let firstSplit = splits[0]
        #expect(firstSplit.splitIndex == 1)
        #expect(firstSplit.distanceMeters >= 950.0)
        #expect(firstSplit.averagePaceSecondsPerKm > 0)
        #expect(firstSplit.formattedPace.contains("/km"))
    }
}

