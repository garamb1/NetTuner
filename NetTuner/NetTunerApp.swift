//
//  NetTunerApp.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 15/04/24.
//

import SwiftUI
import CoreData

@main
struct NetTunerApp: App {
    
    var body: some Scene {
        
        MenuBarExtra("NetTuner", systemImage: "hammer") {
            MenuBarView()
                .modelContainer(for: RadioStation.self)
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup("Settings", id: "settings") {
            SettingsView()
                .modelContainer(for: RadioStation.self)
                .onAppear(perform: {
                    NSApplication.show(ignoringOtherApps: true)
                })
                .onDisappear(perform: {
                    NSApplication.hide()
                })
        }
    }
}
