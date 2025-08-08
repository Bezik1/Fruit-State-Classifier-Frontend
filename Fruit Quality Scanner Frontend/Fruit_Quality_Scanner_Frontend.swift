//
//  Fruit_Quality_Scanner_FrontendApp.swift
//  Fruit Quality Scanner Frontend
//
//  Created by MacBook Mateusz Adamowicz on 08/08/2025.
//

import SwiftUI

@main
struct Fruit_Quality_Scanner_FrontedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 410, maxWidth: 410, minHeight: 650, maxHeight: 650)
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        window.setContentSize(NSSize(width: 440, height: 650))
                        window.minSize = NSSize(width: 440, height: 650)
                        window.maxSize = NSSize(width: 440, height: 650)
                    }
                }
        }
    }
}
