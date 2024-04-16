//
//  PreferenceView.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 16/04/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // Swift Data variables
    @Environment(\.modelContext) var modelContext
    @Query private var radios: [RadioStation]
    
    // Table related variables
    @State private var selectedRadio = Set<RadioStation.ID>()
    @State private var radioSortOrder = [KeyPathComparator(\RadioStation.title)]
    @State private var searchText: String = ""
    
    var filteredRadios : [RadioStation] {
        if searchText.count < 2 {
            sortedRadios
        } else {
            sortedRadios.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
 
    var sortedRadios: [RadioStation] {
        radios.sorted(using: radioSortOrder)
    }
    
    var body: some View {
        NavigationStack {
            Table(filteredRadios, selection: $selectedRadio, sortOrder: $radioSortOrder) {
                TableColumn("Name", value: \.title)
                TableColumn("URL") { radio in
                    Text("\(radio.url)")
                }
            }
            .searchable(text: $searchText)
        }
        .navigationTitle("Radio Stations")
        .toolbar {
            ToolbarItem() {
                Button("Add", action: addSamples)
            }
            ToolbarItem() {
                Button("Add Samples", action: addSamples)
            }
            ToolbarItem() {
                Button("Remove All", action: removeAll)
            }
        }
    }
    
    func addSamples() {
        modelContext.insert(RadioStation(url: URL(string: "http://icestreaming.rai.it/1.mp3")!, title: "Rai Radio 1"))
        modelContext.insert(RadioStation(url: URL(string: "http://icestreaming.rai.it/2.mp3")!, title: "Rai Radio 2"))
        modelContext.insert(RadioStation(url: URL(string: "http://icestreaming.rai.it/3.mp3")!, title: "Rai Radio 3"))
    }
    
    func removeAll() {
        do {
            try modelContext.delete(model: RadioStation.self)
        } catch {
            print("Failed to clear all Country and City data.")
        }
    }
}

#Preview {
    SettingsView()
}
