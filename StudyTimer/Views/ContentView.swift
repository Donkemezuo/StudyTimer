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
    let dataManager: SwiftDataManaging
    
    init(dataManager: SwiftDataManaging) {
        let viewModel = ViewModel(dataManager: dataManager)
        _viewModel = State(initialValue: viewModel)
        self.dataManager =  dataManager
    }

    var body: some View {
        NavigationStack {
            if let previousStudySession = viewModel.previousStudySession {
                TabView {
                    CreateSessionView(viewModel: .init(studySession: previousStudySession, dataManager: dataManager))
                        .tabItem {
                            Image(systemName: "timer")
                            Text("Study")
                        }
                        .tag(0)
                    HistoryView(viewModel: .init(dataManager: dataManager))
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
}

extension ContentView {
    @Observable
    final class ViewModel {
        private let dataManager: SwiftDataManaging
        var previousStudySession: StudySession?
        init(dataManager: SwiftDataManaging) {
            self.dataManager = dataManager
        }
        @MainActor func fetchPreviousStudySession() throws {
            self.previousStudySession = try dataManager.fetchLatestStudySession()
        }
    }
}
