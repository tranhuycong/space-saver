//
//  ContentView.swift
//  SpaceSaver
//
//  Created by Tran Cong on 7/10/24.
//

import AppKit
import SwiftUI

enum NavigationItem: Hashable {
    case home
    case space(SpaceInfo)
}

struct ContentView: View {

  @StateObject private var appService = AppService.shared
  @State private var selectedItem: NavigationItem? = .home

  var body: some View {
    NavigationSplitView {
      List(selection: $selectedItem) {
        NavigationLink(value: NavigationItem.home) {
          Label("Home", systemImage: "house")
        }
        
        Divider()
        
        Section(header: Text("Saved Spaces")) {
          ForEach(appService.spaceList.data, id: \.self) { space in
            NavigationLink(value: NavigationItem.space(space)) {
              Text(space.name)
            }
          }
        }
      }
      .listStyle(SidebarListStyle())
      .frame(minWidth: 200)
    } detail: {
        switch selectedItem {
        case .home, .none:
            HomeView()
        case .space(let space):
            SpaceDetail(space: space)
        }
    }
    .frame(minWidth: 1000, minHeight: 600)
  }
}

#Preview {
  ContentView()
}
