//
//  SettingsView.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 16/04/24.
//

import SwiftUI
import SwiftData
import SwiftCSV

struct SettingsView: View {

    // Swift Data variables
    @Environment(\.modelContext) var modelContext
    @Query private var radios: [RadioStation]
    
    // Table related variables
    @State private var selectedRadios = Set<RadioStation.ID>()
    @State private var radioSortOrder = [KeyPathComparator(\RadioStation.title)]
    @State private var searchText: String = ""
    
    // Addition & import popover
    @State private var showingAddPopover = false;
    @State private var showingImportPopover = false;
    
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
        Table(filteredRadios, selection: $selectedRadios, sortOrder: $radioSortOrder) {
            TableColumn("Name", value: \.title)
            TableColumn("URL") { radio in
                Text("\(radio.url)")
            }
        }
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem() {
                Button("Add", systemImage: "plus", action: {
                    showingAddPopover = true
                }).popover(isPresented: $showingAddPopover, content: {
                    AddRadioView()
                })
            }
            ToolbarItem() {
                Button("Remove", systemImage: "minus", action: {
                    deleteSelection()
                }).disabled(radios.isEmpty)
            }
            ToolbarItem() {
                Button("Add", systemImage: "square.and.arrow.down", action: {
                    showingImportPopover = true
                }).popover(isPresented: $showingImportPopover, content: {
                    ImportView()
                })
            }
        }
    }
    
    func deleteSelection() {
        if selectedRadios.count < 1 {
            return
        }
        
        try? modelContext.delete(
            model: RadioStation.self,
            where: #Predicate{
                item in selectedRadios.contains(item.id)
            })
    }
}

struct AddRadioView : View {
    @Environment(\.dismiss) var dismiss

    @Environment(\.modelContext) var modelContext
    @State private var title = ""
    @State private var urlString = ""

    
    var body: some View {
        VStack {
            Form {
                TextField("Radio Station:", text: $title).lineLimit(1)
                TextField("URL:", text: $urlString).lineLimit(1)
            }.padding()
            
            HStack {
                Spacer()
                Button("Cancel", action: {
                    dismiss()
                }).keyboardShortcut(.cancelAction)
                Button("Add", action: {
                    let url = URL(string: urlString)
                    if (url != nil) {
                        let newRadio = RadioStation(url: url!, title: title)
                        addRadioStation(radioStation: newRadio)
                        resetInputs()
                        dismiss()
                    }
                })
                .disabled(title.isEmpty && urlString.isEmpty)
                .keyboardShortcut(.defaultAction)
            }.padding()
        }.frame(minWidth: 300)
    }
    
    
    func addRadioStation(radioStation: RadioStation) {
        modelContext.insert(radioStation)
    }
    
    func resetInputs() {
        title = ""
        urlString = ""
    }
}


struct ImportView : View {
    @State private var importing = false
    @State private var processing = false;
    @State private var importError : String?;
    
    @Environment(\.modelContext) var modelContext

    var body: some View {
        VStack {
            Text("Import a CSV Radio List").font(.title)
            
            if processing {
                HStack {
                    ProgressView()
                    Text("Importing...")
                }.padding()
                    .interactiveDismissDisabled()
            } else {
                HStack {
                    Text("Choose a file...")
                    Button("Import") {
                        importing = true
                    }
                    .fileImporter(
                        isPresented: $importing,
                        allowedContentTypes: [.plainText, .commaSeparatedText]
                    ) { result in
                        switch result {
                        case .success(let file):
                            processing = true
                            loadFromCsv(fileUrl: file)
                        case .failure(let error):
                            importError = "Access Error"
                        }
                    }
                }.padding()
            }
        }.padding()
    }
    
    func loadFromCsv(fileUrl : URL) {
        
        do {
            let csvFile: CSV = try CSV<Named>(url:fileUrl)
            for row in csvFile.rows {
                let url = URL(string: row["url"]!)
                let newRadio = RadioStation(url: url!, title: row["title"]!)
                addRadioStation(radioStation: newRadio)
            }
        } catch {
            print(error)
        }
        processing = false
    }
    
    func addRadioStation(radioStation: RadioStation) {
        modelContext.insert(radioStation)
    }
}

#Preview {
    SettingsView()
}
