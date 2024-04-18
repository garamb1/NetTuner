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
    @State private var volume: Float = 1.0

    @Environment(\.modelContext) var modelContext
    @Query private var radios: [RadioStation]
    @State private var selectedRadio: RadioStation?
    @State private var radioSortOrder = [KeyPathComparator(\RadioStation.title)]
    
    // Animation Toggles
    @State private var stopAnimationToggle: Bool = false
    
    var sortedRadios: [RadioStation] {
        radios.sorted(using: radioSortOrder)
    }

    var body: some View {
        VStack {
            HStack {
                Label("", systemImage: "wave.3.backward")
                    .symbolEffect(.bounce.up.byLayer,
                                  options: audioController.isPlaying ? .repeating : .nonRepeating,
                                  value: audioController.isPlaying)
                    .font(.largeTitle)
                Text("NetTuner").font(.largeTitle)
                Label("", systemImage: "wave.3.forward")
                    .symbolEffect(.bounce.up.byLayer,
                                  options: audioController.isPlaying ? .repeating : .nonRepeating,
                                  value: audioController.isPlaying)
                    .font(.largeTitle)
                Spacer()
                Button(action: {
                    openWindow(id: "settings")
                }) {
                    Text("Radio Stations...")
                    Image(systemName: "gear")
                }.keyboardShortcut(",", modifiers: .command)
                
            }.frame(maxWidth: .infinity, alignment: .center)
             .padding()

            if !sortedRadios.isEmpty {
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
                    .padding()
            }
            
            HStack {
                Button(action: {
                    selectedRadio = nil
                    audioController.pause()
                    stopAnimationToggle.toggle()
                }) {
                    Label(selectedRadio?.title ?? "Not Playing", systemImage: "stop.circle")
                        .symbolEffect(.bounce, options: .speed(3), value: stopAnimationToggle)
                        .font(.title)
                }.disabled(!audioController.isPlaying)
                 .buttonStyle(PlainButtonStyle())

                Spacer()
            }.padding()
            
            HStack {
                Image(systemName: "speaker.fill")
                Slider(value: $volume, in: 0...1, onEditingChanged: {_ in 
                    audioController.setVolume(volume: volume)
                })
                Image(systemName: "speaker.wave.3.fill")
            }.padding()

        }.background()
    }
}

#Preview {
    MenuBarView()
}
