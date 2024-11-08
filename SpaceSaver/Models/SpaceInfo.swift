import Foundation

struct SpaceInfo: Identifiable, Codable {
    var id = UUID()
    var name: String
    var windowList: [WindowInfo]

    init?(windowList: [WindowInfo]) {
        self.windowList = windowList
        self.name = "Space \(id.uuidString.prefix(6))"
    }
}
