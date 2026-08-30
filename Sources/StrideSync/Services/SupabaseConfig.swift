import Foundation

/// Centralized configuration for StrideSync's live Supabase cloud database instance.
public struct SupabaseConfig: Sendable {
    public static let projectURL: String = "https://xcpyoyrvweobzchnnphj.supabase.co"
    public static let publishableKey: String = "sb_publishable_A22jLzCqH3JIN4lc63z4_A_tahCeWrm"
    public static let restBaseURL: String = "\(projectURL)/rest/v1"
    public static let authBaseURL: String = "\(projectURL)/auth/v1"
}
