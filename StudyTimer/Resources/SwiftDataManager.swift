//
//  SwiftDataManager.swift
//  StudyTimer
//
//  Created by Pursuit on 6/15/25.
//

import Foundation
import SwiftData
import Combine

@MainActor
protocol SwiftDataProtocol {
    var didSaveNewSessionSubject: PassthroughSubject<Void, Never> { get }
    var didDeleteSessionSubject: PassthroughSubject<StudySession, Never> { get }
    var isInMemoryDatabase: Bool { get }
    func fetchLatestStudySession() throws -> StudySession?
    func fetchAllStudySession() throws -> [StudySession]
    func saveStudySession(_ newStudySession: StudySession) throws
    func deleteStudySession(_ session: StudySession) throws
    func deleteAllStudySessions() throws
}

@MainActor
final class SwiftDataManager: SwiftDataProtocol {
    
    static let shared = SwiftDataManager()
    // Shared database app group
    private let appGroupIdentifier: String = "group.com.blueoceantechnologies.StudyTimer"
    internal var isInMemoryDatabase: Bool
    var sharedModelContainer: ModelContainer
    
    init(isInMemoryDatabase: Bool = false) {
        self.isInMemoryDatabase = isInMemoryDatabase
        let schema = Schema([
            StudySession.self,
        ])
        var modelConfiguration: ModelConfiguration
        if isInMemoryDatabase {
            modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: isInMemoryDatabase)
        } else {
            // App group url
            guard let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
                fatalError("Unable to access app group container")
            }
            
            let databaseURL = appGroupURL.appendingPathComponent("StudyTimer.sqlite")
            modelConfiguration = ModelConfiguration(
                schema: schema,
                url: databaseURL
            )
        }
        do {
            self.sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failure trying to create ModelContainer: \(error)")
        }
    }
    
    var didSaveNewSessionSubject = PassthroughSubject<Void, Never>()
    var didDeleteSessionSubject = PassthroughSubject<StudySession, Never>()
    
    internal var context: ModelContext {
        sharedModelContainer.mainContext
    }
    
    func fetchLatestStudySession() throws -> StudySession? {
        let descriptor = FetchDescriptor<StudySession>(sortBy: [SortDescriptor(\.creationDate)])
        let previousStudySession = try context.fetch(descriptor).last
        return previousStudySession
    }

    func fetchAllStudySession() throws -> [StudySession] {
        let descriptor = FetchDescriptor<StudySession>(sortBy: [SortDescriptor(\.creationDate, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func saveStudySession(_ newStudySession: StudySession) throws {
            context.insert(newStudySession)
        try context.save()
        didSaveNewSessionSubject.send()
    }
    
    func deleteStudySession(_ session: StudySession) throws {
        context.delete(session)
        didDeleteSessionSubject.send(session)
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
