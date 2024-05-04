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
                Text("NetTuner").font(.largeTitle)
                Label("", systemImage: "wave.3.forward")
                    .symbolEffect(.bounce.up.byLayer,
                                  options: audioController.status == AudioControllerStatus.playing ? .repeating : .nonRepeating,
                                  value: audioController.status)
                    .font(.title)
                Spacer()
                Menu {
                    Button(action: {
                        openWindow(id: "settings")
                    }) {
                        Text("Radio Stations")
                    }.keyboardShortcut(",", modifiers: .command)
                    
                    Button(action: {
                        exit(0)
                    }) {
                        Text("Quit")
                    }.keyboardShortcut("q", modifiers: .command)
                    
                } label: {
                    Image(systemName: "gear")
                }.fixedSize()
                 .menuStyle(.borderlessButton)

            }.frame(maxWidth: .infinity, alignment: .center)
             .padding()

            if !sortedRadios.isEmpty {
                List(selection: $selectedRadio) {
                    ForEach(sortedRadios, id: \.self) { radio in
                        HStack {
                            Text(radio.title)
                                .background(radio == selectedRadio ? Color.accentColor : nil)
                            
                            if radio == selectedRadio {
                                switch audioController.status {
                                case .playing:
                                    Image(systemName: "speaker.wave.3.fill")
                                case .loading:
                                    Image(systemName: "network").symbolEffect(.pulse)
                                case .failed:
                                    Image(systemName: "network.slash")
                                default:
                                    EmptyView()
                                }
                            }
                            
                        }
                    }.onChange(of: selectedRadio, {
                        if (selectedRadio != nil) {
                            audioController.start(radio: selectedRadio!)
                        }
                    })
                }.listStyle(BorderedListStyle())
                    .modelContainer(for: RadioStation.self)
                    .padding(.horizontal)
            }
            
            VStack {
                HStack {
                    Button(action: {
                        selectedRadio = nil
                        audioController.stop()
                        stopAnimationToggle.toggle()
                    }) {
                        Label(audioController.statusString, systemImage: "stop.circle")
                            .symbolEffect(.bounce, options: .speed(3), value: stopAnimationToggle)
                            .font(.largeTitle)
                    }.disabled(audioController.status != .playing)
                        .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }.padding()
                    .cornerRadius(20) /// make the background rounded
                    .overlay( /// apply a rounded border
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                    )
                
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $volume, in: 0...1, onEditingChanged: {_ in
                        audioController.setVolume(volume: volume)
                    })
                    Image(systemName: "speaker.wave.3.fill")
                }.padding(.vertical)
                
            }.padding()

        }.background()
    }
}

#Preview {
    MenuBarView()
}
