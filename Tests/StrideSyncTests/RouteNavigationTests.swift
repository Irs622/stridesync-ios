import Testing
import Foundation
import CoreLocation
@testable import StrideSync

@Suite("GPX Route Navigation & Turn-by-Turn Tests")
struct RouteNavigationTests {
    
    @Test("Test RouteNavigationEngine step generation and bearing calculation")
    func testNavigationStepGeneration() {
        let coords = [
            CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272),
            CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8372), // Heading East (90 deg)
            CLLocationCoordinate2D(latitude: -6.1854, longitude: 106.8372)  // Turning South (180 deg) -> Turn Right
        ]
        
        let engine = RouteNavigationEngine(coordinates: coords)
        #expect(engine.navigationSteps.count >= 2)
        #expect(engine.navigationSteps.first?.maneuver == .start)
        #expect(engine.navigationSteps.last?.maneuver == .arrive)
        
        let bearing1 = RouteNavigationEngine.calculateBearing(from: coords[0], to: coords[1])
        #expect(abs(bearing1 - 90.0) < 5.0) // East
    }
    
    @Test("Test On-course and Off-course guidance detection")
    func testNavigationGuidanceAndOffCourse() {
        let coords = [
            CLLocationCoordinate2D(latitude: -6.1754, longitude: 106.8272),
            CLLocationCoordinate2D(latitude: -6.1764, longitude: 106.8272),
            CLLocationCoordinate2D(latitude: -6.1774, longitude: 106.8272)
        ]
        let engine = RouteNavigationEngine(coordinates: coords, offCourseThresholdMeters: 30.0)
        
        // Case 1: On-course athlete
        let onCourseLoc = CLLocation(latitude: -6.1755, longitude: 106.8272)
        let guidance1 = engine.processLocation(onCourseLoc)
        #expect(guidance1.isOffCourse == false)
        #expect(guidance1.crossTrackDistanceMeters < 30.0)
        
        // Case 2: Off-course athlete (150m East)
        let offCourseLoc = CLLocation(latitude: -6.1755, longitude: 106.8300)
        let guidance2 = engine.processLocation(offCourseLoc)
        #expect(guidance2.isOffCourse == true)
        #expect(guidance2.currentManeuver == .offCourse)
        #expect(guidance2.crossTrackDistanceMeters > 30.0)
    }
}

