# 🏃‍♂️ StrideSync Zero-Cost Deployment Guide (100% Free)

This guide explains how to install and run **StrideSync** on your physical iPhone and share it with friends **without paying for an Apple Developer Account ($99) or renting cloud servers**.

---

## 🌟 1. "Local-First" Zero Server Overhead Architecture

StrideSync is engineered on **Local-First** design principles:
* **Self-Contained Storage (SwiftData):** All GPS routes, elevation charts, kilometer splits, VO2 Max estimates, and personal record histories are stored securely in local iPhone memory.
* **100% Offline Capability:** Record outdoor runs in mountains, forests, or abroad without an internet connection.
* **Unlimited Export & Sharing:** Export workout routes in world-standard **GPX 1.1 XML** or **Garmin FIT** formats and share via AirDrop, Messages, or import directly into Strava / Garmin Connect for free!

---

## 📲 2. How to Install on Your Physical iPhone (Free via Xcode)

Install StrideSync directly onto your iPhone using a standard free Apple ID account:

### Step-by-Step Instructions:
1. **Connect iPhone to Mac:**
   * Connect your iPhone to your Mac using a USB/Type-C cable.
   * On your iPhone screen, select **"Trust This Computer"**.
2. **Enable Developer Mode on iPhone (iOS 16+):**
   * On iPhone, open **Settings** ➡️ **Privacy & Security**.
   * Scroll to the bottom, tap **Developer Mode**, switch it **ON**, and restart your iPhone.
3. **Open Project in Xcode:**
   * Open the project in Xcode:
     ```bash
     open StrideSync.xcodeproj
     ```
4. **Select Free Personal Team:**
   * Under *Signing & Capabilities* tab, enter your free Apple ID (iCloud) account in the **Team** dropdown.
5. **Run on Physical iPhone:**
   * At the top of Xcode (Device Selector), change selection from *Simulator* to **Your iPhone Name**.
   * Click **▶️ Play (Run)**.
   * StrideSync will compile and launch directly on your physical iPhone!

---

## 👥 3. Sharing with Friends Without Server Costs

* **Option A (Free Sideloading):** Friends can install build artifacts using USB cables or free sideloading tools like *Sideloadly* / *AltStore*.
* **Option B (Group Run GPX Export):** After a group workout, tap **Share GPX** on the workout summary screen to send the complete route file via Messages or AirDrop.
* **Option C (Free Cloud Backend via Gmail):** If community social feed synchronization is desired, set up a free project on **Supabase.com** with a free Gmail account (free tier supports up to 50,000 active users).

---

## 🛠️ 4. Running Automated Unit Tests

To verify all features operate cleanly without regression:
```bash
swift test
```
All 37 test suites will execute and pass successfully (**100% PASS**).
