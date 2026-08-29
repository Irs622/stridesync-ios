import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("Climb Classifier & UCI Grade Analysis Tests")
struct ClimbClassifierTests {
    
    @Test("Test Climb Score Formula and Categorization")
    func testClimbScoreCategorization() {
        let classifier = ClimbClassifier()
        
        // Massive HC Climb: 10,000m @ 10% grade
        let hcScore = classifier.calculateClimbScore(distanceMeters: 10000, gradePercent: 10)
        #expect(hcScore >= 80000)
        let hcCategory = classifier.categorizeScore(score: hcScore, distanceMeters: 10000, elevationGainMeters: 1000)
        #expect(hcCategory == .hc)
        
        // Cat 4 Climb: 1,000m @ 4% grade -> Score = 1000 * 16 = 16,000
        let cat3Score = classifier.calculateClimbScore(distanceMeters: 1000, gradePercent: 4)
        let cat3Category = classifier.categorizeScore(score: cat3Score, distanceMeters: 1000, elevationGainMeters: 40)
        #expect(cat3Category == .cat3 || cat3Category == .cat4)
        
        // Gentle hill: 300m @ 2% grade -> Score = 300 * 4 = 1200
        let hillScore = classifier.calculateClimbScore(distanceMeters: 300, gradePercent: 2)
        let hillCategory = classifier.categorizeScore(score: hillScore, distanceMeters: 300, elevationGainMeters: 6)
        #expect(hillCategory == .uncategorized)
    }
    
    @Test("Test Climb Detection from Telemetry Series")
    func testClimbDetectionFromTelemetry() {
        let classifier = ClimbClassifier()
        var points: [TelemetrySnapshot] = []
        let baseLat = -6.175392
        let baseLon = 106.827153
        
        // Generate a 1km continuous uphill segment (+50m gain, ~5% grade)
        for i in 0...10 {
            points.append(TelemetrySnapshot(
                timestamp: Date().addingTimeInterval(Double(i) * 30),
                latitude: baseLat + (Double(i) * 0.001),
                longitude: baseLon,
                altitude: 10.0 + (Double(i) * 5.0), // +5m every 100m = 5% grade
                speedMps: 3.5,
                horizontalAccuracy: 5.0
            ))
        }
        
        let climbs = classifier.detectClimbs(from: points, minClimbLengthMeters: 200.0, minElevationGainMeters: 10.0)
        #expect(!climbs.isEmpty)
        #expect(climbs.first?.elevationGainMeters ?? 0 > 30.0)
        #expect(climbs.first?.averageGradePercent ?? 0 > 3.0)
    }
}

