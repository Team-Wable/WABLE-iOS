//
//  CodableSerializable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 1/7/25.
//

import Foundation

protocol Serializable {
    func serialize(_ value: Encodable) throws -> Data
}

protocol Deserializable {
    func deserialize<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

typealias CodableSerializable = Serializable & Deserializable


// MARK: - JSONSerializer

struct JSONSerializer: CodableSerializable {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func serialize(_ value: any Encodable) throws -> Data {
        try encoder.encode(value)
    }
    
    func deserialize<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decoder.decode(type, from: data)
    }
}
