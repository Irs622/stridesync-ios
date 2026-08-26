import Foundation
import CoreLocation

/// Service to export activities as standard GPX 1.1 XML and parse imported GPX files.
public struct GPXService: Sendable {
    public init() {}
    
    private func createFormatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    
    /// Exports an ActivityRecord and its TelemetrySnapshots to standard GPX 1.1 XML format.
    public func exportToGPX(activity: ActivityRecord, points: [TelemetrySnapshot]) -> String {
        let formatter = createFormatter()
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="StrideSync iOS" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1">
          <metadata>
            <name>\(escapeXml(activity.title))</name>
            <time>\(formatter.string(from: activity.startTime))</time>
          </metadata>
          <trk>
            <name>\(escapeXml(activity.title))</name>
            <type>\(activity.activityType.rawValue)</type>
            <trkseg>
        """
        
        for point in points {
            let timeStr = formatter.string(from: point.timestamp)
            gpx += "\n      <trkpt lat=\"\(point.latitude)\" lon=\"\(point.longitude)\">"
            gpx += "\n        <ele>\(String(format: "%.1f", point.altitude))</ele>"
            gpx += "\n        <time>\(timeStr)</time>"
            
            if let hr = point.heartRate {
                gpx += "\n        <extensions>"
                gpx += "\n          <gpxtpx:TrackPointExtension>"
                gpx += "\n            <gpxtpx:hr>\(hr)</gpxtpx:hr>"
                gpx += "\n          </gpxtpx:TrackPointExtension>"
                gpx += "\n        </extensions>"
            }
            gpx += "\n      </trkpt>"
        }
        
        gpx += """
        
            </trkseg>
          </trk>
        </gpx>
        """
        return gpx
    }
    
    /// Parses simple GPX 1.1 XML string and returns an array of TelemetrySnapshot.
    public func parseGPX(xmlString: String) -> [TelemetrySnapshot] {
        var points: [TelemetrySnapshot] = []
        let formatter = createFormatter()
        
        let trkptPattern = #"<trkpt\s+lat="([^"]+)"\s+lon="([^"]+)">([\s\S]*?)<\/trkpt>"#
        guard let regex = try? NSRegularExpression(pattern: trkptPattern, options: []) else {
            return []
        }
        
        let nsString = xmlString as NSString
        let matches = regex.matches(in: xmlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            guard match.numberOfRanges >= 3 else { continue }
            let latStr = nsString.substring(with: match.range(at: 1))
            let lonStr = nsString.substring(with: match.range(at: 2))
            let innerContent = match.numberOfRanges >= 4 ? nsString.substring(with: match.range(at: 3)) : ""
            
            guard let lat = Double(latStr), let lon = Double(lonStr) else { continue }
            
            var altitude = 0.0
            if let eleRange = innerContent.range(of: "<ele>"),
               let eleEnd = innerContent.range(of: "</ele>") {
                let eleSub = innerContent[eleRange.upperBound..<eleEnd.lowerBound]
                altitude = Double(eleSub) ?? 0.0
            }
            
            var timestamp = Date()
            if let timeRange = innerContent.range(of: "<time>"),
               let timeEnd = innerContent.range(of: "</time>") {
                let timeSub = String(innerContent[timeRange.upperBound..<timeEnd.lowerBound])
                timestamp = formatter.date(from: timeSub) ?? ISO8601DateFormatter().date(from: timeSub) ?? Date()
            }
            
            var heartRate: Int?
            if let hrRange = innerContent.range(of: "<gpxtpx:hr>"),
               let hrEnd = innerContent.range(of: "</gpxtpx:hr>") {
                let hrSub = innerContent[hrRange.upperBound..<hrEnd.lowerBound]
                heartRate = Int(hrSub)
            }
            
            let snapshot = TelemetrySnapshot(
                timestamp: timestamp,
                latitude: lat,
                longitude: lon,
                altitude: altitude,
                speedMps: 0.0,
                horizontalAccuracy: 5.0,
                heartRate: heartRate
            )
            points.append(snapshot)
        }
        
        return points
    }
    
    private func escapeXml(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

