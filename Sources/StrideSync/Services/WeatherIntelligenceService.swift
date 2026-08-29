import Foundation
import CoreLocation

/// Service calculating environmental weather conditions, heat index, and providing physiological pacing adjustments.
public final class WeatherIntelligenceService: Sendable {
    public static let shared = WeatherIntelligenceService()
    
    public init() {}
    
    /// Generates or fetches current weather intelligence based on coordinate and time of day.
    public func fetchWeather(for coordinate: CLLocationCoordinate2D, date: Date = Date()) -> WeatherConditions {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        var temp: Double
        var humidity: Double
        var condition: String
        var icon: String
        
        if hour >= 5 && hour < 10 {
            temp = 24.0
            humidity = 78.0
            condition = "Pagi Cerah Berawan"
            icon = "sun.and.horizon.fill"
        } else if hour >= 10 && hour < 15 {
            temp = 32.0
            humidity = 65.0
            condition = "Siang Terik Panas"
            icon = "sun.max.fill"
        } else if hour >= 15 && hour < 19 {
            temp = 28.0
            humidity = 72.0
            condition = "Sore Teduh"
            icon = "cloud.sun.fill"
        } else {
            temp = 23.0
            humidity = 82.0
            condition = "Malam Sejuk"
            icon = "moon.stars.fill"
        }
        
        return WeatherConditions(
            temperatureCelsius: temp,
            relativeHumidityPercent: humidity,
            windSpeedKmh: 9.0,
            windDirectionText: "Selatan",
            conditionDescription: condition,
            iconName: icon,
            airQualityIndexAQI: 38
        )
    }
    
    /// Formulates actionable tactical pacing guidance based on environmental stress.
    public func generateWeatherAdvice(conditions: WeatherConditions, targetPaceSecondsPerKm: Double? = nil) -> String {
        let stress = conditions.thermalStressCategory
        
        switch stress {
        case .normal:
            return "Kondisi cuaca sangat ideal untuk push pace atau memecahkan rekor PR!"
        case .caution:
            return "Suhu mulai hangat (\(conditions.formattedTemperature)). Pastikan konsumsi air teratur setiap 20 menit."
        case .extremeCaution:
            let adj = Int(conditions.recommendedPaceAdjustmentSecondsPerKm)
            return "Suhu semu \(conditions.formattedApparentTemperature) dengan kelembaban \(conditions.formattedHumidity). Disarankan memperlambat pace target +\(adj) detik/km guna mencegah dehidrasi."
        case .danger:
            return "⚠️ Peringatan Panas Ekstrem! Suhu semu \(conditions.formattedApparentTemperature). Kurangi intensitas drastis dan utamakan hidrasi elektrolit."
        }
    }
}

