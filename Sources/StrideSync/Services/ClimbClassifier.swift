import Foundation
import CoreLocation

/// Engine analyzing route elevation profiles, calculating slope gradients, and categorizing climbs (UCI / Strava standard).
public final class ClimbClassifier: Sendable {
    public init() {}
    
    /// Analyzes a sequential list of telemetry coordinates and altitudes, identifying uphill segments and classifying their difficulty.
    public func detectClimbs(from points: [TelemetrySnapshot], minClimbLengthMeters: Double = 300.0, minElevationGainMeters: Double = 10.0) -> [ClimbSegment] {
        guard points.count >= 3 else { return [] }
        
        var climbs: [ClimbSegment] = []
        var inClimb = false
        var climbStartIndex = 0
        var climbDist = 0.0
        var climbElevGain = 0.0
        var maxGrade = 0.0
        
        for i in 0..<(points.count - 1) {
            let p1 = points[i]
            let p2 = points[i + 1]
            
            let loc1 = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
            let loc2 = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
            let segDist = loc1.distance(from: loc2)
            
            guard segDist > 1.0 else { continue }
            
            let elevDelta = (p2.altitude ?? 0.0) - (p1.altitude ?? 0.0)
            let grade = (elevDelta / segDist) * 100.0
            
            if grade >= 0.8 { // Significant uphill gradient threshold
                if !inClimb {
                    inClimb = true
                    climbStartIndex = i
                    climbDist = segDist
                    climbElevGain = max(0.0, elevDelta)
                    maxGrade = grade
                } else {
                    climbDist += segDist
                    climbElevGain += max(0.0, elevDelta)
                    maxGrade = max(maxGrade, grade)
                }
            } else {
                if inClimb {
                    // Check if climb meets minimum threshold
                    if climbDist >= minClimbLengthMeters && climbElevGain >= minElevationGainMeters {
                        let avgGrade = (climbElevGain / climbDist) * 100.0
                        let score = calculateClimbScore(distanceMeters: climbDist, gradePercent: avgGrade)
                        let category = categorizeScore(score: score, distanceMeters: climbDist, elevationGainMeters: climbElevGain)
                        
                        let climb = ClimbSegment(
                            startIndex: climbStartIndex,
                            endIndex: i,
                            distanceMeters: climbDist,
                            elevationGainMeters: climbElevGain,
                            averageGradePercent: avgGrade,
                            maxGradePercent: maxGrade,
                            category: category,
                            score: score,
                            startCoordinate: points[climbStartIndex].coordinate,
                            endCoordinate: points[i].coordinate
                        )
                        climbs.append(climb)
                    }
                    inClimb = false
                    climbDist = 0.0
                    climbElevGain = 0.0
                    maxGrade = 0.0
                }
            }
        }
        
        // Handle trailing climb at the end of the route
        if inClimb && climbDist >= minClimbLengthMeters && climbElevGain >= minElevationGainMeters {
            let avgGrade = (climbElevGain / climbDist) * 100.0
            let score = calculateClimbScore(distanceMeters: climbDist, gradePercent: avgGrade)
            let category = categorizeScore(score: score, distanceMeters: climbDist, elevationGainMeters: climbElevGain)
            
            let climb = ClimbSegment(
                startIndex: climbStartIndex,
                endIndex: points.count - 1,
                distanceMeters: climbDist,
                elevationGainMeters: climbElevGain,
                averageGradePercent: avgGrade,
                maxGradePercent: maxGrade,
                category: category,
                score: score,
                startCoordinate: points[climbStartIndex].coordinate,
                endCoordinate: points[points.count - 1].coordinate
            )
            climbs.append(climb)
        }
        
        return climbs
    }
    
    /// Official Strava/UCI Climb Score formula: Length (m) * (Grade %)^2
    public func calculateClimbScore(distanceMeters: Double, gradePercent: Double) -> Double {
        guard distanceMeters > 0 && gradePercent > 0 else { return 0.0 }
        let score = distanceMeters * (gradePercent * gradePercent)
        return score
    }
    
    /// Maps climb score and elevation gain to standard categories.
    public func categorizeScore(score: Double, distanceMeters: Double, elevationGainMeters: Double) -> ClimbCategory {
        if score >= 80000.0 || (elevationGainMeters >= 1000.0 && distanceMeters >= 10000.0) {
            return .hc
        } else if score >= 64000.0 || elevationGainMeters >= 600.0 {
            return .cat1
        } else if score >= 32000.0 || elevationGainMeters >= 300.0 {
            return .cat2
        } else if score >= 16000.0 || elevationGainMeters >= 150.0 {
            return .cat3
        } else if score >= 8000.0 || elevationGainMeters >= 40.0 {
            return .cat4
        } else {
            return .uncategorized
        }
    }
}
