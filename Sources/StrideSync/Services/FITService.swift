import Foundation

/// Struct representing parsed FIT activity file contents.
public struct FITActivityData: Sendable {
    public let title: String
    public let activityType: ActivityType
    public let startTime: Date
    public let durationSeconds: TimeInterval
    public let distanceMeters: Double
    public let telemetryPoints: [TelemetrySnapshot]
    
    public init(
        title: String,
        activityType: ActivityType,
        startTime: Date,
        durationSeconds: TimeInterval,
        distanceMeters: Double,
        telemetryPoints: [TelemetrySnapshot]
    ) {
        self.title = title
        self.activityType = activityType
        self.startTime = startTime
        self.durationSeconds = durationSeconds
        self.distanceMeters = distanceMeters
        self.telemetryPoints = telemetryPoints
    }
}

/// Service providing export and import capabilities for Garmin FIT 2.0 binary activity files.
public final class FITService: Sendable {
    public static let shared = FITService()
    
    public init() {}
    
    /// Encodes an ActivityRecord and telemetry points into FIT 2.0 binary Data.
    public func encode(activity: ActivityRecord, snapshots: [TelemetrySnapshot]) -> Data {
        var data = Data()
        
        // 1. FIT Header (14 Bytes)
        let headerSize: UInt8 = 14
        let protocolVersion: UInt8 = 0x20 // FIT 2.0
        let profileVersion: UInt16 = 2100 // Profile 21.00
        
        let recordCount = UInt32(snapshots.count)
        let payloadSize: UInt32 = 32 + 64 + (recordCount * 24)
        
        data.append(headerSize)
        data.append(protocolVersion)
        var profVerLittle = profileVersion.littleEndian
        data.append(Data(bytes: &profVerLittle, count: 2))
        var paySizeLittle = payloadSize.littleEndian
        data.append(Data(bytes: &paySizeLittle, count: 4))
        
        // Magic string ".FIT"
        let fitMagic: [UInt8] = [0x2E, 0x46, 0x49, 0x54]
        data.append(contentsOf: fitMagic)
        
        // Header CRC
        var headerCRC: UInt16 = 0x0000
        data.append(Data(bytes: &headerCRC, count: 2))
        
        // 2. File ID Message
        var fileIdData = Data([0x00, 0x00, 0x00, 0x00])
        var startTimeSec = UInt32(max(0, activity.startTime.timeIntervalSince1970 - 631065600)).littleEndian
        fileIdData.append(Data(bytes: &startTimeSec, count: 4))
        fileIdData.append(Data(repeating: 0, count: 24))
        data.append(fileIdData)
        
        // 3. Session Message Block (64 bytes)
        var sessionData = Data([0x01, 0x01])
        var dist = UInt32(activity.distanceMeters * 100).littleEndian
        sessionData.append(Data(bytes: &dist, count: 4))
        var dur = UInt32(activity.durationSeconds * 1000).littleEndian
        sessionData.append(Data(bytes: &dur, count: 4))
        
        let typeCode: UInt8
        switch activity.activityType {
        case .run, .trailRun, .indoorRun: typeCode = 1
        case .ride: typeCode = 2
        case .walk: typeCode = 11
        case .hike: typeCode = 17
        }
        sessionData.append(typeCode)
        sessionData.append(Data(repeating: 0, count: 53))
        data.append(sessionData)
        
        // 4. Telemetry Records (24 bytes per point)
        for point in snapshots {
            var pointData = Data([0x02])
            var latSemicircles = Int32(point.latitude * (2147483648.0 / 180.0)).littleEndian
            var lonSemicircles = Int32(point.longitude * (2147483648.0 / 180.0)).littleEndian
            var altMeters = UInt16((point.altitude + 500) * 5).littleEndian
            var speedMps = UInt16(point.speedMps * 1000).littleEndian
            let hr = UInt8(point.heartRate ?? 0)
            
            pointData.append(Data(bytes: &latSemicircles, count: 4))
            pointData.append(Data(bytes: &lonSemicircles, count: 4))
            pointData.append(Data(bytes: &altMeters, count: 2))
            pointData.append(Data(bytes: &speedMps, count: 2))
            pointData.append(hr)
            pointData.append(Data(repeating: 0, count: 10))
            data.append(pointData)
        }
        
        // 5. File CRC
        var fileCRC = computeCRC(data: data).littleEndian
        data.append(Data(bytes: &fileCRC, count: 2))
        
        return data
    }
    
