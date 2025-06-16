//
//  HistoryView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    var viewModel: ViewModel
    var body: some View {
        VStack(spacing: 3) {
            Text("History")
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.buttonTitleText)
                .multilineTextAlignment(.leading)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.studySessions, id: \.self) { studySession in
                        HistoryItemView(
                            viewModel: .init(
                                duration: studySession.duration,
                                date: studySession.creationDate,
                                subject: studySession.subject,
                                topic: studySession.topic
                            )
                        )
                    }
                }
                .padding()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
        .padding([.horizontal, .top], 20)
        .background(Color.screenBackground)
        .onAppear {
            Task {
                try await viewModel.fetchHistory()
            }
        }
    }
}

extension HistoryView {
    @Observable
    final class ViewModel {
        var studySessions: [StudySession] = []
        private let dataManager: SwiftDataManaging
        
        init(dataManager: SwiftDataManaging) {
            self.dataManager = dataManager
        }
        
        func fetchHistory() async throws {
            self.studySessions = try await dataManager.fetchAllStudySession()
        }
    }
}

struct HistoryItemView: View {
    var viewModel: ViewModel
    var body: some View {
        HStack {
            VStack(spacing: 20) {
                Text(viewModel.displayableDuration)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
                Text(viewModel.displayableDate)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
            }
            .frame(alignment: .leading)
            Spacer()
            VStack(spacing: 20){
                Text(viewModel.subject)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
                Text(viewModel.topic)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.infoTitle)
                    .multilineTextAlignment(.leading)
            }
            .frame(alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.cardBackground)
        .cornerRadius(20)
        
    }
}

extension HistoryItemView {
    @Observable
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
