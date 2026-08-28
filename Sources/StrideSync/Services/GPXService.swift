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
    
    /// Parses GPX 1.1 XML string and returns an array of TelemetrySnapshot.
    public func parseGPX(xmlString: String) -> [TelemetrySnapshot] {
        guard let data = xmlString.data(using: .utf8) else { return [] }
        
        let parserDelegate = GPXParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = parserDelegate
        if parser.parse() && !parserDelegate.points.isEmpty {
            return parserDelegate.points
        }
        
        // Fallback flexible regex if XMLParser fails on non-standard fragments
        return parseGPXRegexFallback(xmlString: xmlString)
    }
    
    private func parseGPXRegexFallback(xmlString: String) -> [TelemetrySnapshot] {
        var points: [TelemetrySnapshot] = []
        let formatter = createFormatter()
        
        let trkptPattern = #"<trkpt[^>]*lat=["']([^"']+)["'][^>]*lon=["']([^"']+)["'][^>]*>([\s\S]*?)<\/trkpt>|<trkpt[^>]*lon=["']([^"']+)["'][^>]*lat=["']([^"']+)["'][^>]*>([\s\S]*?)<\/trkpt>"#
        guard let regex = try? NSRegularExpression(pattern: trkptPattern, options: []) else {
            return []
        }
        
        let nsString = xmlString as NSString
        let matches = regex.matches(in: xmlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            var latStr = ""
            var lonStr = ""
            var innerContent = ""
            
            if match.range(at: 1).location != NSNotFound && match.range(at: 2).location != NSNotFound {
                latStr = nsString.substring(with: match.range(at: 1))
                lonStr = nsString.substring(with: match.range(at: 2))
                if match.range(at: 3).location != NSNotFound {
                    innerContent = nsString.substring(with: match.range(at: 3))
                }
            } else if match.range(at: 4).location != NSNotFound && match.range(at: 5).location != NSNotFound {
                lonStr = nsString.substring(with: match.range(at: 4))
                latStr = nsString.substring(with: match.range(at: 5))
                if match.range(at: 6).location != NSNotFound {
                    innerContent = nsString.substring(with: match.range(at: 6))
                }
            }
            
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
            } else if let hrRange = innerContent.range(of: "<hr>"),
                      let hrEnd = innerContent.range(of: "</hr>") {
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

/// Internal SAX XMLParser delegate for GPX 1.1 tracks.
final class GPXParserDelegate: NSObject, XMLParserDelegate, @unchecked Sendable {
    var points: [TelemetrySnapshot] = []
    
    private var currentElement: String = ""
    private var currentLat: Double?
    private var currentLon: Double?
    private var currentEle: Double?
    private var currentTime: Date?
    private var currentHeartRate: Int?
    private var elementBuffer: String = ""
    
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    private let standardIsoFormatter = ISO8601DateFormatter()
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        elementBuffer = ""
        
        if elementName == "trkpt" || elementName == "wpt" {
            if let latStr = attributeDict["lat"], let lonStr = attributeDict["lon"] {
                currentLat = Double(latStr)
                currentLon = Double(lonStr)
            } else if let latStr = attributeDict["latitude"], let lonStr = attributeDict["longitude"] {
                currentLat = Double(latStr)
                currentLon = Double(lonStr)
            }
            currentEle = nil
            currentTime = nil
            currentHeartRate = nil
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        elementBuffer += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let trimmed = elementBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if elementName == "ele" {
            currentEle = Double(trimmed)
        } else if elementName == "time" {
            currentTime = isoFormatter.date(from: trimmed) ?? standardIsoFormatter.date(from: trimmed)
        } else if elementName == "gpxtpx:hr" || elementName == "hr" {
            currentHeartRate = Int(trimmed)
        } else if elementName == "trkpt" || elementName == "wpt" {
            if let lat = currentLat, let lon = currentLon {
                let pt = TelemetrySnapshot(
                    timestamp: currentTime ?? Date(),
                    latitude: lat,
                    longitude: lon,
                    altitude: currentEle ?? 0.0,
                    speedMps: 0.0,
                    horizontalAccuracy: 5.0,
                    heartRate: currentHeartRate
                )
                points.append(pt)
            }
            currentLat = nil
            currentLon = nil
        }
    }
}

