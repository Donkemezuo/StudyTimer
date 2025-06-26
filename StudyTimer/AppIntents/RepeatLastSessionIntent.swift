//
//  RepeatLastSessionIntent.swift
//  StudyTimer
//
//  Created by Raymond Donkemezuo on 6/18/25.
//
import AppIntents

struct RepeatLastSessionIntent: AppIntent, ProvidesDialog {
    var value: Never?
    
    static var title: LocalizedStringResource = "Repeat Last Study Session"
    static var description = IntentDescription("Start a new study session using the same subject, topic, and duration as the last one.")
    
    @MainActor
    func perform() async throws -> some ProvidesDialog {
        guard let lastStudySession = try SwiftDataManager.shared.fetchLatestStudySession() else {
            return .result(dialog: "No previous session found.")
        }
        let newStudySession = StudySession(
            duration: lastStudySession.duration,
            subject: lastStudySession.subject,
            topic: lastStudySession.topic
        )
        try SwiftDataManager.shared.saveStudySession(newStudySession)
        
        return .result(dialog: "Started a new session on \(newStudySession.subject) for \(newStudySession.duration) minutes.")
    }
}