    /// Parses FIT binary Data back into FITActivityData safely without raw pointer alignment issues.
    public func decode(fitData: Data) throws -> FITActivityData {
        guard fitData.count >= 14 else {
            throw FITError.invalidHeader
        }
        
        let headerSize = fitData[0]
        guard headerSize >= 12 else { throw FITError.invalidHeader }
        
        let magicString = String(bytes: fitData[8..<12], encoding: .ascii)
        guard magicString == ".FIT" else {
            throw FITError.invalidMagicString
        }
        
        var points: [TelemetrySnapshot] = []
        var offset = Int(headerSize)
        
        let now = Date()
        var totalDistance: Double = 0
        var totalDuration: Double = 0
        var detectedType: ActivityType = .run
        
        while offset + 24 <= fitData.count - 2 {
            let recordType = fitData[offset]
            if recordType == 0x01 && offset + 64 <= fitData.count {
                // Session record
                let distUnits = loadUInt32(from: fitData, at: offset + 2)
                let durUnits = loadUInt32(from: fitData, at: offset + 6)
                totalDistance = Double(distUnits) / 100.0
                totalDuration = Double(durUnits) / 1000.0
                
                let actByte = fitData[offset + 10]
                switch actByte {
                case 2: detectedType = .ride
                case 11: detectedType = .walk
                case 17: detectedType = .hike
                default: detectedType = .run
                }
                offset += 64
            } else if recordType == 0x02 && offset + 14 <= fitData.count {
                // Telemetry record
                let latSemi = loadInt32(from: fitData, at: offset + 1)
                let lonSemi = loadInt32(from: fitData, at: offset + 5)
                let altRaw = loadUInt16(from: fitData, at: offset + 9)
                let spdRaw = loadUInt16(from: fitData, at: offset + 11)
                let hr = fitData[offset + 13]
                
                let lat = Double(latSemi) * (180.0 / 2147483648.0)
                let lon = Double(lonSemi) * (180.0 / 2147483648.0)
                let alt = (Double(altRaw) / 5.0) - 500.0
                let speed = Double(spdRaw) / 1000.0
                
                let point = TelemetrySnapshot(
                    timestamp: now.addingTimeInterval(Double(points.count)),
                    latitude: lat,
                    longitude: lon,
                    altitude: alt,
                    speedMps: speed,
                    heartRate: hr > 0 ? Int(hr) : nil,
                    cadence: nil
                )
                points.append(point)
                offset += 24
            } else {
                offset += 1
            }
        }
        
        return FITActivityData(
            title: "FIT Imported Workout",
            activityType: detectedType,
            startTime: now,
            durationSeconds: totalDuration > 0 ? totalDuration : Double(points.count),
            distanceMeters: totalDistance,
            telemetryPoints: points
        )
    }
    
    // MARK: - Safe Alignment Unpackers
    private func loadUInt32(from data: Data, at offset: Int) -> UInt32 {
        let b0 = UInt32(data[offset])
        let b1 = UInt32(data[offset + 1]) << 8
        let b2 = UInt32(data[offset + 2]) << 16
        let b3 = UInt32(data[offset + 3]) << 24
        return b0 | b1 | b2 | b3
    }

    private func loadInt32(from data: Data, at offset: Int) -> Int32 {
        return Int32(bitPattern: loadUInt32(from: data, at: offset))
    }

    private func loadUInt16(from data: Data, at offset: Int) -> UInt16 {
        let b0 = UInt16(data[offset])
        let b1 = UInt16(data[offset + 1]) << 8
        return b0 | b1
    }
    
    private func computeCRC(data: Data) -> UInt16 {
        var crc: UInt16 = 0
        let crcTable: [UInt16] = [
            0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,
            0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400
        ]
        
        for byte in data {
            var tmp = crcTable[Int(crc & 0xF) ^ Int(byte & 0xF)]
            crc = (crc >> 4) ^ tmp
            tmp = crcTable[Int(crc & 0xF) ^ Int(byte >> 4)]
            crc = (crc >> 4) ^ tmp
        }
        return crc
    }
}

public enum FITError: Error {
    case invalidHeader
    case invalidMagicString
    case corruptedData
}
