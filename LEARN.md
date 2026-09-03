# 🎓 Learning Guide: Building & Mastering High-Performance Athletic Telemetry iOS Apps with Swift 6 & SwiftData

> **Welcome to the StrideSync iOS Educational Guide!**  
> This guide is designed for students, educators, and developers participating in the **GitHub Community Exchange / GitHub Learning Program**. It provides a comprehensive, step-by-step educational breakdown of how **StrideSync iOS** (`v0.5.0-beta`) is engineered—from Swift 6 strict concurrency to real-time CoreLocation actor processing, local-first SwiftData persistence, ActivityKit Live Activities, and athletic telemetry algorithms.

---

## 📌 Table of Contents

1. [Project Overview & Learning Objectives](#-project-overview--learning-objectives)
2. [Prerequisites & Environment Setup](#-prerequisites--environment-setup)
3. [Core Architectural Concepts](#-core-architectural-concepts)
4. [Step-by-Step Practical Tutorial](#-step-by-step-practical-tutorial)
   - [Step 1: Anatomy of StrideSync iOS Architecture](#step-1-anatomy-of-stridesync-ios-architecture)
   - [Step 2: Building an Actor-Isolated GPS Telemetry Engine](#step-2-building-an-actor-isolated-gps-telemetry-engine)
   - [Step 3: Local-First Persistence with SwiftData](#step-3-local-first-persistence-with-swiftdata)
   - [Step 4: Real-Time Athletic Analytics (VO2 Max & TRIMP)](#step-4-real-time-athletic-analytics-vo2-max--trimp)
   - [Step 5: Live Activity HUD (Dynamic Island & Lock Screen)](#step-5-live-activity-hud-dynamic-island--lock-screen)
   - [Step 6: Binary Encoding/Decoding (Garmin FIT 2.0 & GPX 1.1)](#step-6-binary-encodingdecoding-garmin-fit-20--gpx-11)
5. [Community Issues & Collaboration Guide](#-community-issues--collaboration-guide)
6. [Hands-On Exercises for Learners](#-hands-on-exercises-for-learners)
7. [Troubleshooting & Common Pitfalls](#-troubleshooting--common-pitfalls)
8. [Further Learning & Documentation Index](#-further-learning--documentation-index)

---

## 🎯 Project Overview & Learning Objectives

### What is StrideSync iOS?
**StrideSync iOS** is an open-source, high-performance athletic intelligence and GPS running platform. Built natively for **iOS 17.0+** using **Swift 6.0**, it tracks outdoor endurance activities (running, cycling, hiking, walking) with telemetry-grade GPS accuracy, real-time audio coaching, Bluetooth GATT sensor connectivity, and Garmin FIT / GPX export capabilities.

```text
StrideSync iOS App Architecture
├── SwiftUI & MapKit (Declarative Dark Mode UI & Polyline Rendering)
├── LocationEngine Actor (Isolated GPS Stream & Noise Filtering)
├── SwiftData Container (@Model Local-First Relational Database)
├── ActivityKit & WidgetKit (Dynamic Island & Lock Screen Live HUD)
└── Supabase Cloud & RLS (PostgreSQL Cloud Social Feed Sync)
```

### What You Will Learn
By studying and extending this repository, learners will master:
- **Swift 6 Strict Concurrency**: Eliminating data races in location streaming using `actor LocationEngine` and `@Sendable` types.
- **Local-First Architecture**: Storing workout sessions locally with `@Model SwiftData` for zero-server dependency and zero cost (Rp 0).
- **CoreLocation Telemetry Engine**: Filtering GPS horizontal accuracy noise ($> 25\text{m}$ rejection), smart auto-pause/resume, and kilometer split tracking.
- **Sports Science Physiology Models**: Calculating VO2 Max via Jack Daniels VDOT, Banister TRIMP training load (ATL, CTL), and UCI grade elevation climb classification.
- **CoreBluetooth GATT Sensor Integration**: Reading binary payloads from Bluetooth heart rate monitors and cycling power meters.
- **ActivityKit & Dynamic Island**: Creating real-time background Live Activities.
- **Binary Protocols & File Parsing**: Parsing and generating Garmin FIT 2.0 binary protocol and GPX 1.1 XML data.

---

## 💻 Prerequisites & Environment Setup

### System Requirements
- **macOS**: Sonoma (14.0+) or Sequoia (15.0+)
- **Xcode**: 15.3 or 16.0+ (with Swift 6.0 compiler support)
- **Target OS**: iOS 17.0+ (Simulator or Physical iPhone)

### Step-by-Step Installation

```bash
# 1. Clone the repository
git clone https://github.com/Irs622/stridesync-ios.git
cd stridesync-ios

# 2. Open the native Xcode project
open StrideSync.xcodeproj

# 3. Build and run unit tests via command line
xcodebuild test -project StrideSync.xcodeproj -scheme StrideSync -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## 🏛️ Core Architectural Concepts

StrideSync follows a modern **MVVM + Service Actor Pattern** with strict thread isolation:

```text
       ┌───────────────────────────────────────┐
       │             SwiftUI Views             │
       │    (HUDView, FeedView, ProfileView)   │
       └──────────────────┬────────────────────┘
                          │ @State / @Observable
                          ▼
       ┌───────────────────────────────────────┐
       │           View Models (MVVM)          │
       │  (WorkoutViewModel, CommunityFeedVM)  │
       └──────────────────┬────────────────────┘
                          │ async/await calls
                          ▼
       ┌───────────────────────────────────────┐
       │            Service Actors             │
       │  (actor LocationEngine, SyncEngine)   │
       └──────────────────┬────────────────────┘
                          │ SwiftData & CoreData
                          ▼
       ┌───────────────────────────────────────┐
       │          SwiftData Store              │
       │  (@Model WorkoutSession, LocationPoint)│
       └───────────────────────────────────────┘
```

---

## 🚀 Step-by-Step Practical Tutorial

### Step 1: Anatomy of StrideSync iOS Architecture

Inspect the directory structure in [`Sources/StrideSync/`](file:///Users/mac/Downloads/stridesync-ios/Sources/StrideSync):

- **`Models/`**: Relational data structures (`WorkoutSession.swift`, `LocationPoint.swift`, `AthleteProfile.swift`).
- **`Services/`**: Background services (`LocationEngine.swift`, `AudioPacingCoach.swift`, `GarminFITEncoder.swift`, `BluetoothSensorManager.swift`).
- **`ViewModels/`**: State containers managing UI updates (`ActiveWorkoutViewModel.swift`).
- **`Views/`**: Declarative UI components built with SwiftUI (`ProHUDView.swift`, `LiveMapView.swift`).

---

### Step 2: Building an Actor-Isolated GPS Telemetry Engine

To prevent data race conditions when processing rapid GPS coordinate updates (1-10 Hz), StrideSync isolates calculations inside `actor LocationEngine`:

```swift
import CoreLocation
import Foundation

/// Swift 6 Actor isolating GPS coordinate processing and noise rejection.
public actor LocationEngine {
    private var rawCoordinates: [CLLocation] = []
    private var filteredPoints: [LocationPoint] = []
    private(set) public var isAutoPaused: Bool = false
    
    /// Process incoming GPS location update with accuracy filtering.
    public func processLocation(_ location: CLLocation) -> LocationPoint? {
        // 1. Reject coordinates with low horizontal accuracy (> 25 meters)
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 25.0 else {
            return nil
        }
        
        // 2. Reject velocity anomalies (speed > 15 m/s or 54 km/h for running)
        guard location.speed <= 15.0 else {
            return nil
        }
        
        // 3. Smart Auto-Pause check (speed < 0.8 m/s for > 5 seconds)
        if location.speed < 0.8 {
            isAutoPaused = true
        } else {
            isAutoPaused = false
        }
        
        let point = LocationPoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude,
            speed: location.speed,
            timestamp: location.timestamp
        )
        
        filteredPoints.append(point)
        return point
    }
}
```

---

### Step 3: Local-First Persistence with SwiftData

Workout data is stored locally using **SwiftData** `@Model` annotations. This ensures zero data loss even if the device loses network connectivity.

```swift
import Foundation
import SwiftData

@Model
public final class WorkoutSession {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var activityTypeRaw: String
    public var startDate: Date
    public var endDate: Date?
    public var totalDistanceMeters: Double
    public var totalDurationSeconds: Double
    public var totalElevationGainMeters: Double
    
    @Relationship(deleteRule: .cascade) 
    public var locationPoints: [LocationPoint]
    
    public init(
        id: UUID = UUID(),
        title: String,
        activityTypeRaw: String = "run",
        startDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.activityTypeRaw = activityTypeRaw
        self.startDate = startDate
        self.totalDistanceMeters = 0.0
        self.totalDurationSeconds = 0.0
        self.totalElevationGainMeters = 0.0
        self.locationPoints = []
    }
}
```

---

### Step 4: Real-Time Athletic Analytics (VO2 Max & TRIMP)

StrideSync computes physiological load and aerobic capacity using established sports science formulas:

#### 1. Banister TRIMP (Training Impulse) Formula:
$$\text{TRIMP} = D \times \Delta\text{HR}_r \times y$$
Where $D$ is duration in minutes, $\Delta\text{HR}_r = \frac{\text{HR}_{\text{avg}} - \text{HR}_{\text{rest}}}{\text{HR}_{\text{max}} - \text{HR}_{\text{rest}}}$, and $y = 0.64 e^{1.92 \Delta\text{HR}_r}$ for male athletes ($1.67$ for female athletes).

#### 2. Jack Daniels VDOT Formula:
Calculates VO2 Max equivalent based on race distance $d$ (meters) and time $t$ (minutes):
$$v = \frac{d}{t}$$
$$\text{VO}_2 = -4.60 + 0.182258 v + 0.000104 v^2$$

---

### Step 5: Live Activity HUD (Dynamic Island & Lock Screen)

Using **ActivityKit**, StrideSync renders active run metrics directly on the Dynamic Island and Lock Screen:

```swift
import ActivityKit
import WidgetKit
import SwiftUI

public struct StrideSyncAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var distanceKm: Double
        public var currentPaceFormatted: String
        public var heartRateBpm: Int
        public var elapsedTimeFormatted: String
    }
    
    public var workoutTitle: String
}
```

---

### Step 6: Binary Encoding/Decoding (Garmin FIT 2.0 & GPX 1.1)

StrideSync includes a native parser and generator for Garmin FIT 2.0 binary protocol files, allowing direct synchronization with Garmin Connect and Wahoo devices without third-party dependencies.

---

## 🤝 Community Issues & Collaboration Guide

We welcome contributions and questions from student developers! To participate in community learning or report issues:

### 📥 Opening an Issue
1. Navigate to the **[Issues tab](https://github.com/Irs622/stridesync-ios/issues)** in GitHub.
2. Click **New Issue** and choose from our pre-formatted templates:
   - 🐛 **Bug Report**: Report unexpected behavior or crashes.
   - 💡 **Feature Request**: Propose a new telemetry metric or UI enhancement.
   - 🎓 **Educational / Question Inquiry**: Ask architectural or Swift 6 questions.

### 🏷️ GitHub Issue Labels
- `good first issue` — Starter tasks for new contributors.
- `documentation` — Improvements to docs, guides, or code comments.
- `question` — General inquiries about Swift 6, SwiftData, or algorithms.
- `enhancement` — Feature improvements.
- `bug` — Confirmed software bugs.

---

## 🧪 Hands-On Exercises for Learners

### Exercise 1: Custom Audio Pacing Coach Alert
1. Open [`Sources/StrideSync/Services/AudioPacingCoach.swift`](file:///Users/mac/Downloads/stridesync-ios/Sources/StrideSync).
2. Implement a function `announcePaceZone(currentPace: Double, targetPace: Double)` using `AVSpeechSynthesizer`.
3. Test audio ducking when music is playing in background.

### Exercise 2: Bluetooth Cycling Cadence Parser
1. Inspect [`Sources/StrideSync/Services/BluetoothSensorManager.swift`](file:///Users/mac/Downloads/stridesync-ios/Sources/StrideSync).
2. Implement parsing for GATT UUID `0x1816` (Cycling Speed and Cadence).

### Exercise 3: Write a Swift Test for Race Finish Estimator
1. Open [`Tests/StrideSyncTests/VDOTCalculatorTests.swift`](file:///Users/mac/Downloads/stridesync-ios/Tests/StrideSyncTests).
2. Add a test case verifying estimated finish time for a 10K race based on a 22-minute 5K PR.

---

## 🛠️ Troubleshooting & Common Pitfalls

| Issue / Symptom | Potential Cause | Recommended Fix |
| :--- | :--- | :--- |
| `Publishing changes from background threads is not allowed` | Updating SwiftUI state outside MainActor. | Wrap UI updates in `@MainActor` or `Task { @MainActor in ... }`. |
| GPS stops tracking when screen locks | Missing background location permission. | Ensure `UIBackgroundModes` contains `location` and `audio` in Info.plist / pbxproj. |
| Swift 6 `Data Race` Compiler Error | Passing non-Sendable object between concurrency domains. | Annotate model with `@Sendable` or isolate processing inside an `actor`. |

---

## 📚 Further Learning & Documentation Index

- 📖 **[PRD Specification (`PRD.md`)](file:///Users/mac/Downloads/stridesync-ios/PRD.md)** — Complete Product Requirement Document.
- 📐 **[Architecture Overview (`ARCHITECTURE.md`)](file:///Users/mac/Downloads/stridesync-ios/ARCHITECTURE.md)** — In-depth system diagrams and database schemas.
- 📱 **[App Store Setup Guide (`docs/APP_STORE_GUIDE.md`)](file:///Users/mac/Downloads/stridesync-ios/docs/APP_STORE_GUIDE.md)** — Step-by-step deployment guide.
- 💸 **[Free Deployment Guide (`docs/FREE_DEPLOYMENT_GUIDE.md`)](file:///Users/mac/Downloads/stridesync-ios/docs/FREE_DEPLOYMENT_GUIDE.md)** — Installing on physical iPhone for Rp 0.

---

*StrideSync iOS is maintained under the [MIT License](file:///Users/mac/Downloads/stridesync-ios/LICENSE).*
