# 🤝 Official StrideSync Contributing Guidelines

Welcome to the **StrideSync iOS** project! To maintain telemetry-grade reliability, athlete data privacy, and **Swift 6** architectural integrity, all contributors are required to adhere to the software engineering standards set forth in this document.

---

## 🏛️ 1. Engineering Principles

1. ⚡️ **Swift 6 Data-Race Safety:** All new code must compile under Swift 6 Strict Concurrency without warnings (*zero warnings*).
2. 🛡️ **Privacy & Security First:** Sensitive user location data (home/office) must be sanitized with geofence masking, and credentials/tokens must be stored in **Apple Keychain**.
3. 💾 **Local-First & Schema Integrity:** The app must be 100% functional offline. Any changes to `@Model` data structures must include versioned schema migration plans (`StrideSyncSchema` / `SchemaMigrationPlan`).
4. 🧪 **100% Passing Test Gate:** Pull Requests (PRs) will not be merged if any unit tests fail (*broken build*).

---

## 🌿 2. Git Workflow & Branch Naming Conventions

### 2.1 Branch Name Format
Use a task type prefix followed by a specific lower-case module/feature name in kebab-case:

| Type | Naming Pattern | Example |
| :--- | :--- | :--- |
| **New Feature** | `feature/<feature-name>` | `feature/live-safety-beacon`, `feature/pacing-coach` |
| **Bug Fix** | `bugfix/<bug-description>` | `bugfix/fix-gpx-elevation-overflow`, `bugfix/split-pause-drift` |
| **Performance** | `perf/<optimization-target>`| `perf/kalman-filter-memory`, `perf/mapkit-overlay-fps` |
| **Refactoring** | `refactor/<module-name>` | `refactor/location-engine-actors`, `refactor/ble-manager` |
| **Documentation**| `docs/<doc-name>` | `docs/update-architecture-v2`, `docs/api-reference` |

### 2.2 Step-by-Step Workflow
1. **Fork & Clone** the repository to your local machine:
   ```bash
   git clone https://github.com/Irs622/stridesync-ios.git
   cd stridesync-ios
   ```
2. **Synchronize with the latest `main` branch:**
   ```bash
   git checkout main
   git pull origin main
   ```
3. **Create a new branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Write code, documentation, and unit tests.**
5. **Run local test suite:**
   ```bash
   swift test
   ```
6. **Submit structured commits and create a Pull Request.**

---

## 📝 3. Commit Message Standards (Conventional Commits v1.0)

Commit messages must follow the **[Conventional Commits](https://www.conventionalcommits.org/)** specification:

```text
<type>(<optional scope>): <short description in imperative mood>

[optional body explaining rationale and trade-offs]
[optional footer referencing issues or breaking changes]
```

### Allowed Prefix Types:
* `feat:` A new feature for the user.
* `fix:` A bug fix in system or algorithms.
* `refactor:` Code changes without altering external functionality.
* `perf:` Improvements to computational efficiency, memory, or battery.
* `test:` Adding or updating unit test suites.
* `docs:` Changes to `.md` documentation files (PRD, README, ARCHITECTURE, etc.).
* `security:` Improvements to encryption, geofence data sanitization, or Keychain handling.
* `chore:` Maintenance of dependencies, CI/CD build configuration, or automation scripts.

### Examples of Good Commit Messages:
```bash
feat(pacing): implement dynamic audio cue feedback for target splits
fix(navigation): resolve cross-track error threshold on sharp hairpin turns
test(training-load): add Banister TRIMP exponential decay unit tests
security(privacy): enforce 200m geofence masking before exporting GPX files
```

---

## 🛡️ 4. Code Quality & Strict Engineering Rules

### 4.1 Swift 6 Concurrency & Actor Isolation
* **Actor Boundary Safety:** Never send non-`Sendable` data types across Actor boundaries. Always create snapshot structs (e.g., `TelemetrySnapshot`, `SplitSnapshot`, `PacingTarget`).
* **Hardware & Heavy Computation Isolation:** All continuous GPS calculations must reside inside `actor LocationEngine`, while UI updates must be isolated to `@MainActor`.
* **Zero Force Unwrapping:** Force unwrapping `!` is strictly prohibited in production code except static mock test constants. Use `guard let`, `if let`, or default fallback `??`.
* **Non-Blocking Execution:** Never call `Thread.sleep(...)` on async workflows. Always use `Task.sleep(nanoseconds:)`.

### 4.2 Database Persistence & SwiftData Schema Migration
* Do not alter `@Model` properties directly without registering them in versioned schemas (`StrideSyncSchema.swift`).
* Every table structure migration (adding, removing, or changing relationships) must include tested `SchemaMigrationPlan` to prevent app crashes for existing users.

### 4.3 Geospatial Data Privacy & Security
* Every public file export function (`GPXService`, `FITService`, Web Live Beacon) **must** pass coordinate points through sanitization filters around user home/office via `PrivacyZoneService`.
* Sensitive credentials, authentication tokens, and private keys **must** be saved in Apple Keychain Security Framework via `KeychainManager`. Plaintext storage in `UserDefaults` is strictly forbidden.

---

## 📄 License

By contributing to **StrideSync iOS**, you agree that your contributions will be licensed under its **[MIT License](LICENSE)**.
