//
//  CreateSessionView.swift
//  StudyTimer
//
//  Created by Pursuit on 6/14/25.
//

import SwiftUI
import SwiftData

struct CreateSessionView: View {
    @ObservedObject var viewModel: ViewModel
    @State var showSubjectSelectionView = false
    @State var showTopicSelectionView = false
    @State var showTimerOptionsView = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let duration = viewModel.duration {
                TimerCountdownView(
                    viewModel: .init(
                        totalTime: duration,
                        isRunning: viewModel.isStudying
                    )
                )
                    .padding(.top, 10)
            } else {
                Image(.appLogo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(20)
                    .padding(.top, 10)
            }
            Text(viewModel.studyTimerText)
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.buttonTitleText)
                .padding(.top, 10)
            
            InfoRowView(viewModel: .init(
                title: "Duration",
                value: viewModel.durationText,
                valueBackgroundColor: .clear,
                titleTintColor: .buttonTitleText,
                valueTintColor: .buttonTitleText,
                onTap: {
                    showTimerOptionsView.toggle()
                }
            )
            )
            .background(Color.durationBackground)
            .cornerRadius(20)
            
            VStack {
                InfoRowView(viewModel: .init(
                    title: "Subject",
                    value: viewModel.subjectText,
                    valueBackgroundColor: .pillBackground,
                    titleTintColor: .screenBackground,
                    valueTintColor: .pillText,
                    onTap: {
                        viewModel.selectedTopic = nil
                        showSubjectSelectionView.toggle()
                    }
                )
                )
                Divider().padding(.horizontal, 20)
                InfoRowView(viewModel: .init(
                    title: "Topic",
                    value: viewModel.topicText,
                    valueBackgroundColor: .pillBackground,
                    titleTintColor: .screenBackground,
                    valueTintColor: .pillText,
                    onTap: {
                        guard viewModel.selectedSubject != nil else { return }
                        showTopicSelectionView.toggle()
                    }
                )
                )
            }
            .background(Color.cardBackground)
            .cornerRadius(20)
            Text(viewModel.prompt)
                .font(.system(size: 22))
                .foregroundColor(.buttonTitleText)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            
            Button {
                viewModel.isStudying.toggle()
                Task {
                    try await viewModel.createStudySession()
                }
            } label: {
                Text("Start")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color.cardBackground)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isStudying ? Color.red : Color.startButtonBackground)
                    .cornerRadius(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .background(Color.screenBackground)
        .ignoresSafeArea()
        .sheet(isPresented: $showSubjectSelectionView) {
            SelectionView(viewModel: .init(title: "Select Subject", options: viewModel.subjects), selectedOption: $viewModel.selectedSubject)
        }
        
        .sheet(isPresented: $showTopicSelectionView) {
            SelectionView(viewModel: .init(title: "Select Topic", options: viewModel.topicsInSelectedSubject), selectedOption: $viewModel.selectedTopic)
        }
        .sheet(isPresented: $showTimerOptionsView) {
            SelectionView(viewModel: .init(title: "Select Duration", options: viewModel.durationsInMinutes), selectedOption: $viewModel.selectedDuration)
        }
    }
}

extension CreateSessionView {
    final class ViewModel: ObservableObject {
        @Published var selectedSubject: String? = nil
        @Published var selectedTopic: String? = nil
        @Published var selectedDuration: Int? = nil
        @Published var studySession: StudySession? = nil
        @Published var isStudying: Bool = false
        private let dataManager: SwiftDataManaging
        
        init(
            studySession: StudySession? = nil,
            dataManager: SwiftDataManaging
        ) {
            self.studySession = studySession
            self.dataManager = dataManager
            self.selectedSubject = studySession?.subject
            self.selectedDuration = studySession?.duration
            self.selectedTopic = studySession?.topic
        }
        
        var durationText: String {
            if let selectedDuration {
                return String(describing: selectedDuration) + " min"
            }  else {
                return "Select"
            }
        }
        
        var topicText: String {
            if let selectedTopic {
                return selectedTopic
            }  else {
                return "Select"
            }
        }
        
        var subjectText: String {
            if let selectedSubject {
                return selectedSubject
            }  else {
                return "Select"
            }
        }
        
        var studyTimerText: String {
            return "Study Timer"
        }
        
        var prompt: String {
            if let studySession {
                return isStudying ? "Stop your \(studySession.duration)-minute study session on \(studySession.subject)" : "Start a \(studySession.duration)-minute study session on \(studySession.subject)"
            } else {
                return "Create a new study session"
            }
        }
        
