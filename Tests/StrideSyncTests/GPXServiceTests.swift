import Testing
import Foundation
@testable import StrideSync

@Suite("GPXService Tests")
struct GPXServiceTests {
    
    @Test("Test Exporting Activity and Snapshots to GPX XML and Parsing Back")
    func testGPXExportAndParse() throws {
        let service = GPXService()
        let now = Date()
        
        let activity = ActivityRecord(
            title: "Morning River Run",
            activityType: .run,
            startTime: now,
            endTime: now.addingTimeInterval(1800),
            distanceMeters: 5000.0,
            durationSeconds: 1800,
            movingTimeSeconds: 1750,
            totalElevationGainMeters: 40.0,
            averageSpeedMps: 2.85
        )
        
        let points = [
            TelemetrySnapshot(timestamp: now, latitude: -6.175392, longitude: 106.827153, altitude: 12.0, heartRate: 145),
            TelemetrySnapshot(timestamp: now.addingTimeInterval(10), latitude: -6.175200, longitude: 106.827180, altitude: 14.0, heartRate: 152),
            TelemetrySnapshot(timestamp: now.addingTimeInterval(20), latitude: -6.175000, longitude: 106.827200, altitude: 15.0, heartRate: 158)
        ]
        
        let gpxXml = service.exportToGPX(activity: activity, points: points)
        
        #expect(gpxXml.contains("<gpx version=\"1.1\""))
        #expect(gpxXml.contains("Morning River Run"))
        #expect(gpxXml.contains("-6.175392"))
        #expect(gpxXml.contains("<gpxtpx:hr>145</gpxtpx:hr>"))
        
        let parsedPoints = service.parseGPX(xmlString: gpxXml)
        #expect(parsedPoints.count == 3)
        #expect(abs(parsedPoints[0].latitude - (-6.175392)) < 0.0001)
        #expect(parsedPoints[0].heartRate == 145)
    }
    
    @Test("Test GPX Parsing with Reversed Lon/Lat and Single Quotes")
    func testGPXParsingVariations() throws {
        let service = GPXService()
        
        let thirdPartyGpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="ThirdPartyApp">
          <trk>
            <name>Trail Run</name>
            <trkseg>
              <trkpt lon="106.827153" lat="-6.175392">
                <ele>25.4</ele>
                <time>2026-08-29T00:00:00Z</time>
                <extensions>
                  <gpxtpx:TrackPointExtension>
                    <gpxtpx:hr>162</gpxtpx:hr>
                  </gpxtpx:TrackPointExtension>
                </extensions>
              </trkpt>
              <trkpt lon='106.827200' lat='-6.175300'>
                <ele>26.0</ele>
                <time>2026-08-29T00:00:05Z</time>
                <hr>165</hr>
              </trkpt>
            </trkseg>
          </trk>
        </gpx>
        """
        
        let parsed = service.parseGPX(xmlString: thirdPartyGpx)
        #expect(parsed.count == 2)
        #expect(abs(parsed[0].latitude - (-6.175392)) < 0.0001)
        #expect(abs(parsed[0].longitude - 106.827153) < 0.0001)
        #expect(parsed[0].heartRate == 162)
        #expect(parsed[1].heartRate == 165)
    }
}

