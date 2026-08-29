import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("Weather Intelligence & Thermal Stress Tests")
struct WeatherIntelligenceTests {
    
    @Test("Test Apparent Temperature Heat Index Formula")
    func testApparentTemperatureCalculation() {
        // High temp and high humidity
        let hotHumid = WeatherConditions(
            temperatureCelsius: 32.0,
            relativeHumidityPercent: 80.0
        )
        #expect(hotHumid.apparentTemperatureCelsius > 32.0)
        #expect(hotHumid.thermalStressCategory == .extremeCaution || hotHumid.thermalStressCategory == .danger)
        #expect(hotHumid.recommendedPaceAdjustmentSecondsPerKm >= 10.0)
        
        // Cool pleasant weather
        let cool = WeatherConditions(
            temperatureCelsius: 18.0,
            relativeHumidityPercent: 50.0
        )
        #expect(cool.thermalStressCategory == .normal)
        #expect(cool.recommendedPaceAdjustmentSecondsPerKm == 0.0)
    }
    
    @Test("Test Weather Service Advice Generation")
    func testWeatherAdviceGeneration() {
        let service = WeatherIntelligenceService.shared
        let hotConditions = WeatherConditions(temperatureCelsius: 35.0, relativeHumidityPercent: 85.0)
        let advice = service.generateWeatherAdvice(conditions: hotConditions)
        #expect(advice.contains("Peringatan Panas Ekstrem") || advice.contains("dehidrasi") || advice.contains("Suhu"))
    }
}

