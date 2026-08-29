import Foundation

/// Thermal stress level categorizing heat or cold risk for athletic exertion.
public enum ThermalStressCategory: String, Codable, Sendable, CaseIterable {
    case normal = "Normal / Optimal"
    case caution = "Waspada Ringan"
    case extremeCaution = "Waspada Tinggi (Pace +5-10s)"
    case danger = "Bahaya Termal (Wajib Hidrasi & Kurangi Intensitas)"
    
    public var iconName: String {
        switch self {
        case .normal: return "checkmark.shield.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .extremeCaution: return "flame.fill"
        case .danger: return "exclamationmark.octagon.fill"
        }
    }
}

/// Weather summary and physiological environmental parameters for a workout session.
public struct WeatherConditions: Codable, Sendable {
    public var temperatureCelsius: Double
    public var relativeHumidityPercent: Double // 0 to 100
    public var windSpeedKmh: Double
    public var windDirectionText: String
    public var conditionDescription: String
    public var iconName: String
    public var airQualityIndexAQI: Int?
    
    public init(
        temperatureCelsius: Double = 26.0,
        relativeHumidityPercent: Double = 70.0,
        windSpeedKmh: Double = 10.0,
        windDirectionText: String = "Barat Daya",
        conditionDescription: String = "Cerah Berawan",
        iconName: String = "sun.max.fill",
        airQualityIndexAQI: Int? = 45
    ) {
        self.temperatureCelsius = temperatureCelsius
        self.relativeHumidityPercent = relativeHumidityPercent
        self.windSpeedKmh = windSpeedKmh
        self.windDirectionText = windDirectionText
        self.conditionDescription = conditionDescription
        self.iconName = iconName
        self.airQualityIndexAQI = airQualityIndexAQI
    }
    
    /// Calculates NOAA Heat Index / Apparent Temperature in °C.
    public var apparentTemperatureCelsius: Double {
        let tc = temperatureCelsius
        let rh = relativeHumidityPercent
        
        if tc < 20.0 {
            // Below 20°C, apparent temp is close to actual temp
            return tc
        }
        
        // Convert to Fahrenheit for NOAA formula
        let tf = (tc * 9.0 / 5.0) + 32.0
        
        let hiF = -42.379
            + 2.04901523 * tf
            + 10.14333127 * rh
            - 0.22475541 * tf * rh
            - 0.00683783 * (tf * tf)
            - 0.05481717 * (rh * rh)
            + 0.00122874 * (tf * tf) * rh
            + 0.00085282 * tf * (rh * rh)
            - 0.00000199 * (tf * tf) * (rh * rh)
        
        let hiC = (hiF - 32.0) * 5.0 / 9.0
        return max(tc, hiC)
    }
    
    /// Evaluates physiological thermal stress based on apparent temperature.
    public var thermalStressCategory: ThermalStressCategory {
        let hi = apparentTemperatureCelsius
        if hi < 27.0 {
            return .normal
        } else if hi < 32.0 {
            return .caution
        } else if hi < 39.0 {
            return .extremeCaution
        } else {
            return .danger
        }
    }
    
    /// Estimated target pace adjustment in seconds per km to avoid hyperthermia.
    public var recommendedPaceAdjustmentSecondsPerKm: Double {
        let hi = apparentTemperatureCelsius
        if hi < 25.0 {
            return 0.0
        } else if hi < 30.0 {
            return 4.0
        } else if hi < 35.0 {
            return 10.0
        } else {
            return 18.0
        }
    }
    
    public var formattedTemperature: String {
        String(format: "%.0f°C", temperatureCelsius)
    }
    
    public var formattedApparentTemperature: String {
        String(format: "%.0f°C", apparentTemperatureCelsius)
    }
    
    public var formattedHumidity: String {
        String(format: "%.0f%%", relativeHumidityPercent)
    }
    
    public var formattedWind: String {
        String(format: "%.0f km/h %@", windSpeedKmh, windDirectionText)
    }
}

