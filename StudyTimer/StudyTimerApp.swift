//
//  StudyTimerApp.swift
//  StudyTimer
//
//  Created by Pursuit on 6/13/25.
//

import SwiftUI
import SwiftData

@main
struct StudyTimerApp: App {
    var body: some Scene {
        let dataManager = SwiftDataManager.shared
        WindowGroup {
            ContentView(dataManager: dataManager)
        }
        .modelContainer(dataManager.sharedModelContainer)
    }
}
