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
    
    @State var audioController: AudioController = AudioController()
    
    var body: some Scene {
        
        MenuBarExtra {
            MenuBarView()
                .modelContainer(for: RadioStation.self)
                .environment(audioController)
        } label: {
            HStack {
                if audioController.status == .playing {
                    Image(systemName: "radio.fill")
                } else {
                    Image(systemName: "radio")
                }
            }
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 300, height: 350)
        
        Window("Radio Stations", id: "settings") {
            SettingsView().modelContainer(for: RadioStation.self)
        }
    }
}
