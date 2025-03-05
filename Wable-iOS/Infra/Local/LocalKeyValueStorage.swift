//
//  LocalKeyValueStorage.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/5/25.
//


import Foundation

protocol LocalKeyValueStorage {
    func setValue<T: Codable>(_ value: T, for key: String) throws
    func getValue<T: Codable>(for key: String) throws -> T?
    func removeValue(for key: String) throws
}
