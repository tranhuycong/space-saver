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
  @State private var spaceToDelete: SpaceInfo? = nil

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
              HStack {
                SpacePreview(space: space)
                  .scaledToFit()
                  .cornerRadius(4)
                  .frame(width: 150)
                
                Text(space.name)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                Spacer()
                
                Image(systemName: "trash")
                  .foregroundColor(.gray)
                  .onTapGesture {
                    spaceToDelete = space
                  }
              }
            }
            .buttonStyle(PlainButtonStyle())
            .cornerRadius(8)
            .padding(.vertical, 4)
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
    .confirmationDialog(
      "Are you sure you want to delete \((spaceToDelete != nil) ? spaceToDelete!.name : "this space")?",
      isPresented: Binding(
        get: { spaceToDelete != nil },
        set: { if !$0 { spaceToDelete = nil } }
      ),
      titleVisibility: .visible
    ) {
      Button("Delete", role: .none) {
        if let space = spaceToDelete {
          let index = appService.spaceList.data.firstIndex {
            $0.id == space.id
          }
          if index != nil {
            appService.deleteSpace(at: index!)
          }
        }
        spaceToDelete = nil
      }
      Button("Cancel", role: .cancel) {
        spaceToDelete = nil
      }
    }
  }
}

#Preview {
  ContentView()
}
