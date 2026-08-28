import Testing
@testable import StrideSync

@Suite("VO2 Max & Race Predictor Tests")
struct VO2MaxPredictorTests {
    
    @Test("Test VO2 Max Score and Category Estimation")
    func testVO2MaxEstimation() {
        let calc = VO2MaxCalculator(restingHeartRate: 52, maxHeartRate: 190, age: 26, isMale: true)
        
        // Fast steady tempo run: 4.16 m/s (~15 km/h) at 155 bpm
        let result = calc.estimateVO2Max(averageSpeedMps: 4.16, averageHeartRate: 155)
        
        #expect(result.score >= 45.0 && result.score <= 75.0)
        #expect(result.category == .superior || result.category == .excellent)
        #expect(result.ageGroupPercentile >= 50)
        #expect(result.predictions.count == 4)
    }
    
    @Test("Test Race Predictions Duration and Pace Ordering")
    func testRacePredictions() {
        let calc = VO2MaxCalculator()
        let predictions = calc.generateRacePredictions(vo2Max: 54.0)
        
        #expect(predictions.count == 4)
        
        let fiveK = predictions.first(where: { $0.raceDistance == .fiveK })!
        let tenK = predictions.first(where: { $0.raceDistance == .tenK })!
        let half = predictions.first(where: { $0.raceDistance == .halfMarathon })!
        let full = predictions.first(where: { $0.raceDistance == .fullMarathon })!
        
        #expect(fiveK.estimatedTimeSeconds < tenK.estimatedTimeSeconds)
        #expect(tenK.estimatedTimeSeconds < half.estimatedTimeSeconds)
        #expect(half.estimatedTimeSeconds < full.estimatedTimeSeconds)
        
        // 5K pace should be faster than Marathon pace
        #expect(fiveK.estimatedPaceSecondsPerKm < full.estimatedPaceSecondsPerKm)
    }
}

