import Foundation
import SwiftData

/// Schema V1 definition for StrideSync persistent models.
public enum StrideSyncSchemaV1: VersionedSchema {
    public static let versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    
    public static var models: [any PersistentModel.Type] {
        [
            ActivityRecord.self,
            TelemetryPoint.self,
            DistanceSplit.self,
            Segment.self,
            GearItem.self
        ]
    }
}

/// Migration Plan for StrideSync SwiftData containers.
public enum StrideSyncMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [StrideSyncSchemaV1.self]
    }
    
    public static var stages: [MigrationStage] {
        []
    }
}
