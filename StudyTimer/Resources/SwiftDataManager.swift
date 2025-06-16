//
//  SwiftDataManager.swift
//  StudyTimer
//
//  Created by Pursuit on 6/15/25.
//

import Foundation
import SwiftData

@MainActor
protocol SwiftDataManaging {
    func fetchLatestStudySession() throws -> StudySession?
    func fetchAllStudySession() throws -> [StudySession]
    func saveSession(_ newStudySession: StudySession) throws
    func deleteSession(_ session: StudySession) throws
    func deleteAllStudySessions() throws
}

@MainActor
final class SwiftDataManager: SwiftDataManaging {

    var previousStudySession: StudySession?
    let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container  = container
    }
    
    var context: ModelContext {
        container.mainContext
    }
    
    func fetchLatestStudySession() throws -> StudySession? {
        let descriptor = FetchDescriptor<StudySession>(sortBy: [SortDescriptor(\.creationDate)])
        self.previousStudySession = try context.fetch(descriptor).first
        return previousStudySession
    }

    func fetchAllStudySession() throws -> [StudySession] {
        let descriptor = FetchDescriptor<StudySession>(sortBy: [SortDescriptor(\.creationDate, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func saveSession(_ newStudySession: StudySession) throws {
            context.insert(newStudySession)
        try context.save()
    }
    
    func deleteSession(_ session: StudySession) throws {
        context.delete(session)
        try context.save()
    }
    
    func deleteAllStudySessions() throws {
        let all = try fetchAllStudySession()
        for session in all {
            context.delete(session)
        }
        try context.save()
    }
    
}
