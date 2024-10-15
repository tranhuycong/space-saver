import Foundation

class WindowInfo: Identifiable {
    var id = UUID()
    var layer: Int
    var memoryUsage: Int
    var windowNumber: Int
    var ownerPID: Int
    var isOnscreen: Bool
    var storeType: Int
    var bounds: CGRect
    var sharingState: Int
    var ownerName: String
    var alpha: Float
    
    init?(dictionary: [String: Any]) {
        guard let layer = dictionary["kCGWindowLayer"] as? Int,
              let memoryUsage = dictionary["kCGWindowMemoryUsage"] as? Int,
              let windowNumber = dictionary["kCGWindowNumber"] as? Int,
              let ownerPID = dictionary["kCGWindowOwnerPID"] as? Int,
              let isOnscreen = dictionary["kCGWindowIsOnscreen"] as? Int,
              let storeType = dictionary["kCGWindowStoreType"] as? Int,
              let boundsDict = dictionary["kCGWindowBounds"] as? [String: Any],
              let height = boundsDict["Height"] as? CGFloat,
              let width = boundsDict["Width"] as? CGFloat,
              let x = boundsDict["X"] as? CGFloat,
              let y = boundsDict["Y"] as? CGFloat,
              let sharingState = dictionary["kCGWindowSharingState"] as? Int,
              let ownerName = dictionary["kCGWindowOwnerName"] as? String,
              let alpha = dictionary["kCGWindowAlpha"] as? Float else {
            return nil
        }
        
        self.layer = layer
        self.memoryUsage = memoryUsage
        self.windowNumber = windowNumber
        self.ownerPID = ownerPID
        self.isOnscreen = isOnscreen == 1
        self.storeType = storeType
        self.bounds = CGRect(x: x, y: y, width: width, height: height)
        self.sharingState = sharingState
        self.ownerName = ownerName
        self.alpha = alpha
    }
}
