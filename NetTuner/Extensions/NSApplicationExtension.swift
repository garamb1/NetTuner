//
//  NSApplicationExtension.swift
//  NetTuner
//
//  Created by Vincenzo Garambone on 16/04/24.
//

import Cocoa

extension NSApplication {
    
    static func show(ignoringOtherApps: Bool = true) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: ignoringOtherApps)
    }
    
    static func hide() {
        NSApp.setActivationPolicy(.accessory)
        NSApp.hide(self)
    }
}
