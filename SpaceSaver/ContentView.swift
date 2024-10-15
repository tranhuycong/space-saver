//
//  ContentView.swift
//  SpaceSaver
//
//  Created by Tran Cong on 7/10/24.
//

import ApplicationServices
import Cocoa
import CoreGraphics
import SwiftUI

struct ContentView: View {
    @State private var spaceInfoList: [WindowInfo] = []
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("SpaceSaver need access to your screen to get space info")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            Button("Accessibility settings") {
                NSWorkspace.shared.open(
                    URL(
                        string:
                            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                    )!)
            }
            Button("Open app") {
                openAppAndPosition()
            }
            Button("Get Space Info") {
                getAllOpenWindows()
            }
            List(spaceInfoList) { windowInfo in
                VStack(alignment: .leading) {
                    Text("Owner: \(windowInfo.ownerName)")
                    Text("PID: \(windowInfo.ownerPID)")
                    Text("Memory Usage: \(windowInfo.memoryUsage) KB")
                    Text("Bounds: \(windowInfo.bounds)")
                }
                .padding()
            }
        }
        .padding()
    }

    func getAllOpenWindows() {
        let options = CGWindowListOption(
            arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowsListInfo as! [[String: Any]]
        let visibleWindows = infoList.filter {
            $0["kCGWindowLayer"] as! Int == 0
        }

        print(visibleWindows)
        spaceInfoList = visibleWindows.compactMap(WindowInfo.init)
    }

    func openAppAndPosition() {
        let url =
            NSURL(
                fileURLWithPath: "/System/Applications/Utilities/Terminal.app",
                isDirectory: true)
            as URL

        let path = "/bin"
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [path]
        configuration.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(
            at: url,
            configuration: configuration,
            completionHandler: nil)
    }
}

extension Array {
    static func fromCFArray(records: CFArray?) -> [Element]? {
        var result: [Element]?
        if let records = records {
            for i in 0..<CFArrayGetCount(records) {
                let unmanagedObject: UnsafeRawPointer = CFArrayGetValueAtIndex(
                    records, i)
                let rec: Element = unsafeBitCast(
                    unmanagedObject, to: Element.self)
                if result == nil {
                    result = [Element]()
                }
                result!.append(rec)
            }
        }
        return result
    }
}

#Preview {
    ContentView()
}
