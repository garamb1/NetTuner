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
        
        Window("Radio Stations", id: "settings") {
            SettingsView().modelContainer(for: RadioStation.self)
        }
    }
}
