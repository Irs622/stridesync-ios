import Foundation
import CoreLocation

/// Engine managing live nearby community runners and calculating relative spatial radar target bearings.
public final class GroupRunRadarEngine: @unchecked Sendable {
    public static let shared = GroupRunRadarEngine()
    
    private var registeredBuddies: [BuddyRunner] = []
    public var radarRangeMeters: Double = 1200.0 // 1.2km radar sweep radius
    
    public init(initialBuddies: [BuddyRunner] = []) {
        self.registeredBuddies = initialBuddies.isEmpty ? Self.sampleBuddies() : initialBuddies
    }
    
    /// Updates the list of live buddies in the session.
    public func updateBuddies(_ buddies: [BuddyRunner]) {
        self.registeredBuddies = buddies
    }
    
    /// Evaluates all buddies within the radar range from the current athlete's coordinate and course heading.
    public func scanRadar(
        currentCoordinate: CLLocationCoordinate2D,
        currentPaceSecondsPerKm: Double = 270.0,
        activityType: ActivityType = .run
    ) -> [RadarTargetPing] {
        let athleteLoc = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
        var pings: [RadarTargetPing] = []
        
        for buddy in registeredBuddies where buddy.activityType == activityType {
            let buddyLoc = CLLocation(latitude: buddy.latitude, longitude: buddy.longitude)
            let distance = athleteLoc.distance(from: buddyLoc)
            
            if distance <= radarRangeMeters && distance > 0.5 {
                let bearing = calculateBearing(from: currentCoordinate, to: buddy.coordinate)
                let isAhead = buddy.distanceCompletedMeters >= 0 // relative distance or bearing
                let paceDiff = currentPaceSecondsPerKm - buddy.currentPaceSecondsPerKm
                
                let ping = RadarTargetPing(
                    buddy: buddy,
                    relativeDistanceMeters: distance,
                    relativeBearingDegrees: bearing,
                    isAhead: isAhead,
                    paceDifferenceSecondsPerKm: paceDiff
                )
                pings.append(ping)
            }
        }
        
        // Sort closest first
        return pings.sorted { $0.relativeDistanceMeters < $1.relativeDistanceMeters }
    }
    
    /// Calculates initial compass bearing from point A to point B in degrees (0..360).
    public func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180.0
        let lon1 = from.longitude * .pi / 180.0
        let lat2 = to.latitude * .pi / 180.0
        let lon2 = to.longitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radians = atan2(y, x)
        let degrees = (radians * 180.0 / .pi + 360.0).truncatingRemainder(dividingBy: 360.0)
        return degrees
    }
    
    public static func sampleBuddies() -> [BuddyRunner] {
        let baseLat = -6.175392
        let baseLon = 106.827153
        return [
            BuddyRunner(
                name: "Alex Rivera",
                latitude: baseLat + 0.0035,
                longitude: baseLon + 0.0012,
                currentSpeedMps: 4.2,
                currentPaceSecondsPerKm: 238.0, // 3:58 /km
                distanceCompletedMeters: 4800,
                activityType: .run,
                isClubMember: true
            ),
            BuddyRunner(
                name: "Siti Rahmawati",
                latitude: baseLat + 0.0018,
                longitude: baseLon - 0.0008,
                currentSpeedMps: 3.6,
                currentPaceSecondsPerKm: 277.0, // 4:37 /km
                distanceCompletedMeters: 3100,
                activityType: .run,
                isClubMember: true
            ),
            BuddyRunner(
                name: "Dimas Anggara",
                latitude: baseLat - 0.0022,
                longitude: baseLon + 0.0020,
                currentSpeedMps: 3.3,
                currentPaceSecondsPerKm: 303.0, // 5:03 /km
                distanceCompletedMeters: 2200,
                activityType: .run,
                isClubMember: false
            )
        ]
    }
}

