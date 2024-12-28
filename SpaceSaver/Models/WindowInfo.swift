//
//  WindowInfo.swift
//  SpaceSaver
//
//  Created by Tran Cong on 17/10/24.
//
import Foundation

struct WindowInfo: Identifiable, Codable, Hashable {
  var id = UUID()
  var isOnscreen: Bool
  var ownerName: String
  let xPercent: CGFloat
  let yPercent: CGFloat
  let widthPercent: CGFloat
  let heightPercent: CGFloat

  init?(dictionary: [String: Any]) {
    guard dictionary["kCGWindowLayer"] as? Int != nil,
      let isOnscreen = dictionary["kCGWindowIsOnscreen"] as? Int,
      let ownerName = dictionary["kCGWindowOwnerName"] as? String,
      let xPercent = dictionary["xPercent"] as? CGFloat,
      let yPercent = dictionary["yPercent"] as? CGFloat,
      let widthPercent = dictionary["widthPercent"] as? CGFloat,
      let heightPercent = dictionary["heightPercent"] as? CGFloat
    else {
      return nil
    }

    self.isOnscreen = isOnscreen == 1
    self.ownerName = ownerName
    self.xPercent = xPercent
    self.yPercent = yPercent
    self.widthPercent = widthPercent
    self.heightPercent = heightPercent
  }
}
