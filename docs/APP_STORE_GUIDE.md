# 🍎 Complete App Store & TestFlight Deployment Guide (StrideSync iOS)

This document is the official step-by-step guide for registering, testing (*TestFlight*), and releasing **StrideSync** to the **Apple App Store**.

---

## 1. 📋 Account & App Store Connect Setup
1. **Enroll in Apple Developer Program:**
   * Go to [developer.apple.com/programs](https://developer.apple.com/programs/) ($99 USD/year).
2. **Create App ID & Provisioning Profile:**
   * **Bundle Identifier:** `com.stridesync.ios`
   * **Enabled Capabilities:**
     * `Sign in with Apple`
     * `HealthKit`
     * `Push Notifications`
     * `Background Modes` (Location updates, Audio, Background fetch)
3. **Create App in App Store Connect:**
   * Log in to [appstoreconnect.apple.com](https://appstoreconnect.apple.com).
   * Click `+` -> **New App**.
   * **Name:** `StrideSync: Running & GPS Tracker`
   * **Primary Language:** `English (U.S.)`
   * **Primary Category:** `Health & Fitness`
   * **Secondary Category:** `Sports`

---

## 2. 📝 Metadata & App Store Optimization (ASO)

### **App Title:**
`StrideSync – GPS Run & Social Fitness`

### **Subtitle (30 Characters):**
`Running, GPS Routes & Community`

### **Keywords (100 Characters):**
`running,run,strava,gps,marathon,jogging,route,metronome,vo2max,cycling,healthkit,community,radar`

### **Description:**
```text
Elevate your daily running and athletic performance with StrideSync – your telemetry-grade GPS tracker, intelligent biomechanics guide, and modern athletic community.

KEY FEATURES:
• 📍 Precision GPS Tracking: Record distance, pace, 1-km splits, and elevation gains with high accuracy.
• 🎙️ Audio Coach (Audio Cues): Receive real-time pace and split announcements directly in your earphones.
• 🗺️ 3D Flyover Replay: Replay your recorded routes in an immersive 3D satellite camera simulation.
• 🔋 Cadence Metronome & Biomechanics: Sync your stride to 170-190 SPM rhythm for optimal running efficiency.
• 📡 Live Buddy Radar & Safety Beacon: Monitor nearby running companions and share emergency live tracking links via SMS.
• 🥇 Segments & All-Time PRs: Conquer local street segments and collect personal record trophies.
• ⌚ Apple Health & Apple Watch Sync.

Ready to step further? Download StrideSync today and start running!
```

---

## 3. 🔒 Apple Privacy Questionnaire Answers (App Store Review)
When completing the **App Privacy** section in App Store Connect:
* **Location:**
  * *Collected:* Yes.
  * *Purpose:* App Functionality (Tracking workout routes & segments).
  * *Linked to User:* Yes.
* **Health & Fitness (HealthKit):**
  * *Collected:* Yes (Heart rate & calories).
  * *Purpose:* Analytics & App Functionality.
  * *Used for Advertising:* **NO** (Important: Never select advertising for HealthKit).
* **Contact Info (Email/Name):**
  * *Collected:* Yes (For Sign in with Apple authentication).

---

## 4. 🚀 Automated Build & Upload to TestFlight

Run the release build script provided in terminal:
```bash
chmod +x scripts/build_release_ipa.sh
./scripts/build_release_ipa.sh
```

The resulting `.ipa` or `.xcarchive` will be ready for upload using **Xcode Organizer** or the **Transporter App** on macOS!
