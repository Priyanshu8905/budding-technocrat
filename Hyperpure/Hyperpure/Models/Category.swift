import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let icon: String
    let colorHex: String
    let shortName: String
}
