import SwiftUI

/// Settings view for scanning, connecting, and inspecting external Bluetooth hardware sensors.
public struct BLESensorsSettingsView: View {
    @State private var bleManager = BLEHeartRateAndSensorManager.shared
    
    public init() {}
    
    public var body: some View {
        List {
            // Live Status Section
            Section {
                HStack(spacing: 12) {
                    Image(systemName: bleManager.isScanning ? "antenna.radiowaves.left.and.right" : "sensor.fill")
                        .font(.title2)
                        .foregroundStyle(StrideTheme.primaryOrange)
                        .symbolEffect(.variableColor.iterative, isActive: bleManager.isScanning)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(bleManager.isScanning ? "Memindai Sensor Terdekat..." : "Bluetooth Siap")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        Text("Mendukung Garmin HRM, Polar H10, Power Meter, & Cadence.")
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        if bleManager.isScanning {
                            bleManager.stopScan()
                        } else {
                            bleManager.startScan()
                        }
                    } label: {
                        Text(bleManager.isScanning ? "Berhenti" : "Pindai")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(StrideTheme.primaryOrange)
                            .foregroundStyle(Color.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Konektivitas Bluetooth LE")
            }
            
            // Connected Devices Section
            if !bleManager.connectedDevices.isEmpty {
                Section {
                    ForEach(bleManager.connectedDevices) { device in
                        HStack {
                            Image(systemName: device.sensorType.iconName)
                                .foregroundStyle(StrideTheme.athleticGreen)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.name)
                                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                                Text("Terhubung • Baterai: \(device.batteryLevel ?? 100)%")
                                    .font(.caption2)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Putus") {
                                bleManager.disconnect(device: device)
                            }
                            .font(.caption.bold())
                            .foregroundStyle(Color.red)
                        }
                    }
                } header: {
                    Text("Perangkat Terhubung")
                }
            }
            
            // Discovered Devices Section
            Section {
                if bleManager.discoveredDevices.isEmpty {
                    Text("Belum ada perangkat terdeteksi. Tekan Pindai di atas.")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                } else {
                    ForEach(bleManager.discoveredDevices) { device in
                        HStack {
                            Image(systemName: device.sensorType.iconName)
                                .foregroundStyle(StrideTheme.primaryOrange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(device.name)
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                Text(device.sensorType.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Hubungkan") {
                                bleManager.connect(to: device)
                            }
                            .font(.caption.bold())
                            .foregroundStyle(StrideTheme.primaryOrange)
                        }
                    }
                }
            } header: {
                Text("Perangkat Terdeteksi")
            }
        }
        .navigationTitle("Sensor Eksternal (BLE)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

