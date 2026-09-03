# 🔒 Athlete Security & Privacy Policy

Athlete data security and location information privacy are top priorities in the development of **StrideSync iOS**. This document outlines our security policies, data protection mechanisms, and vulnerability reporting procedures in accordance with GitHub Security standards.

---

## 🛡️ 1. Supported Versions

We actively maintain and issue security patches for the following versions:

| Version | Support Status | Security Notes |
| :--- | :--- | :--- |
| **v0.5.x-beta (Latest)** | :white_check_mark: **Fully Supported** | Swift 6 Strict Concurrency, Keychain Encryption, Geofence Masking |
| **< 0.5** | :x: Unsupported | Initial development releases |

---

## 🏛️ 2. Data Protection & Privacy Standards

1. **Geofencing Coordinate Sanitization (`PrivacyZoneService`):**
   * All GPS coordinates within an athlete's privacy zone radius (home, school, or office) are automatically masked before routes are uploaded to public timelines or exported to GPX/FIT files.
2. **Credential Encryption in Apple Keychain (`KeychainManager`):**
   * Authentication JWT tokens, passwords, and private keys are stored encrypted in **Apple Keychain Services** (`kSecClassGenericPassword`) with Secure Enclave hardware isolation.
3. **Local-First Data Isolation:**
   * Activity history and sensor recordings are stored locally on the device using **SwiftData**. Data is never transmitted to third-party servers without explicit athlete consent.
4. **Bluetooth LE Communication Security (`CoreBluetooth`):**
   * Heart rate and power meter data packets are processed locally in isolated system queues without persisting permanent tracking identifiers across workout sessions.
5. **PostgreSQL Row Level Security (RLS):**
   * Supabase cloud database enforces strict RLS policies ensuring each athlete can only read/write their own data.

---

## 📬 3. Reporting a Vulnerability

If you discover a security vulnerability or potential privacy leak in StrideSync source code:

1. **Do not open a public Issue on GitHub.**
2. Report it confidentially via **[GitHub Private Vulnerability Reporting](https://github.com/Irs622/stridesync-ios/security/advisories/new)** or send an email to **[ichalprov@gmail.com](mailto:ichalprov@gmail.com)** with subject `[SECURITY] StrideSync Vulnerability Report`.
3. Include the following details in your report:
   * Detailed description of the vulnerability.
   * Steps to reproduce the issue (*proof-of-concept payload*).
   * Affected iOS / macOS system version and commit hash.

### Response Commitment:
* We will acknowledge receipt of your report within **24–48 hours**.
* The development team will analyze the impact and issue a patch/hotfix as quickly as possible.
* You will be credited in our release notes (*Security Acknowledgments*) as appreciation for your contribution.

---
*Thank you for helping keep the StrideSync athletic community safe and private!*
