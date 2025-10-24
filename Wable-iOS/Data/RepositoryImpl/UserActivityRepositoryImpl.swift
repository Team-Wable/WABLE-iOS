//
//  UserActivityRepositoryImpl.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/24/25.
//

import Foundation
import Combine

final class UserActivityRepositoryImpl: UserActivityRepository {
    enum Keys {
        static let activityDictionary = "activityDictionary"
    }

    private let storage: LocalKeyValueProvider
    private let queue = DispatchQueue(label: "com.wable.userActivity.queue", attributes: .concurrent)
    
    private var activities: [UInt: UserActivity] = [:]

    init(storage: LocalKeyValueProvider) {
        self.storage = storage
        loadActivities()
    }

    func fetchUserActivity(for userID: UInt) -> AnyPublisher<UserActivity, WableError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError))
                return
            }
            
            self.queue.async {
                guard let activity = self.activities[userID] else {
                    promise(.failure(.notFoundMember))
                    return
                }
                promise(.success(activity))
            }
        }
        .eraseToAnyPublisher()
    }

    func updateUserActivity(for userID: UInt, _ activity: UserActivity) -> AnyPublisher<Void, WableError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError))
                return
            }
            
            self.queue.async(flags: .barrier) {
                self.activities[userID] = activity
                
                do {
                    try self.storage.setValue(self.activities, for: Keys.activityDictionary)
                    promise(.success(()))
                } catch {
                    promise(.failure(.validationException))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func removeUserActivity(for userID: UInt) -> AnyPublisher<Void, WableError> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError))
                return
            }
            
            self.queue.async(flags: .barrier) {
                self.activities.removeValue(forKey: userID)
                
                do {
                    try self.storage.setValue(self.activities, for: Keys.activityDictionary)
                    promise(.success(()))
                } catch {
                    promise(.failure(.validationException))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func loadActivities() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self,
                  let loadedActivities: [UInt: UserActivity] = try? self.storage.getValue(for: Keys.activityDictionary)
            else {
                return
            }
            
            self.activities = loadedActivities
        }
    }
}

// MARK: - MockUserActivityRepository

struct MockUserActivityRepository: UserActivityRepository {
    private var mockActivities: [UInt: UserActivity] = [:]
    
    func fetchUserActivity(for userID: UInt) -> AnyPublisher<UserActivity, WableError> {
        return .just(.default)
    }
    
    func updateUserActivity(for userID: UInt, _ activity: UserActivity) -> AnyPublisher<Void, WableError> {
        return .just(())
    }

    func removeUserActivity(for userID: UInt) -> AnyPublisher<Void, WableError> {
        return .just(())
    }
}
