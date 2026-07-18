import Foundation
import Combine

enum SupabaseConfig {
    // Replace with your Supabase Project URL and Anon Public Key
    static let projectURLString = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://udkgjwcekgqzelvpiviy.supabase.co"
    static let anonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "sb_publishable_WbKAifCZHgJiCiLxoIEPPg_EZYQLwXn"
    
    static var projectURL: URL {
        URL(string: projectURLString) ?? URL(string: "https://udkgjwcekgqzelvpiviy.supabase.co")!
    }
    
    static var isConfigured: Bool {
        return !projectURLString.contains("udkgjwcekgqzelvpiviy") && !anonKey.contains("sb_publishable_WbKAifCZHgJiCiLxoIEPPg_EZYQLwXn")
    }
}
