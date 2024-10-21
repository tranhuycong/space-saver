//
//  SpaceList.swift
//  SpaceSaver
//
//  Created by Tran Cong on 17/10/24.
//
import Foundation

struct SpaceList: Codable {
    var data: [SpaceInfo]
    
    init() {
        data = []
    }

}

