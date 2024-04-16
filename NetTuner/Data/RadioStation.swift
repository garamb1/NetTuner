//
//  RadioStation.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 15/04/24.
//
//

import Foundation
import SwiftData


@Model class RadioStation : Identifiable {
    
    var id: UUID
    @Attribute(.unique) var url: URL
    @Attribute(.unique) var title: String
    
    init(url: URL, title: String) {
        self.id = UUID()
        self.url = url
        self.title = title
    }
}
