import Foundation
import CoreLocation

/// Engine managing GPX route tracking, turn-by-turn step calculation, cross-track error detection, and off-course alerts.
public final class RouteNavigationEngine: @unchecked Sendable {
    public let courseCoordinates: [CLLocationCoordinate2D]
    public let navigationSteps: [NavigationStep]
    public let offCourseThresholdMeters: Double
    
    public var currentStepIndex: Int = 0
    public var isOffCourse: Bool = false
    public var totalRouteDistanceMeters: Double = 0.0
    
    public init(
        coordinates: [CLLocationCoordinate2D],
        offCourseThresholdMeters: Double = 30.0
    ) {
        self.courseCoordinates = coordinates
        self.offCourseThresholdMeters = offCourseThresholdMeters
        
        // Calculate cumulative distances and generate turn maneuvers
        var steps: [NavigationStep] = []
        var totalDist: Double = 0.0
        
        if coordinates.count >= 2 {
            steps.append(NavigationStep(
                coordinate: coordinates[0],
                maneuver: .start,
                distanceAlongRouteMeters: 0.0,
                instruction: "Mulai ikuti rute"
            ))
            
            for i in 1..<coordinates.count {
                let loc1 = CLLocation(latitude: coordinates[i - 1].latitude, longitude: coordinates[i - 1].longitude)
                let loc2 = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
                totalDist += loc1.distance(from: loc2)
                
                // Check bearing changes for turns if 3 points available
                if i < coordinates.count - 1 {
                    let b1 = Self.calculateBearing(from: coordinates[i - 1], to: coordinates[i])
                    let b2 = Self.calculateBearing(from: coordinates[i], to: coordinates[i + 1])
                    var diff = b2 - b1
                    while diff > 180 { diff -= 360 }
                    while diff < -180 { diff += 360 }
                    
                    if abs(diff) >= 30.0 {
                        let maneuver: NavigationManeuver
                        let instruction: String
                        if diff > 60 {
                            maneuver = .turnRight
                            instruction = "Belok kanan"
                        } else if diff > 30 {
                            maneuver = .slightRight
                            instruction = "Serong kanan"
                        } else if diff < -60 {
                            maneuver = .turnLeft
                            instruction = "Belok kiri"
                        } else {
                            maneuver = .slightLeft
                            instruction = "Serong kiri"
                        }
                        
                        steps.append(NavigationStep(
                            coordinate: coordinates[i],
                            maneuver: maneuver,
                            distanceAlongRouteMeters: totalDist,
                            instruction: instruction
                        ))
                    }
                }
            }
            
            // Final arrival step
            if let lastCoord = coordinates.last {
                steps.append(NavigationStep(
                    coordinate: lastCoord,
                    maneuver: .arrive,
                    distanceAlongRouteMeters: totalDist,
                    instruction: "Tiba di tujuan rute"
                ))
            }
        }
        
        self.navigationSteps = steps
        self.totalRouteDistanceMeters = totalDist
    }
    
    /// Processes current athlete location and yields real-time navigation guidance.
    public func processLocation(_ athleteLocation: CLLocation) -> NavigationGuidance {
        guard !courseCoordinates.isEmpty else {
            return NavigationGuidance(
                currentManeuver: .arrive,
                instruction: "Rute kosong",
                distanceToManeuverMeters: 0,
                remainingRouteDistanceMeters: 0,
                isOffCourse: false,
                crossTrackDistanceMeters: 0
            )
        }
        
        // 1. Calculate minimum cross-track distance to course polyline
        let crossTrack = calculateMinDistanceToCourse(athleteLocation)
        let offCourse = crossTrack > offCourseThresholdMeters
        self.isOffCourse = offCourse
        
        if offCourse {
            return NavigationGuidance(
                currentManeuver: .offCourse,
                instruction: String(format: "Keluar jalur! (%.0fm dari rute)", crossTrack),
                distanceToManeuverMeters: crossTrack,
                remainingRouteDistanceMeters: max(0, totalRouteDistanceMeters),
                isOffCourse: true,
                crossTrackDistanceMeters: crossTrack
            )
        }
        
        // 2. Advance step index if close to current maneuver (< 20 meters)
        if currentStepIndex < navigationSteps.count - 1 {
            let nextStep = navigationSteps[currentStepIndex + 1]
            let stepLoc = CLLocation(latitude: nextStep.coordinate.latitude, longitude: nextStep.coordinate.longitude)
            if athleteLocation.distance(from: stepLoc) < 20.0 {
                currentStepIndex += 1
            }
        }
        
        // 3. Determine active upcoming maneuver
        let activeStep = currentStepIndex < navigationSteps.count ? navigationSteps[currentStepIndex] : navigationSteps.last!
        let activeLoc = CLLocation(latitude: activeStep.coordinate.latitude, longitude: activeStep.coordinate.longitude)
        let distToManeuver = athleteLocation.distance(from: activeLoc)
        
        // 4. Estimate remaining distance to end of route
        var remainingDist = 0.0
        if let lastCoord = courseCoordinates.last {
            let lastLoc = CLLocation(latitude: lastCoord.latitude, longitude: lastCoord.longitude)
            remainingDist = athleteLocation.distance(from: lastLoc)
        }
        
        return NavigationGuidance(
            currentManeuver: activeStep.maneuver,
            instruction: "\(activeStep.instruction) (\(String(format: "%.0f m", distToManeuver)))",
            distanceToManeuverMeters: distToManeuver,
            remainingRouteDistanceMeters: remainingDist,
            isOffCourse: false,
            crossTrackDistanceMeters: crossTrack
        )
    }
    
    // MARK: - Geometry Helpers
    
    private func calculateMinDistanceToCourse(_ location: CLLocation) -> Double {
        var minDistance = Double.infinity
        for i in 0..<courseCoordinates.count {
            let loc = CLLocation(latitude: courseCoordinates[i].latitude, longitude: courseCoordinates[i].longitude)
            let dist = location.distance(from: loc)
            if dist < minDistance {
                minDistance = dist
            }
        }
        return minDistance == Double.infinity ? 0.0 : minDistance
    }
    
    public static func calculateBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180.0
        let lon1 = from.longitude * .pi / 180.0
        let lat2 = to.latitude * .pi / 180.0
        let lon2 = to.longitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radians = atan2(y, x)
        let degrees = radians * 180.0 / .pi
        return (degrees + 360.0).truncatingRemainder(dividingBy: 360.0)
    }
}

