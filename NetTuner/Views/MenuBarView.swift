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
    @State private var selectedRadio: RadioStation?
    @State private var radioSortOrder = [KeyPathComparator(\RadioStation.title)]
    var sortedRadios: [RadioStation] {
        radios.sorted(using: radioSortOrder)
    }

    var body: some View {
        VStack {
            List(selection: $selectedRadio) {
                ForEach(sortedRadios, id: \.self) { radio in
                    Text(radio.title)
                        .background(radio == selectedRadio ? Color.accentColor : nil)
                }.onChange(of: selectedRadio, {
                    audioController.start(radio: selectedRadio!)
                })
            }.listStyle(BorderedListStyle())
                .padding()
                .modelContainer(for: RadioStation.self)
            Text(audioController.nowPlayingInfo ?? "None")
            Button("Play") {
                audioController.play()
            }.disabled(audioController.isPlaying)
            Button("Pause") {
                audioController.pause()
            }.disabled(!audioController.isPlaying)
            SettingsLink {
                Text("settings")
            }.keyboardShortcut(",", modifiers: .command)
        }.background()
    }
}

#Preview {
    MenuBarView()
}
