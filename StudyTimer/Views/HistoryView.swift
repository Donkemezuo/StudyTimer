//
//  HistoryView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @ObservedObject var viewModel: ViewModel
    @State var showDeleteStudySessionConfrimationAlert: Bool = false
    @State var showDeleteErrorAlert: Bool = false
    var body: some View {
        VStack(spacing: 3) {
            List {
                ForEach(viewModel.studySessions, id: \.self) { studySession in
                    HistoryItemView(
                        viewModel: .init(
                            duration: studySession.duration,
                            date: studySession.creationDate,
                            subject: studySession.subject,
                            topic: studySession.topic
                        )
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            showDeleteStudySessionConfrimationAlert.toggle()
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
        .background(Color.screenBackground)
        .alert(isPresented: $showDeleteErrorAlert) {
            Alert(title: .init("An error occurred"))
        }
        .alert(isPresented: $showDeleteStudySessionConfrimationAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text( "This action will permanently delete the study session"),
                primaryButton: .destructive(Text("Delete").bold(),
                    action: {
                        Task {
                            do {
                                try await viewModel.deleteStudySession(viewModel.studySessions.last!)
                            } catch {
                                showDeleteErrorAlert.toggle()
                            }
                        }
                    }),
                secondaryButton: .cancel(Text("Cancel").bold())
            )
        }
        .onAppear {
            Task {
                try await viewModel.fetchHistory()
            }
        }
    }
}

extension HistoryView {
    final class ViewModel: ObservableObject {
        @Published var studySessions: [StudySession] = []
        private let dataManager: SwiftDataManaging
        
        init(dataManager: SwiftDataManaging) {
            self.dataManager = dataManager
        }
        @MainActor
        func fetchHistory() async throws {
            self.studySessions = try dataManager.fetchAllStudySession()
        }
        
        @MainActor
        func deleteStudySession(_ studySession: StudySession) async throws {
           try self.dataManager.deleteSession(studySession)
            self.studySessions.removeAll { $0.id == studySession.id }
        }
    }
}

struct HistoryItemView: View {
    var viewModel: ViewModel
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(viewModel.displayableDuration)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
                Text(viewModel.displayableDate)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            VStack(alignment: .leading,spacing: 20){
                Text(viewModel.subject)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
                Text(viewModel.topic)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.cardBackground)
        .cornerRadius(20)
        
    }
}

extension HistoryItemView {
    final class ViewModel {
        let duration: Int
        let date: Date
        let subject: String
        let topic: String
        
        var displayableDate: String {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                return "Today"
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM d, yyyy"
                return dateFormatter.string(from: date)
            }
        }
        
        var displayableDuration:  String {
            return String(describing: duration) + " min"
        }
        
        init(
            duration: Int,
            date: Date,
            subject: String,
            topic: String
        ) {
            self.duration = duration
            self.date = date
            self.subject = subject
            self.topic = topic
        }
    }
}
