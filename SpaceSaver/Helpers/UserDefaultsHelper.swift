//
//  UserDefaultsHelper.swift
//  SpaceSaver
//
//  Created by Tran Cong on 16/10/24.
//

import Foundation

struct UserDefaultsHelper {
    static var spaceList: SpaceList {
        get {
            if let data = UserDefaults.standard.data(forKey: "spaceList") {
                do {
                    let decoded = try JSONDecoder().decode(SpaceList.self, from: data)
                    return decoded
                } catch {
                    print("Failed to decode SpaceList: \(error)")
                }
            }
            return SpaceList()
        }
        set {
            do {
                let encoded = try JSONEncoder().encode(newValue)
                print("Encoded SpaceList size: \(Double(encoded.count) / 1_000_000.0) MB")
                UserDefaults.standard.set(encoded, forKey: "spaceList")
            } catch {
                print("Failed to encode SpaceList: \(error)")
            }
        }
    }
}