        var duration: Int? {
            var value: Int?
            if let studySession {
                value  =  studySession.duration * 60
            } else if let selectedDuration {
                value = selectedDuration * 60
            } else {
                value = nil
            }
            return value
        }
        
        let subjects = [
            "Mathematics",
            "Biology",
            "Chemistry",
            "Physics",
            "Computer Science",
            "English Language",
            "English Literature",
            "History",
            "Geography",
            "Economics",
            "Psychology",
            "Sociology",
            "Political Science",
            "Philosophy",
            "French",
            "Spanish",
            "Art History",
            "Music Theory",
            "Business Studies",
            "Accounting",
            "Marketing",
            "Personal Finance",
            "Health Education",
            "Physical Education",
            "Creative Writing",
            "Environmental Science"
        ]
        
        private let subjectTopics: [String: [String]] = [
            "Mathematics": ["Algebra", "Geometry", "Calculus", "Statistics", "Trigonometry"],
            "Biology": ["Cell Biology", "Genetics", "Human Anatomy", "Ecology", "Evolution"],
            "Chemistry": ["Organic Chemistry", "Inorganic Chemistry", "Stoichiometry", "Periodic Table", "Chemical Reactions"],
            "Physics": ["Mechanics", "Optics", "Electricity and Magnetism", "Thermodynamics", "Quantum Physics"],
            "Computer Science": ["Data Structures", "Algorithms", "Web Development", "Programming in Swift", "Databases"],
            "English Language": ["Grammar", "Vocabulary", "Comprehension", "Essay Writing", "Speech"],
            "English Literature": ["Shakespeare", "Poetry Analysis", "Modern Novels", "Drama", "Literary Devices"],
            "History": ["World War I", "World War II", "Cold War", "Ancient Civilizations", "Modern History"],
            "Geography": ["Physical Geography", "Human Geography", "Map Skills", "Climate", "Urbanization"],
            "Economics": ["Microeconomics", "Macroeconomics", "Supply and Demand", "Market Structures", "Global Economy"],
            "Psychology": ["Cognitive Psychology", "Behavioral Psychology", "Developmental Psychology", "Research Methods"],
            "Sociology": ["Culture", "Socialization", "Social Inequality", "Family Structures", "Education"],
            "Political Science": ["Governance", "Political Theories", "International Relations", "Elections", "Constitutions"],
            "Philosophy": ["Ethics", "Logic", "Existentialism", "Epistemology", "Political Philosophy"],
            "French": ["Grammar", "Vocabulary", "Speaking Practice", "Writing Practice", "Listening Comprehension"],
            "Spanish": ["Grammar", "Vocabulary", "Speaking Practice", "Reading Practice", "Tenses"],
            "Art History": ["Renaissance Art", "Modern Art", "Impressionism", "Sculpture", "Iconography"],
            "Music Theory": ["Chords", "Scales", "Harmony", "Sight Reading", "Composition"],
            "Business Studies": ["Entrepreneurship", "Business Models", "Operations", "Finance", "Marketing"],
            "Accounting": ["Bookkeeping", "Balance Sheets", "Income Statements", "Auditing", "Cost Accounting"],
            "Marketing": ["Digital Marketing", "Consumer Behavior", "Market Research", "Branding", "SEO"],
            "Personal Finance": ["Budgeting", "Saving", "Investing", "Credit Scores", "Loans"],
            "Health Education": ["Nutrition", "Mental Health", "Substance Abuse", "Reproductive Health", "Diseases"],
            "Physical Education": ["Fitness Training", "Sports Rules", "Anatomy", "Stretching", "Cardio Workouts"],
            "Creative Writing": ["Storytelling", "Poetry", "Character Development", "Plot Structure", "Dialogue"],
            "Environmental Science": ["Climate Change", "Sustainability", "Ecosystems", "Pollution", "Renewable Energy"]
        ]
        
        var topicsInSelectedSubject: [String] {
            guard let selectedSubject,
                  let topics = subjectTopics[selectedSubject]
            else {
                return []
            }
            return topics
        }
        let durationsInMinutes = [30, 45, 60, 75, 90, 105, 120]
        
        func createStudySession() async throws {
            guard let selectedSubject,
                  let selectedTopic,
                  let selectedDuration else {
                return
            }
            let studySession = StudySession(
                duration: selectedDuration,
                subject: selectedSubject,
                topic: selectedTopic
            )
            try await dataManager.saveSession(studySession)
        }
    }
}
