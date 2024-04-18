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
        
        MenuBarExtra("NetTuner", systemImage: "radio") {
            MenuBarView()
                .modelContainer(for: RadioStation.self)
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 400, height: 300)
        
        Window("Radio Stations", id: "settings") {
            SettingsView().modelContainer(for: RadioStation.self)
        }
    }
}
