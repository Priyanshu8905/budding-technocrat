import Foundation
import Combine

enum SupabaseConfig {
    // Replace with your Supabase Project URL and Anon Public Key
    static let projectURLString = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://your-project-id.supabase.co"
    static let anonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "your-anon-key-here"
    
    static var projectURL: URL {
        URL(string: projectURLString) ?? URL(string: "https://example.supabase.co")!
    }
    
    static var isConfigured: Bool {
        return !projectURLString.contains("your-project-id") && !anonKey.contains("your-anon-key")
    }
}
