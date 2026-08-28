import SwiftUI

/// Emergency overlay modal presented during hard fall incident countdown with auto-SOS timer.
public struct EmergencyAlertOverlayView: View {
    @State private var fallEngine = FallDetectionEngine.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Pulsing Warning Icon
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Color.red.opacity(0.4))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(Color.white)
                }
                
                VStack(spacing: 8) {
                    Text("BENTURAN KERAS TERDETEKSI!")
                        .font(.system(.title2, design: .rounded, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Mengirimkan panggilan darurat dan lokasi GPS otomatis ke kontak darurat dalam:")
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Countdown Timer Number
                Text("\(fallEngine.countdownSecondsRemaining)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(Color.red)
                
                if let incident = fallEngine.detectedIncident {
                    Text(String(format: "Lokasi: (%.5f, %.5f) | G-Force: %.1fg", incident.coordinate.latitude, incident.coordinate.longitude, incident.peakGForce))
                        .font(.caption.bold())
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                // "I'm OK" Dismiss Button
                Button {
                    fallEngine.dismissIncident()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.title3.bold())
                        Text("SAYA BAIK-BAIK SAJA (BATALKAN)")
                            .font(.system(.headline, design: .rounded, weight: .heavy))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(StrideTheme.athleticGreen)
                    .foregroundStyle(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }
}

