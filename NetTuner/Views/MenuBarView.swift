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
    @State private var volume: Double = 100

    @Environment(\.modelContext) var modelContext
    @Query private var radios: [RadioStation]
    @State private var selectedRadio: RadioStation?
    @State private var radioSortOrder = [KeyPathComparator(\RadioStation.title)]
    var sortedRadios: [RadioStation] {
        radios.sorted(using: radioSortOrder)
    }

    var body: some View {
        VStack {
            HStack {
                Text("NetTuner").font(.title)
                    .padding()
                Button(action: {
                    openWindow(id: "settings")
                }) {
                    Image(systemName: "gear")
                }.keyboardShortcut(",", modifiers: .command)
            }

            List(selection: $selectedRadio) {
                ForEach(sortedRadios, id: \.self) { radio in
                    HStack {
                        Text(radio.title)
                            .background(radio == selectedRadio ? Color.accentColor : nil)
                        
                        if radio == selectedRadio {
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        
                    }
                }.onChange(of: selectedRadio, {
                    if (selectedRadio != nil) {
                        audioController.start(radio: selectedRadio!)
                    }
                })
            }.listStyle(BorderedListStyle())
                .modelContainer(for: RadioStation.self)
            
            HStack {
                HStack {
                    Button(action: {
                        selectedRadio = nil
                        audioController.pause()
                    }) {
                        Image(systemName: "stop.circle")
                            .resizable()
                            .frame(width: 32.0, height: 32.0)

                    }.disabled(!audioController.isPlaying)
                    Text(selectedRadio?.title ?? "Not Playing").bold()
                }
                Image(systemName: "speaker.fill")
                Slider(value: $volume, in: 0...100)
                Image(systemName: "speaker.wave.3.fill")
            }.padding()

        }.background()
    }
}

#Preview {
    MenuBarView()
}
