//
//  indoor_navigationApp.swift
//  indoor navigation
//
//  Created by Lily Wang on 2024/9/29.
//

import SwiftUI

@main
struct indoor_navigationApp: App {
    @StateObject var indoorNavigationManager = IndoorNavigationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(indoorNavigationManager) 
        }
    }
}
