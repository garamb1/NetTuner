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

    @Environment(AudioController.self) private var audioController
    @State private var volume: Float = 1.0

    @Environment(\.modelContext) var modelContext
    @Query private var radios: [RadioStation]
    @State private var selectedRadio: RadioStation?
    @State private var radioSortOrder = [KeyPathComparator(\RadioStation.title)]

    var sortedRadios: [RadioStation] {
        radios.sorted(using: radioSortOrder)
    }

    var body: some View {
        VStack {
            
            // Header
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
                        NSApplication.shared.orderFrontStandardAboutPanel()
                    }) {
                        Text("About")
                    }
                    Button(action: {
                        NSApplication.shared.activate(ignoringOtherApps: true)
                        openWindow(id: "settings")
                    }) {
                        Text("Radio Stations")
                    }.keyboardShortcut(",", modifiers: .command)
                    
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Text("Quit")
                    }.keyboardShortcut("q", modifiers: .command)
                    
                } label: {
                    Image(systemName: "gear")
                }.fixedSize()
                 .menuStyle(.borderlessButton)

            }.frame(maxWidth: .infinity, alignment: .center)
             .padding()

            // Radio List
            if !sortedRadios.isEmpty {
                List(selection: $selectedRadio) {
                    ForEach(sortedRadios, id: \.self) { radio in
                        HStack {
                            Text(radio.title)
                            
                            if radio == selectedRadio {
                                switch audioController.status {
                                case .playing:
                                    Image(systemName: "play.fill")
                                case .paused:
                                    Image(systemName: "pause.fill")
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
            
            // Playback controls
            VStack {
                HStack {

                    switch audioController.status {
                    case .paused:
                        Button(action: {
                            audioController.play()
                        }) {
                            Image(systemName: "play.circle")
                                .font(.largeTitle)
                        }.buttonStyle(PlainButtonStyle())
                    
                    case .playing:
                        Button(action: {
                            audioController.pause()
                        }) {
                            Image(systemName: "pause.circle")
                                .font(.largeTitle)
                        }.buttonStyle(PlainButtonStyle())

                    case .loading:
                        Image(systemName: "network")
                            .symbolEffect(.pulse)
                            .font(.largeTitle)
                        
                    case .failed:
                        Image(systemName: "network.slash")
                            .symbolEffect(.pulse)
                            .font(.largeTitle)
                        
                    default:
                        Image(systemName: "music.note").font(.largeTitle)
                    }

                    
                    switch audioController.status {
                    case .playing, .paused:
                        Button(action: {
                            selectedRadio = nil
                            audioController.stop()
                        }) {
                            Image(systemName: "stop.circle")
                                .font(.title)
                        }.buttonStyle(PlainButtonStyle())
                    default:
                        EmptyView()
                    }
                    
                    Spacer()

                    Text(audioController.statusString).font(.title)

                    Spacer()
                }.padding()
                    .cornerRadius(20) /// make the background rounded
                    .overlay( /// apply a rounded border
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                    )
                    .background(.ultraThinMaterial)
                
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
