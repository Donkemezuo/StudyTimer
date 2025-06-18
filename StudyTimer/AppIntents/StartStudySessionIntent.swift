//
//  StudySessionIntent.swift
//  StudyTimer
//
//  Created by Raymond Donkemezuo on 6/16/25.
//

/*
 Step 1 - import AppIntents
 */
import AppIntents

/*
 Step 2 - Conform to AppIntent
 */
struct StartStudySessionIntent: AppIntent {
    /*
     Step 3 - Accept the components
     */
    static var title = LocalizedStringResource("Start a new study session")
    
    //Use the parameter keyword to capture the user inputs
    @Parameter(title: "Subject")
    var subject: String
    
    @Parameter(title: "Topic")
    var topic: String
    
    @Parameter(title: "Duration (in minutes)")
    var duration: Int
    
    // Perform the start session
    func perform() async throws -> some IntentResult {
        let newSession = StudySession(
            duration: duration,
            subject: subject,
            topic: topic
        )
        let database = await SwiftDataManager.shared
        do {
            try await database.saveSession(newSession)
        } catch {
            print("RD: Failed to save session: \(error)")
        }
        return .result()
    }
}
