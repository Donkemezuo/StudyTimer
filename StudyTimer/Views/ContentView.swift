//
//  ContentView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/13/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel:  ViewModel
    let dataManager: SwiftDataProtocol
    
    init(dataManager: SwiftDataProtocol) {
        let viewModel = ViewModel(dataManager: dataManager)
        _viewModel = State(initialValue: viewModel)
        self.dataManager =  dataManager
        self.setupTabBarAppearance()
    }

    var body: some View {
        VStack {
            if let previousStudySession = viewModel.previousStudySession {
                TabView {
                    CreateSessionView(viewModel: .init(studySession: previousStudySession, dataManager: dataManager))
                        .tabItem {
                            Image(systemName: "timer")
                            Text("Study")
                        }
                        .tag(0)
                    NavigationStack {
                        HistoryView(viewModel: .init(dataManager: dataManager))
                    }
                    .tabItem {
                        Image(systemName: "bookmark")
                        Text("History")
                    }.tag(1)
                }
                .accentColor(.cardBackground)
            } else {
                CreateSessionView(viewModel: .init(dataManager: dataManager))
            }
        }
        .onAppear {
            Task {
                try viewModel.fetchPreviousStudySession()
            }
        }
    }
    
    func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()

        // Set your desired background color
        tabBarAppearance.backgroundColor = .screenBackground

        // Customize selected item appearance color (accent color)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .cardBackground
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.cardBackground]

        // Apply to standard and scrollEdgeAppearance (for iOS 15+)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

}

extension ContentView {
    @Observable
    final class ViewModel {
        private let dataManager: SwiftDataProtocol
        var previousStudySession: StudySession?
        init(dataManager: SwiftDataProtocol) {
            self.dataManager = dataManager
        }
        @MainActor func fetchPreviousStudySession() throws {
            self.previousStudySession = try dataManager.fetchLatestStudySession()
        }
    }
}
