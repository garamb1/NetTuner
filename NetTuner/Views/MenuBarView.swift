//
//  MenuBarView.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 15/04/24.
//

import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Environment(\.openWindow) var openWindow

    @ObservedObject var audioController: AudioController = AudioController()

    @Environment(\.modelContext) var modelContext
    @Query private var radios: [RadioStation]

    var body: some View {
        NavigationStack {
            List {
                ForEach(radios, id: \.self) { radio in
                    Section {
                        Text(radio.title)
                            .font(.headline)
                        Text(radio.url.absoluteString)
                    }.onTapGesture(perform: {
                        audioController.start(url: radio.url)
                    })
                }
            }.listStyle(SidebarListStyle())
        }
        .modelContainer(for: RadioStation.self)
        .padding()
        Text(audioController.nowPlayingInfo ?? "None")
        Button("Play") {
            audioController.play()
        }.disabled(audioController.isPlaying)
        Button("Pause") {
            audioController.pause()
        }.disabled(!audioController.isPlaying)
        Button("Settings") {
            openWindow(id: "settings")
        }
    }
}

#Preview {
    MenuBarView()
}
