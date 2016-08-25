//
//  KeychainStorage.swift
//  Pods
//
//  Created by Sam Dean on 8/24/16.
//
//

import Foundation

import Locksmith


public final class KeychainStorage<StorableType: Storable>: Storage {
    
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    public func store(value: StorableType) throws {
        let encoded = try value.storedResult()
        
        try Locksmith.saveData(encoded, forUserAccount: self.key)
    }
    
    public func store(values: [StorableType]) throws {
        let encoded = ["values": try values.map { return try $0.storedResult() } ]
        
        try Locksmith.saveData(encoded, forUserAccount: self.key)
    }
    
    public func retrieve() throws -> StorableType? {
        guard let encoded = try Locksmith.loadDataForUserAccount(self.key) as? StoredResult else {
            return nil
        }
        
        return try StorableType.init(storedResult: encoded)
    }
    
    public func retrieve() throws -> [StorableType]? {
        guard let dict = try Locksmith.loadDataForUserAccount(self.key) as? [String: [StoredResult]],
            let encoded = dict["values"] else {
                return nil
        }

        return try encoded.map {
            guard let value = try StorableType.init(storedResult: $0) else {
                throw StorageError.decodingFailed(from: $0, to: StorableType.self)
            }
            return value
        }
    }
}
